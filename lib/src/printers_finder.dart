import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrintersFinder extends ChangeNotifier {
  PrintersFinder({required PosPrintersManager posPrintersManager})
    : _api = posPrintersManager;

  final PosPrintersManager _api;

  final List<PrinterConnectionParamsDTO> _foundPrinters = [];
  bool _isSearching = false;
  StreamSubscription<PrinterConnectionParamsDTO>? _searchSubscription;
  
  bool get isSearching => _isSearching;
  List<PrinterConnectionParamsDTO> get foundPrinters => _foundPrinters;

  /// Start searching for printers
  Future<void> findPrinters({required PosPrinter printer}) async {
    if (_isSearching) return;

    _isSearching = true;
    _foundPrinters.clear();
    notifyListeners();

    _searchSubscription?.cancel();

    try {
      final stream = _api.findPrinters(
        filter: printer.handler.settings.discoveryFilter,
      );
      _searchSubscription = stream.listen(
        (discoveredPrinter) {
          final exists = _foundPrinters.any(
            (p) => samePrinter(p, discoveredPrinter),
          );
          if (!exists) {
            _foundPrinters.add(discoveredPrinter);
            notifyListeners();
          }
        },
        onDone: () {
          _isSearching = false;
          notifyListeners();
          _searchSubscription = null;
        },
        onError: (err) {
          _searchSubscription = null;
        },
        cancelOnError: true,
      );
      _api.awaitDiscoveryComplete().catchError((e) {
        if (_isSearching) {
          _isSearching = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _isSearching = false;
      notifyListeners();
    }
  }

  void removePrinter(PrinterConnectionParamsDTO printer) {
    _foundPrinters.removeWhere((p) => samePrinter(p, printer));
    notifyListeners();
  }

  void addPrinter(PrinterConnectionParamsDTO printer) {
    final exists = _foundPrinters.any(
      (p) => samePrinter(p, printer),
    );
    if (!exists) {
      _foundPrinters.add(printer);
      notifyListeners();
    }
  }

  /// Compare printers by ID (usbPath or ip:port)
  bool samePrinter(PrinterConnectionParamsDTO a, PrinterConnectionParamsDTO b) {
    return a.id == b.id;
  }
}
