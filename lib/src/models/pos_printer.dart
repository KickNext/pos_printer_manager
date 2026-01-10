import 'dart:async';

import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Статус подключения принтера.
enum PrinterConnectionStatus {
  /// Статус неизвестен (начальное состояние)
  unknown,

  /// Принтер подключен и готов к работе
  connected,

  /// Произошла ошибка при работе с принтером
  error,
}

/// Статус USB разрешения для принтера.
enum UsbPermissionStatus {
  /// Разрешение не требуется (сетевой принтер) или статус неизвестен
  notRequired,

  /// Разрешение не проверялось
  unknown,

  /// Разрешение получено
  granted,

  /// Пользователь отказал в разрешении
  denied,
}

/// Состояние ожидания перезагрузки принтера после смены сетевых настроек.
///
/// После изменения сетевых настроек (IP, маска, шлюз, DHCP) принтер необходимо
/// перезагрузить для применения изменений. До перезагрузки:
/// - Текущие сетевые параметры подключения становятся недействительными
/// - Тестирование и диагностика по сети невозможны
/// - USB-подключение продолжает работать нормально
class PendingNetworkReboot {
  /// Сетевые настройки, которые были отправлены на принтер.
  final NetworkParams newSettings;

  /// Время, когда настройки были отправлены.
  final DateTime timestamp;

  /// Тип подключения, через которое были отправлены настройки.
  /// USB — настройки отправлены напрямую
  /// Network — настройки отправлены через UDP broadcast
  final PosPrinterConnectionType configuredVia;

  /// Создаёт состояние ожидания перезагрузки.
  const PendingNetworkReboot({
    required this.newSettings,
    required this.timestamp,
    required this.configuredVia,
  });

  /// Возвращает true, если новые настройки включают DHCP.
  /// По умолчанию false, если значение не задано.
  bool get isDhcpEnabled => newSettings.dhcp ?? false;

  /// Возвращает новый IP-адрес (или null для DHCP).
  String? get newIpAddress => isDhcpEnabled ? null : newSettings.ipAddress;
}

/// Информация об ошибке принтера.
class PrinterError {
  /// Сообщение об ошибке.
  final String message;

  /// Время возникновения ошибки.
  final DateTime timestamp;

  /// Дополнительные детали ошибки.
  final String? details;

  PrinterError({required this.message, required this.timestamp, this.details});
}

/// Класс, представляющий POS-принтер с его конфигурацией и состоянием.
///
/// Управляет подключением, статусом, USB-разрешениями и печатью.
class PosPrinter with LoggerMixin {
  @override
  String get loggerName => 'PosPrinter';
  PosPrinter({
    required PrinterConfig config,
    required this.saveConfig,
    required this.notify,
  }) : _config = config {
    _status = PrinterConnectionStatus.unknown;
    // Определяем начальный статус USB разрешения на основе типа подключения
    _usbPermissionStatus = _isUsbPrinter
        ? UsbPermissionStatus.unknown
        : UsbPermissionStatus.notRequired;
  }

  /// Уникальный идентификатор принтера.
  String get id => _config.id;

  /// Внутренняя переменная конфигурации (immutable, но заменяемая).
  PrinterConfig _config;

  /// Конфигурация принтера.
  ///
  /// Возвращает копию конфигурации для предотвращения внешних изменений.
  PrinterConfig get config => _config;

  /// Обновляет конфигурацию принтера.
  ///
  /// [newConfig] — новая конфигурация (должна иметь тот же ID).
  void updateConfig(PrinterConfig newConfig) {
    assert(newConfig.id == _config.id, 'Cannot change printer ID');
    logger.debug(
      'Config updated',
      data: {'printerId': id, 'name': newConfig.name},
    );
    _config = newConfig;
  }

  /// Тип принтера (чековый, этикеточный, кухонный и т.д.).
  PrinterPOSType get type => _config.printerPosType;

