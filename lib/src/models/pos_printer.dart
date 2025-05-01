import 'dart:async';

import 'package:pos_printer_manager/pos_printer_manager.dart';

class PosPrinter {
  PosPrinter({
    required this.config,
    required this.saveConfig,
    required this.notify,
  }) {
    _isConnected = false;
  }

  String get id => config.id;
  final PrinterConfig config;

  PrinterPOSType get type => config.printerPosType;

  bool? _isConnected;

  bool get isConnected => _isConnected ?? false;

  final Future<void> Function() saveConfig;

  final void Function() notify;

  late PrinterProtocolHandler handler = PrinterPluginRegistry.buildHandler(
    config,
  );

  Future<void> getStatus() async {
    updateStatus(await handler.getStatus());
  }

  void updateStatus(bool status) {
    _isConnected = status;
    notify();
  }

  void updateName(String name) {
    config.name = name;
    unawaited(saveConfig());
  }
}
