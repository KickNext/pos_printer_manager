import 'dart:async';

import 'package:pos_printer_manager/pos_printer_manager.dart';

enum PrinterConnectionStatus {
  unknown,
  connected,
  error,
}

class PrinterError {
  final String message;
  final DateTime timestamp;
  final String? details;

  PrinterError({
    required this.message,
    required this.timestamp,
    this.details,
  });
}

class PosPrinter {
  PosPrinter({
    required this.config,
    required this.saveConfig,
    required this.notify,
  }) {
    _status = PrinterConnectionStatus.unknown;
  }

  String get id => config.id;
  final PrinterConfig config;

  PrinterPOSType get type => config.printerPosType;

  PrinterConnectionStatus _status = PrinterConnectionStatus.unknown;
  PrinterError? _lastError;

  PrinterConnectionStatus get status => _status;
  PrinterError? get lastError => _lastError;
  
  // Backward compatibility
  bool get isConnected => _status == PrinterConnectionStatus.connected;

  final Future<void> Function() saveConfig;

  final void Function() notify;

  late PrinterProtocolHandler handler = PrinterPluginRegistry.buildHandler(
    config,
  );

  /// Try to print and update status based on result
  Future<PrintResult> tryPrint(PrintJob job) async {
    try {
      final result = await handler.print(job);
      if (result.success) {
        _updateStatus(PrinterConnectionStatus.connected);
      } else {
        _updateError(result.message ?? 'Print failed');
      }
      return result;
    } catch (e) {
      _updateError(e.toString());
      return PrintResult(success: false, message: e.toString());
    }
  }

  /// Test print to check connection
  Future<void> testConnection() async {
    try {
      await handler.testPrint();
      _updateStatus(PrinterConnectionStatus.connected);
    } catch (e) {
      _updateError(e.toString());
    }
  }

  /// Legacy method - now just tests connection without real status monitoring
  Future<void> getStatus() async {
    await testConnection();
  }

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

  void clearError() {
    _lastError = null;
    _status = PrinterConnectionStatus.unknown;
    notify();
  }

  /// Legacy method for backward compatibility
  void updateStatus(bool status) {
    _updateStatus(status ? PrinterConnectionStatus.connected : PrinterConnectionStatus.error);
  }

  void updateName(String name) {
    config.name = name;
    unawaited(saveConfig());
  }
}