  PrinterConnectionStatus _status = PrinterConnectionStatus.unknown;
  PrinterError? _lastError;
  UsbPermissionStatus _usbPermissionStatus = UsbPermissionStatus.unknown;

  /// Состояние ожидания перезагрузки после смены сетевых настроек.
  /// null означает, что принтер не ожидает перезагрузки.
  PendingNetworkReboot? _pendingNetworkReboot;

  /// Текущий статус подключения принтера.
  PrinterConnectionStatus get status => _status;

  /// Последняя ошибка, возникшая при работе с принтером.
  PrinterError? get lastError => _lastError;

  /// Текущий статус USB разрешения.
  UsbPermissionStatus get usbPermissionStatus => _usbPermissionStatus;

  /// Состояние ожидания перезагрузки после смены сетевых настроек.
  ///
  /// Не null, если сетевые настройки были изменены и принтер ещё не перезагружен.
  /// В этом состоянии тестирование и диагностика по сети заблокированы.
  PendingNetworkReboot? get pendingNetworkReboot => _pendingNetworkReboot;

  /// Возвращает true, если принтер ожидает перезагрузки после смены сетевых настроек.
  bool get hasPendingNetworkReboot => _pendingNetworkReboot != null;

  /// Проверяет, заблокировано ли тестирование из-за ожидания перезагрузки.
  ///
  /// Тестирование блокируется только если:
  /// - Есть ожидающая перезагрузка
  /// - Принтер подключён по сети (USB-подключение работает всегда)
  bool get isTestingBlockedByPendingReboot {
    if (_pendingNetworkReboot == null) return false;

    final connectionType = handler.settings.connectionParams?.connectionType;
    // USB-подключение не блокируется
    return connectionType == PosPrinterConnectionType.network;
  }

  /// Проверяет, является ли принтер USB-принтером.
  bool get _isUsbPrinter =>
      handler.settings.connectionParams?.connectionType ==
      PosPrinterConnectionType.usb;

  /// Проверяет, требуется ли USB разрешение для этого принтера.
  bool get requiresUsbPermission =>
      _isUsbPrinter && _usbPermissionStatus != UsbPermissionStatus.granted;

  /// Backward compatibility - проверка подключения.
  bool get isConnected => _status == PrinterConnectionStatus.connected;

  /// Callback для сохранения конфигурации.
  final Future<void> Function() saveConfig;

  /// Callback для уведомления об изменениях.
  final void Function() notify;

  /// Обработчик протокола принтера.
  late PrinterProtocolHandler handler = PrinterPluginRegistry.buildHandler(
    config,
  );

  // === USB Permission Methods ===

  /// Проверяет, есть ли USB разрешение для этого принтера.
  ///
  /// Для сетевых принтеров всегда возвращает [UsbPermissionResult] с granted=true.
  Future<UsbPermissionResult> checkUsbPermission() async {
    if (!_isUsbPrinter) {
      _usbPermissionStatus = UsbPermissionStatus.notRequired;
      return UsbPermissionResult(
        granted: true,
        errorMessage: null,
        deviceInfo: 'Network printer - no USB permission required',
      );
    }

    final usbParams = handler.settings.connectionParams?.usbParams;
    if (usbParams == null) {
      _usbPermissionStatus = UsbPermissionStatus.unknown;
      return UsbPermissionResult(
        granted: false,
        errorMessage: 'USB params not available',
        deviceInfo: null,
      );
    }

    final result = await handler.manager.hasUsbPermission(usbParams);
    _usbPermissionStatus = result.granted
        ? UsbPermissionStatus.granted
        : UsbPermissionStatus.denied;
    notify();
    return result;
  }

