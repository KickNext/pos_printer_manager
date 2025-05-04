import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class FindPrintersDialog extends StatefulWidget {
  const FindPrintersDialog({super.key, required this.printer});

  final PosPrinter printer;

  @override
  State<FindPrintersDialog> createState() => _FindPrintersDialogState();
}

class _FindPrintersDialogState extends State<FindPrintersDialog> {
  PrintersFinder get finder => widget.printer.handler.manager.finder;

  bool get isSearching => finder.isSearching;

  List<PrinterConnectionParamsDTO> get foundPrinters => finder.foundPrinters;

  @override
  void initState() {
    finder.addListener(_onPrintersChanged);
    finder.findPrinters(printer: widget.printer);
    super.initState();
  }

  void _onPrintersChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    finder.removeListener(_onPrintersChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Find Printers'),
            LinearProgressIndicator(
              value: isSearching ? null : 1,
              color: Colors.blue,
            ),
            SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                children: [
                  for (var dPrinter in foundPrinters)
                    DiscoveredPrinter(
                      discoveredPrinter: dPrinter,
                      onConnect: () async {
                        await widget.printer.handler.settings
                            .updateConnectionParams(dPrinter);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
