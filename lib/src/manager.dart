import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrintersManager with ChangeNotifier {
  final PosPrintersManager api = PosPrintersManager();
  final PrinterConfigRepository _repository;
  late final PrintersFinder finder = PrintersFinder(posPrintersManager: api);

  late final Future<List<CategoryForPrinter>> Function({
    required List<CategoryForPrinter> currentCategories,
  })
  getCategoriesForPrinter;

  final int maxReceiptPrinters = 1;
  final int maxKitchenPrinters = 9999;
  final int maxLabelPrinters = 1;
  final int maxAndroBarPrinters = 1;

  bool get canAddPrinter {
    if (printers.isEmpty) {
      return true;
    }
    final receiptPrinters =
        printers
            .where((printer) => printer.type == PrinterPOSType.receiptPrinter)
            .length;
    final kitchenPrinters =
        printers
            .where((printer) => printer.type == PrinterPOSType.kitchenPrinter)
            .length;
    final labelPrinters =
        printers
            .where((printer) => printer.type == PrinterPOSType.labelPrinter)
            .length;

    // Отладочный вывод
    debugPrint(
      'Receipt Printers: $receiptPrinters, Kitchen Printers: $kitchenPrinters, Label Printers: $labelPrinters',
    );

    return receiptPrinters < maxReceiptPrinters ||
        kitchenPrinters < maxKitchenPrinters ||
        labelPrinters < maxLabelPrinters;
  }

  List<PosPrinter> _printers = [];

  List<PosPrinter> get printers => List.unmodifiable(_printers);

  PrintersManager({PrinterConfigRepository? repository})
    : _repository = repository ?? SharedPrefsPrinterConfigRepository();

  Future<void> init({
    required Future<List<CategoryForPrinter>> Function({
      required List<CategoryForPrinter> currentCategories,
    })
    getCategoriesFunction,
  }) async {
    getCategoriesForPrinter = getCategoriesFunction;
    PrinterPOSType.registerPrinterTypes(this);
    final configs = await _repository.loadConfigs();
    _printers =
        configs.map((config) {
          return PosPrinter(
            config: config,
            saveConfig: () => saveConfigs(),
            notify: () => notifyListeners(),
          );
        }).toList();
    // Default all printers to connected on init (no I/O), per new logic.
    for (var printer in _printers) {
      printer.updateStatus(true);
    }
  }

  Future<void> addPosPrinter(String name, PrinterPOSType type) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
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
    notifyListeners();
  }

  /// Add printer (alias for backward compatibility)
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

  /// Update printer configuration
  Future<void> updatePrinterConfig(PrinterConfig updatedConfig) async {
    final index = _printers.indexWhere((p) => p.id == updatedConfig.id);
    if (index != -1) {
      _printers[index].config.name = updatedConfig.name;
      _printers[index].config.rawSettings.clear();
      _printers[index].config.rawSettings.addAll(updatedConfig.rawSettings);
      await saveConfigs();
      notifyListeners();
    }
  }

  /// Remove printer (alias for backward compatibility)
  Future<void> removePrinter(String id) async {
    await removePosPrinter(id);
  }

  /// Print using specific printer
  Future<PrintResult> print(String printerId, PrintJob job) async {
    final printer = _printers.firstWhere((p) => p.id == printerId);
    return await printer.tryPrint(job);
  }

  /// Retry connection to printer
  Future<void> retryConnection(String printerId) async {
    final printer = _printers.firstWhere((p) => p.id == printerId);
    await printer.testConnection();
  }

  Future<void> removePosPrinter(String id) async {
    _printers.removeWhere((printer) => printer.id == id);
    await saveConfigs();
    notifyListeners();
  }

  Future<void> saveConfigs() async {
    for (var printer in _printers) {
      printer.config.rawSettings
        ..clear()
        ..addAll(printer.handler.settings.toJson());
    }
    await _repository.saveConfigs(
      _printers.map((e) {
        return e.config;
      }).toList(),
    );
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
    int width,
  ) async {
    return api.printEscHTML(printer, html, width);
  }

  /// Print raw ESC/POS commands
  Future<void> printEscRawData(
    PrinterConnectionParamsDTO printer,
    Uint8List data,
    int width,
  ) async {
    return api.printEscRawData(printer, data, width);
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
