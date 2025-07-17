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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Find Printers',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: isSearching ? null : 1,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            isSearching
                                ? null
                                : () {
                                  finder.findPrinters(printer: widget.printer);
                                },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
