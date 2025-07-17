import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/src/plugins/category_for_printer.dart';

class PrintersManager with ChangeNotifier {
  final PosPrintersManager api = PosPrintersManager();
  final PrinterConfigRepository _repository;
  late final PrintersFinder finder = PrintersFinder(posPrintersManager: api);

  late final PrintersConnectionsHandler _connectionsHandler;

  late final Future<List<CategoryForPrinter>> getCategoriesForPrinters;

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
    : _repository = repository ?? SharedPrefsPrinterConfigRepository() {
    _connectionsHandler = PrintersConnectionsHandler(manager: this);
  }

  Future<void> init({
    required Future<List<CategoryForPrinter>> categoriesFuture,
  }) async {
    getCategoriesForPrinters = categoriesFuture;
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
    for (var printer in _printers) {
      await printer.getStatus();
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

  @override
  void dispose() {
    finder.dispose();
    _connectionsHandler.dispose();
    super.dispose();
  }
}
