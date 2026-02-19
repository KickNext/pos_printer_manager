import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Менеджер POS-принтеров.
///
/// Центральный класс для управления принтерами в приложении.
/// Обеспечивает добавление, удаление, настройку и печать на принтерах.
///
/// ## Пример использования:
///
/// ```dart
/// final manager = PrintersManager();
/// await manager.init(getCategoriesFunction: getCategories);
///
/// // Добавление принтера
/// final result = await manager.addPrinterSafe(
///   name: 'Kitchen Printer',
///   type: PrinterPOSType.kitchenPrinter,
/// );
///
/// result.when(
///   success: (printer) => print('Added: ${printer.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
class PrintersManager with ChangeNotifier, LoggerMixin {
  /// API для работы с принтерами низкого уровня.
  final PosPrintersManager api = PosPrintersManager();

  /// Репозиторий для хранения конфигураций принтеров.
  final PrinterConfigRepository _repository;

  /// Поисковик принтеров в сети и USB.
  late final PrintersFinder finder = PrintersFinder(posPrintersManager: api);

  @override
  String get loggerName => 'PrintersManager';

  /// Callback для получения категорий для кухонного принтера.
  late final Future<List<CategoryForPrinter>> Function({
    required List<CategoryForPrinter> currentCategories,
  })
  getCategoriesForPrinter;

  /// Максимальное количество чековых принтеров.
  final int maxReceiptPrinters = 1;

  /// Максимальное количество кухонных принтеров.
  final int maxKitchenPrinters = 9999;

  /// Максимальное количество этикеточных принтеров.
  final int maxLabelPrinters = 1;

  /// Максимальное количество AndroBar принтеров.
  final int maxAndroBarPrinters = 1;

  /// Проверяет, можно ли добавить принтер указанного типа.
  ///
  /// [type] — тип принтера для проверки. Если null, проверяет
  /// возможность добавить хотя бы один принтер любого типа.
  ///
  /// Возвращает true если можно добавить принтер указанного типа.
  bool canAddPrinterOfType([PrinterPOSType? type]) {
    // Считаем количество принтеров каждого типа
    final counts = <PrinterPOSType, int>{};
    for (final printerType in PrinterPOSType.values) {
      counts[printerType] = printers.where((p) => p.type == printerType).length;
    }

    // Лимиты для каждого типа
    final limits = <PrinterPOSType, int>{
      PrinterPOSType.receiptPrinter: maxReceiptPrinters,
      PrinterPOSType.kitchenPrinter: maxKitchenPrinters,
      PrinterPOSType.labelPrinter: maxLabelPrinters,
      PrinterPOSType.androBar: maxAndroBarPrinters,
    };

    logger.debug(
      'Checking can add printer',
      data: {
        'type': type?.name ?? 'any',
        'counts': counts.map((k, v) => MapEntry(k.name, v)),
      },
    );

    // Если указан конкретный тип, проверяем только его
    if (type != null) {
      return (counts[type] ?? 0) < (limits[type] ?? 0);
    }

    // Иначе проверяем, можно ли добавить хотя бы один принтер
    return limits.entries.any((entry) {
      return (counts[entry.key] ?? 0) < entry.value;
    });
  }

  /// Проверяет, можно ли добавить ещё один принтер любого типа.
  ///
  /// @deprecated Используйте [canAddPrinterOfType] для более точной проверки.
  @Deprecated('Use canAddPrinterOfType() instead')
  bool get canAddPrinter => canAddPrinterOfType();

  List<PosPrinter> _printers = [];

  /// Неизменяемый список всех принтеров.
  List<PosPrinter> get printers => List.unmodifiable(_printers);

  /// Создает менеджер принтеров.
  ///
  /// [repository] - опциональный репозиторий для хранения конфигураций.
  /// По умолчанию используется [SharedPrefsPrinterConfigRepository].
  PrintersManager({PrinterConfigRepository? repository})
    : _repository = repository ?? SharedPrefsPrinterConfigRepository();