  /// Запрашивает USB разрешение для этого принтера.
  ///
  /// Показывает системный диалог запроса разрешения на Android.
  /// Для сетевых принтеров сразу возвращает успех.
  Future<UsbPermissionResult> requestUsbPermission() async {
    if (!_isUsbPrinter) {
      _usbPermissionStatus = UsbPermissionStatus.notRequired;
      return UsbPermissionResult(
        granted: true,
        errorMessage: null,
        deviceInfo: 'Network printer - no USB permission required',
      );
    }

    final usbParams = handler.settings.connectionParams?.usbParams;
    if (usbParams == null) {
      _usbPermissionStatus = UsbPermissionStatus.unknown;
      return UsbPermissionResult(
        granted: false,
        errorMessage: 'USB params not available',
        deviceInfo: null,
      );
    }

    final result = await handler.manager.requestUsbPermission(usbParams);
    _usbPermissionStatus = result.granted
        ? UsbPermissionStatus.granted
        : UsbPermissionStatus.denied;
    notify();
    return result;
  }

  /// Выполняет операцию с автоматическим запросом USB разрешения.
  ///
  /// Если принтер USB и разрешение не получено, запрашивает его.
  /// Выбрасывает [UsbPermissionDeniedException] если пользователь отказал.
  Future<T> withUsbPermission<T>(Future<T> Function() operation) async {
    if (!_isUsbPrinter) {
      return operation();
    }

    final connectionParams = handler.settings.connectionParams;
    if (connectionParams == null) {
      throw StateError('Connection params not configured');
    }

    return handler.manager.withUsbPermission(connectionParams, operation);
  }

  // === Print Methods ===

  /// Пытается выполнить печать и обновляет статус на основе результата.
  ///
  /// Автоматически запрашивает USB разрешение если требуется.
  Future<PrintResult> tryPrint(PrintJob job) async {
    logger.info(
      'Starting print job',
      data: {'printerId': id, 'jobType': job.runtimeType.toString()},
    );

    try {
      // Для USB-принтеров автоматически оборачиваем в withUsbPermission
      if (_isUsbPrinter && handler.settings.connectionParams != null) {
        return await handler.manager.withUsbPermission(
          handler.settings.connectionParams!,
          () async {
            final result = await handler.print(job);
            if (result.success) {
              _updateStatus(PrinterConnectionStatus.connected);
              _usbPermissionStatus = UsbPermissionStatus.granted;
              logger.info(
                'Print completed successfully',
                data: {'printerId': id},
              );
            } else {
              _updateError(result.message ?? 'Print failed');
              logger.warning(
                'Print failed',
                data: {'printerId': id, 'error': result.message},
              );
            }
            return result;
          },
        );
      } else {
        final result = await handler.print(job);
        if (result.success) {
          _updateStatus(PrinterConnectionStatus.connected);
          logger.info('Print completed successfully', data: {'printerId': id});
        } else {
          _updateError(result.message ?? 'Print failed');
          logger.warning(
            'Print failed',
            data: {'printerId': id, 'error': result.message},
          );
        }
        return result;
      }
    } on UsbPermissionDeniedException catch (e) {
      _usbPermissionStatus = UsbPermissionStatus.denied;
      _updateError('USB permission denied: ${e.message}');
      logger.warning('USB permission denied', data: {'printerId': id});
      return PrintResult(success: false, message: e.toString());
    } catch (e, st) {
      _updateError(e.toString());
      logger.error('Print exception', error: e, stackTrace: st);
      return PrintResult(success: false, message: e.toString());
    }
  }

  /// Тестовая печать для проверки подключения.
  Future<void> testConnection() async {
    logger.info('Testing connection', data: {'printerId': id});

    try {
      // Для USB-принтеров автоматически оборачиваем в withUsbPermission
      if (_isUsbPrinter && handler.settings.connectionParams != null) {
        await handler.manager.withUsbPermission(
          handler.settings.connectionParams!,
          () async {
            await handler.testPrint();
            _updateStatus(PrinterConnectionStatus.connected);
            _usbPermissionStatus = UsbPermissionStatus.granted;
            logger.info('Connection test passed', data: {'printerId': id});
          },
        );
      } else {
        await handler.testPrint();
        _updateStatus(PrinterConnectionStatus.connected);
        logger.info('Connection test passed', data: {'printerId': id});
      }
    } on UsbPermissionDeniedException catch (e) {
      _usbPermissionStatus = UsbPermissionStatus.denied;
      _updateError('USB permission denied: ${e.message}');
      logger.warning(
        'USB permission denied during test',
        data: {'printerId': id},
      );
    } catch (e, st) {
      _updateError(e.toString());
      logger.error('Connection test failed', error: e, stackTrace: st);
    }
  }

