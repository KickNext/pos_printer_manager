import 'dart:async';

import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrintersConnectionsHandler {
  PrintersConnectionsHandler({required PrintersManager manager})
    : _manager = manager {
    _initSync();
  }

  final PrintersManager _manager;

  PosPrintersManager get _api => _manager.api;

  StreamSubscription<PrinterConnectionEvent>? _connectionEventsSub;

  List<PosPrinter> get _savedPrinters => _manager.printers;

  void _initSync() {
    _connectionEventsSub = _api.connectionEvents.listen((event) {
      if (event.type == PrinterConnectionEventType.attached) {
        if (event.printer != null) {
          if (_savedPrinters.any(
            (printer) =>
                printer.handler.settings.connectionParams?.id ==
                event.printer?.id,
          )) {
            for (var printer in _savedPrinters) {
              if (printer.handler.settings.connectionParams?.id == event.id) {
                printer.updateStatus(true);
              }
            }
          }
          _manager.finder.addPrinter(event.printer!);
        }
      } else if (event.type == PrinterConnectionEventType.detached) {
        if (event.printer != null) {
          if (_savedPrinters.any(
            (printer) =>
                printer.handler.settings.connectionParams?.id ==
                event.printer?.id,
          )) {
            for (var printer in _savedPrinters) {
              if (printer.handler.settings.connectionParams?.id == event.id) {
                unawaited(printer.getStatus());
              }
            }
          }
          _manager.finder.removePrinter(event.printer!);
        }
      }
    });
  }

  void dispose() {
    _connectionEventsSub?.cancel();
    _connectionEventsSub = null;
  }
}
