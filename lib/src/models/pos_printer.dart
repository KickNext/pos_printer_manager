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
class PosPrinter {
  PosPrinter({
    required this.config,
    required this.saveConfig,
    required this.notify,
  }) {
    _status = PrinterConnectionStatus.unknown;
    // Определяем начальный статус USB разрешения на основе типа подключения
    _usbPermissionStatus =
        _isUsbPrinter
            ? UsbPermissionStatus.unknown
            : UsbPermissionStatus.notRequired;
  }

  /// Уникальный идентификатор принтера.
  String get id => config.id;

  /// Конфигурация принтера.
  final PrinterConfig config;

  /// Тип принтера (чековый, этикеточный, кухонный и т.д.).
  PrinterPOSType get type => config.printerPosType;

  PrinterConnectionStatus _status = PrinterConnectionStatus.unknown;
  PrinterError? _lastError;
  UsbPermissionStatus _usbPermissionStatus = UsbPermissionStatus.unknown;

  /// Текущий статус подключения принтера.
  PrinterConnectionStatus get status => _status;

  /// Последняя ошибка, возникшая при работе с принтером.
  PrinterError? get lastError => _lastError;

  /// Текущий статус USB разрешения.
  UsbPermissionStatus get usbPermissionStatus => _usbPermissionStatus;

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
    _usbPermissionStatus =
        result.granted
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
    _usbPermissionStatus =
        result.granted
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
            } else {
              _updateError(result.message ?? 'Print failed');
            }
            return result;
          },
        );
      } else {
        final result = await handler.print(job);
        if (result.success) {
          _updateStatus(PrinterConnectionStatus.connected);
        } else {
          _updateError(result.message ?? 'Print failed');
        }
        return result;
      }
    } on UsbPermissionDeniedException catch (e) {
      _usbPermissionStatus = UsbPermissionStatus.denied;
      _updateError('USB permission denied: ${e.message}');
      return PrintResult(success: false, message: e.toString());
    } catch (e) {
      _updateError(e.toString());
      return PrintResult(success: false, message: e.toString());
    }
  }

  /// Тестовая печать для проверки подключения.
  Future<void> testConnection() async {
    try {
      // Для USB-принтеров автоматически оборачиваем в withUsbPermission
      if (_isUsbPrinter && handler.settings.connectionParams != null) {
        await handler.manager.withUsbPermission(
          handler.settings.connectionParams!,
          () async {
            await handler.testPrint();
            _updateStatus(PrinterConnectionStatus.connected);
            _usbPermissionStatus = UsbPermissionStatus.granted;
          },
        );
      } else {
        await handler.testPrint();
        _updateStatus(PrinterConnectionStatus.connected);
      }
    } on UsbPermissionDeniedException catch (e) {
      _usbPermissionStatus = UsbPermissionStatus.denied;
      _updateError('USB permission denied: ${e.message}');
    } catch (e) {
      _updateError(e.toString());
    }
  }

  /// Legacy method - теперь просто тестирует подключение.
  Future<void> getStatus() async {
    await testConnection();
  }

  // === Status Management ===

  void _updateStatus(PrinterConnectionStatus status) {
    _status = status;
    if (status == PrinterConnectionStatus.connected) {
      _lastError = null;
    }
    notify();
  }

  void _updateError(String message, {String? details}) {
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

  /// Legacy method for backward compatibility.
  void updateStatus(bool status) {
    _updateStatus(
      status
          ? PrinterConnectionStatus.connected
          : PrinterConnectionStatus.error,
    );
  }

  void updateName(String name) {
    config.name = name;
    unawaited(saveConfig());
  }
}