  /// Legacy method - теперь просто тестирует подключение.
  Future<void> getStatus() async {
    await testConnection();
  }

  // === Status Management ===

  void _updateStatus(PrinterConnectionStatus status) {
    logger.debug(
      'Status updated',
      data: {'printerId': id, 'status': status.name},
    );
    _status = status;
    if (status == PrinterConnectionStatus.connected) {
      _lastError = null;
    }
    notify();
  }

  void _updateError(String message, {String? details}) {
    logger.warning('Error occurred', data: {'printerId': id, 'error': message});
    _status = PrinterConnectionStatus.error;
    _lastError = PrinterError(
      message: message,
      timestamp: DateTime.now(),
      details: details,
    );
    notify();
  }

  /// Очищает ошибку и сбрасывает статус.
  void clearError() {
    _lastError = null;
    _status = PrinterConnectionStatus.unknown;
    notify();
  }

  // === Network Settings Pending Reboot Management ===

  /// Устанавливает состояние ожидания перезагрузки после смены сетевых настроек.
  ///
  /// Вызывается после успешной отправки новых сетевых настроек на принтер.
  /// [newSettings] — новые сетевые настройки, отправленные на принтер
  /// [configuredVia] — тип подключения, через которое были отправлены настройки
  void setNetworkSettingsPending({
    required NetworkParams newSettings,
    required PosPrinterConnectionType configuredVia,
  }) {
    final isDhcp = newSettings.dhcp ?? false;
    logger.info(
      'Network settings pending reboot',
      data: {
        'printerId': id,
        'dhcp': isDhcp,
        'newIp': isDhcp ? 'DHCP' : newSettings.ipAddress,
        'configuredVia': configuredVia.name,
      },
    );
    _pendingNetworkReboot = PendingNetworkReboot(
      newSettings: newSettings,
      timestamp: DateTime.now(),
      configuredVia: configuredVia,
    );
    notify();
  }

  /// Очищает состояние ожидания перезагрузки.
  ///
  /// Вызывается когда пользователь подтверждает, что принтер перезагружен
  /// и переподключён с новыми настройками.
  void clearPendingNetworkReboot() {
    if (_pendingNetworkReboot != null) {
      logger.info('Cleared pending network reboot', data: {'printerId': id});
      _pendingNetworkReboot = null;
      notify();
    }
  }

  /// Сбрасывает подключение и очищает состояние ожидания перезагрузки.
  ///
  /// Используется когда пользователь отключает принтер для переподключения
  /// после перезагрузки с новыми сетевыми настройками.
  Future<void> resetConnectionForNewNetworkSettings() async {
    logger.info(
      'Resetting connection for new network settings',
      data: {'printerId': id},
    );

    // Очищаем параметры подключения — пользователь должен найти принтер заново
    await handler.settings.updateConnectionParams(null);

    // Очищаем pending state
    _pendingNetworkReboot = null;

    // Сбрасываем статус
    _status = PrinterConnectionStatus.unknown;
    _lastError = null;

    notify();
  }

  /// Legacy method for backward compatibility.
  void updateStatus(bool status) {
    _updateStatus(
      status
          ? PrinterConnectionStatus.connected
          : PrinterConnectionStatus.error,
    );
  }

  /// Обновляет имя принтера.
  ///
  /// Создаёт новую immutable конфигурацию с изменённым именем.
  void updateName(String name) {
    _config = _config.copyWith(name: name);
    logger.debug('Name updated', data: {'printerId': id, 'name': name});
    unawaited(saveConfig());
  }
}