  /// Инициализирует менеджер принтеров.
  ///
  /// Загружает сохранённые конфигурации и создаёт объекты принтеров.
  Future<void> init({
    required Future<List<CategoryForPrinter>> Function({
      required List<CategoryForPrinter> currentCategories,
    })
    getCategoriesFunction,
  }) async {
    final stopwatch = logger.startOperation('Init');

    getCategoriesForPrinter = getCategoriesFunction;
    PrinterPOSType.registerPrinterTypes(this);

    final configs = await _repository.loadConfigs();
    logger.info('Loaded printer configs', data: {'count': configs.length});

    _printers = configs.map((config) {
      return PosPrinter(
        config: config,
        saveConfig: () => saveConfigs(),
        notify: () => notifyListeners(),
      );
    }).toList();

    // По умолчанию все принтеры считаются подключёнными при инициализации.
    for (var printer in _printers) {
      printer.updateStatus(true);
    }

    logger.endOperation('Init', stopwatch);
  }

  /// Добавляет новый POS-принтер.
  ///
  /// [name] - имя принтера.
  /// [type] - тип принтера.
  Future<void> addPosPrinter(String name, PrinterPOSType type) async {
    logger.info('Adding printer', data: {'name': name, 'type': type.name});

    final id = IdGenerator.generate();
    final config = PrinterConfig(
      id: id,
      name: name,
      printerPosType: type,
      rawSettings: {},
    );
    _printers.add(
      PosPrinter(
        config: config,
        saveConfig: () => saveConfigs(),
        notify: () => notifyListeners(),
      ),
    );
    await saveConfigs();

    logger.info('Printer added', data: {'id': id, 'name': name});
    notifyListeners();
  }

