import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrintersManager with ChangeNotifier {
  final PosPrintersManager api = PosPrintersManager();
  final PrinterConfigRepository _repository;
  late final PrintersFinder finder = PrintersFinder(posPrintersManager: api);

  late final PrintersConnectionsHandler _connectionsHandler;

  List<PosPrinter> _printers = [];

  List<PosPrinter> get printers => List.unmodifiable(_printers);

  PrintersManager({PrinterConfigRepository? repository})
    : _repository = repository ?? SharedPrefsPrinterConfigRepository() {
    _connectionsHandler = PrintersConnectionsHandler(manager: this);
  }

  Future<void> init() async {
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
    _printers.add(PosPrinter(config: config, saveConfig: () => saveConfigs(), notify: () => notifyListeners()));
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
    for (var printer in _printers) {
      if (!printer.isConnected) {
        await printer.getStatus();
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    finder.dispose();
    _connectionsHandler.dispose();
    super.dispose();
  }
}