  /// Добавляет новый принтер с безопасной обработкой ошибок.
  ///
  /// Возвращает [Result] с конфигурацией принтера или ошибкой.
  Future<Result<PrinterConfig>> addPrinterSafe({
    required PrinterPOSType type,
    required String name,
  }) async {
    // Валидация имени
    if (name.trim().isEmpty) {
      logger.warning('Validation failed: empty name');
      return const Result.failure(
        AppError.validation('Printer name cannot be empty'),
      );
    }

    // Проверка лимита для конкретного типа
    if (!canAddPrinterOfType(type)) {
      logger.warning(
        'Cannot add more printers of this type',
        data: {'type': type.name},
      );
      return Result.failure(
        AppError.validation('Maximum number of ${type.name} printers reached'),
      );
    }

    try {
      await addPosPrinter(name.trim(), type);
      return Result.success(_printers.last.config);
    } catch (e, st) {
      logger.error('Failed to add printer', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }

  /// Add printer (alias for backward compatibility)
  @Deprecated('Use addPrinterSafe for better error handling')
  Future<PrinterConfig> addPrinter({
    required PrinterPOSType type,
    required String name,
  }) async {
    await addPosPrinter(name, type);
    return _printers.last.config;
  }

  /// Get list of printer configurations
  List<PrinterConfig> getPrinters() {
    return _printers.map((p) => p.config).toList();
  }

  /// Получает принтер по ID с безопасной обработкой ошибок.
  ///
  /// Возвращает [Result] с принтером или ошибкой.
  Result<PosPrinter> getPrinterById(String printerId) {
    if (printerId.trim().isEmpty) {
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    final printer = _printers.where((p) => p.id == printerId).firstOrNull;

    if (printer == null) {
      return Result.failure(
        AppError.notFound('Printer with ID $printerId not found'),
      );
    }

    return Result.success(printer);
  }

  /// Update printer configuration
  ///
  /// @Deprecated: Use [updatePrinterConfigSafe] for better error handling.
  Future<void> updatePrinterConfig(PrinterConfig updatedConfig) async {
    logger.info(
      'Updating printer config',
      data: {'printerId': updatedConfig.id, 'name': updatedConfig.name},
    );

    final index = _printers.indexWhere((p) => p.id == updatedConfig.id);
    if (index != -1) {
      // Создаём новую immutable конфигурацию
      final newConfig = _printers[index].config.copyWith(
        name: updatedConfig.name,
        rawSettings: Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(updatedConfig.rawSettings),
        ),
      );
      _printers[index].updateConfig(newConfig);
      await saveConfigs();

      logger.info(
        'Printer config updated',
        data: {'printerId': updatedConfig.id},
      );
      notifyListeners();
    } else {
      logger.warning(
        'Printer not found',
        data: {'printerId': updatedConfig.id},
      );
    }
  }

  /// Обновляет конфигурацию принтера с безопасной обработкой ошибок.
  ///
  /// Возвращает [Result] с обновлённой конфигурацией или ошибкой.
  Future<Result<PrinterConfig>> updatePrinterConfigSafe(
    PrinterConfig updatedConfig,
  ) async {
    if (updatedConfig.id.trim().isEmpty) {
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    if (updatedConfig.name.trim().isEmpty) {
      return const Result.failure(
        AppError.validation('Printer name cannot be empty'),
      );
    }

    final index = _printers.indexWhere((p) => p.id == updatedConfig.id);
    if (index == -1) {
      return Result.failure(
        AppError.notFound('Printer with ID ${updatedConfig.id} not found'),
      );
    }

    try {
      await updatePrinterConfig(updatedConfig);
      return Result.success(_printers[index].config);
    } catch (e, st) {
      logger.error('Failed to update printer config', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }

  /// Remove printer (alias for backward compatibility)
  @Deprecated('Use removePrinterSafe for better error handling')
  Future<void> removePrinter(String id) async {
    await removePosPrinter(id);
  }

  /// Удаляет принтер с безопасной обработкой ошибок.
  ///
  /// Возвращает [Result] с успехом или ошибкой.
  Future<Result<void>> removePrinterSafe(String printerId) async {
    if (printerId.trim().isEmpty) {
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    final exists = _printers.any((p) => p.id == printerId);
    if (!exists) {
      return Result.failure(
        AppError.notFound('Printer with ID $printerId not found'),
      );
    }

    try {
      await removePosPrinter(printerId);
      return const Result.success(null);
    } catch (e, st) {
      logger.error('Failed to remove printer', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }

  /// Print using specific printer
  Future<PrintResult> print(String printerId, PrintJob job) async {
    logger.info(
      'Printing',
      data: {'printerId': printerId, 'jobType': job.runtimeType.toString()},
    );

    final printer = _printers.firstWhere((p) => p.id == printerId);
    final result = await printer.tryPrint(job);

    if (result.success) {
      logger.info('Print completed', data: {'printerId': printerId});
    } else {
      logger.warning(
        'Print failed',
        data: {'printerId': printerId, 'error': result.message},
      );
    }

    return result;
  }

  /// Печатает с безопасной обработкой ошибок.
  ///
  /// Возвращает [Result] с результатом печати или ошибкой.
  Future<Result<PrintResult>> printSafe(String printerId, PrintJob job) async {
    if (printerId.trim().isEmpty) {
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    final printerResult = getPrinterById(printerId);
    if (printerResult.isFailure) {
      return Result.failure(printerResult.errorOrNull!);
    }

    try {
      final result = await print(printerId, job);
      if (result.success) {
        return Result.success(result);
      } else {
        return Result.failure(
          AppError.printing(result.message ?? 'Print failed'),
        );
      }
    } catch (e, st) {
      logger.error('Print exception', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }

  /// Retry connection to printer
  Future<void> retryConnection(String printerId) async {
    logger.info('Retrying connection', data: {'printerId': printerId});

    final printer = _printers.firstWhere((p) => p.id == printerId);
    await printer.testConnection();

    logger.info(
      'Connection retry completed',
      data: {'printerId': printerId, 'status': printer.status.name},
    );
  }

  /// Тестирует подключение к принтеру с безопасной обработкой ошибок.
  ///
  /// Возвращает [Result] с успехом или ошибкой.
  Future<Result<void>> testConnectionSafe(String printerId) async {
    if (printerId.trim().isEmpty) {
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    final printerResult = getPrinterById(printerId);
    if (printerResult.isFailure) {
      return Result.failure(printerResult.errorOrNull!);
    }

    try {
      await retryConnection(printerId);
      final printer = printerResult.dataOrNull!;

      if (printer.status == PrinterConnectionStatus.connected) {
        return const Result.success(null);
      } else {
        return Result.failure(
          AppError.connection(
            printer.lastError?.message ?? 'Connection failed',
          ),
        );
      }
    } catch (e, st) {
      logger.error('Connection test failed', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }

  /// Удаляет POS-принтер по ID.
  Future<void> removePosPrinter(String id) async {
    logger.info('Removing printer', data: {'printerId': id});

    _printers.removeWhere((printer) => printer.id == id);
    await saveConfigs();

    logger.info('Printer removed', data: {'printerId': id});
    notifyListeners();
  }

  /// Сохраняет все конфигурации принтеров.
  ///
  /// Синхронизирует настройки из handler'ов обратно в конфигурации
  /// и сохраняет их в репозиторий.
  Future<void> saveConfigs() async {
    logger.debug('Saving configs', data: {'count': _printers.length});

    // Обновляем rawSettings из текущих настроек handler'ов
    for (var printer in _printers) {
      final newRawSettings = Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(printer.handler.settings.toJson()),
      );
      final newConfig = printer.config.copyWith(rawSettings: newRawSettings);
      printer.updateConfig(newConfig);
    }

    await _repository.saveConfigs(_printers.map((e) => e.config).toList());

    logger.debug('Configs saved');
    notifyListeners();
  }

  // === Printer Discovery Methods ===

  /// Find printers with optional filter
  Stream<PrinterConnectionParamsDTO> findPrinters({
    PrinterDiscoveryFilter? filter,
  }) {
    return api.findPrinters(filter: filter);
  }

  /// Await for discovery process completion
  Future<void> awaitDiscoveryComplete() async {
    return api.awaitDiscoveryComplete();
  }

  /// Stream of discovered printers during scanning
  Stream<PrinterConnectionParamsDTO> get discoveryStream => api.discoveryStream;

  /// Stream of printer connection events (attach/detach)
  Stream<PrinterConnectionEvent> get connectionEvents => api.connectionEvents;

  // === Printer Status and Information ===

  /// Get printer status
  Future<StatusResult> getPrinterStatus(
    PrinterConnectionParamsDTO printer,
  ) async {
    return api.getPrinterStatus(printer);
  }

  /// Get printer serial number
  Future<StringResult> getPrinterSN(PrinterConnectionParamsDTO printer) async {
    return api.getPrinterSN(printer);
  }

  /// Get ZPL printer status
  Future<ZPLStatusResult> getZPLPrinterStatus(
    PrinterConnectionParamsDTO printer,
  ) async {
    return api.getZPLPrinterStatus(printer);
  }

  // === Cash Drawer Control ===

  /// Open cash drawer connected to printer
  Future<void> openCashBox(PrinterConnectionParamsDTO printer) async {
    return api.openCashBox(printer);
  }

  // === ESC/POS Printing ===

  /// Print HTML content on ESC/POS printer
  Future<void> printEscHTML(
    PrinterConnectionParamsDTO printer,
    String html,
    int width, {
    bool upsideDown = false,
  }) async {
    return api.printEscHTML(printer, html, width, upsideDown: upsideDown);
  }

  /// Print raw ESC/POS commands
  Future<void> printEscRawData(
    PrinterConnectionParamsDTO printer,
    Uint8List data,
    int width, {
    bool upsideDown = false,
  }) async {
    return api.printEscRawData(printer, data, width, upsideDown: upsideDown);
  }

  // === ZPL Label Printing ===

  /// Print HTML content on ZPL label printer
  Future<void> printZplHtml(
    PrinterConnectionParamsDTO printer,
    String html,
    int width,
  ) async {
    return api.printZplHtml(printer, html, width);
  }

  /// Print raw ZPL commands
  Future<void> printZplRawData(
    PrinterConnectionParamsDTO printer,
    Uint8List data,
    int width,
  ) async {
    return api.printZplRawData(printer, data, width);
  }

  // === TSPL Label Printing ===

  /// Print HTML content on TSPL label printer
  Future<void> printTsplHtml(
    PrinterConnectionParamsDTO printer,
    String html,
    int width,
  ) async {
    return api.printTsplHtml(printer, html, width);
  }

  /// Print raw TSPL commands
  Future<void> printTsplRawData(
    PrinterConnectionParamsDTO printer,
    Uint8List data,
    int width,
  ) async {
    return api.printTsplRawData(printer, data, width);
  }

  /// Get TSPL printer status
  Future<TSPLStatusResult> getTSPLPrinterStatus(
    PrinterConnectionParamsDTO printer,
  ) async {
    return api.getTSPLPrinterStatus(printer);
  }

  // === USB Permission Management ===

  /// Запрашивает разрешение на использование USB-устройства у пользователя.
  ///
  /// В Android для работы с USB-устройствами необходимо получить разрешение
  /// от пользователя. Этот метод показывает системный диалог с запросом.
  ///
  /// **ВАЖНО**: Этот метод должен быть вызван перед любыми операциями
  /// с USB-принтером (печать, получение статуса и т.д.), иначе будет
  /// ошибка "USB permission denied".
  ///
  /// [usbParams] - параметры USB-устройства (vendorId, productId, serialNumber)
  ///
  /// Возвращает [UsbPermissionResult] с информацией о результате:
  /// - [granted] - true если разрешение получено
  /// - [errorMessage] - сообщение об ошибке (если не получено)
  /// - [deviceInfo] - информация об устройстве
  Future<UsbPermissionResult> requestUsbPermission(UsbParams usbParams) async {
    return api.requestUsbPermission(usbParams);
  }

  /// Проверяет, есть ли уже разрешение на использование USB-устройства.
  ///
  /// Этот метод **не показывает** диалог пользователю, только проверяет
  /// текущее состояние разрешения.
  ///
  /// [usbParams] - параметры USB-устройства
  ///
  /// Возвращает [UsbPermissionResult] с текущим состоянием разрешения.
  Future<UsbPermissionResult> hasUsbPermission(UsbParams usbParams) async {
    return api.hasUsbPermission(usbParams);
  }

  /// Удобный метод для работы с USB-принтером с автоматическим запросом разрешения.
  ///
  /// Проверяет разрешение, запрашивает его при необходимости, и выполняет
  /// переданную операцию только при успешном получении разрешения.
  ///
  /// [printer] - параметры подключения принтера
  /// [operation] - операция для выполнения после получения разрешения
  ///
  /// Выбрасывает [UsbPermissionDeniedException] если пользователь отказал в разрешении.
  /// Выбрасывает [ArgumentError] если принтер USB, но нет usbParams.
  Future<T> withUsbPermission<T>(
    PrinterConnectionParamsDTO printer,
    Future<T> Function() operation,
  ) async {
    return api.withUsbPermission(printer, operation);
  }

  // === Network Configuration ===

  /// Configure network settings via USB connection
  Future<void> setNetSettings(
    PrinterConnectionParamsDTO printer,
    NetworkParams netSettings,
  ) async {
    return api.setNetSettings(printer, netSettings);
  }

  /// Configure network settings via UDP broadcast
  Future<void> configureNetViaUDP(
    String macAddress,
    NetworkParams netSettings,
  ) async {
    // Note: The underlying API doesn't use macAddress parameter directly
    // but the method signature is kept for API compatibility as per README
    return api.configureNetViaUDP(macAddress, netSettings);
  }

  @override
  void dispose() {
    api.dispose();
    finder.dispose();
    super.dispose();
  }
}
