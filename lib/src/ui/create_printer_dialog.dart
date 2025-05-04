import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class CreatePrinterDialog extends StatefulWidget {
  const CreatePrinterDialog({super.key, required this.printerManager});

  final PrintersManager printerManager;

  @override
  State<CreatePrinterDialog> createState() => _CreatePrinterDialogState();
}

class _CreatePrinterDialogState extends State<CreatePrinterDialog> {
  late String? printerName =
      'Printer ${widget.printerManager.printers.length + 1}';

  PrinterPOSType? selectedPrinterType;

  void back() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Text(
                      'Add printer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SegmentedButton<PrinterPOSType>(
                      emptySelectionAllowed: true,
                      segments: <ButtonSegment<PrinterPOSType>>[
                        ButtonSegment<PrinterPOSType>(
                          value: PrinterPOSType.receiptPrinter,
                          label: Text('Receipt printer'),
                          icon: Icon(Icons.receipt_long_rounded),
                          enabled:
                              widget.printerManager.maxReceiptPrinters >
                              widget.printerManager.printers
                                  .where(
                                    (p) =>
                                        p.type == PrinterPOSType.receiptPrinter,
                                  )
                                  .length,
                        ),
                        ButtonSegment<PrinterPOSType>(
                          value: PrinterPOSType.kitchenPrinter,
                          label: Text('Kitchen printer'),
                          icon: Icon(Icons.soup_kitchen_rounded),
                          enabled:
                              widget.printerManager.maxKitchenPrinters >
                              widget.printerManager.printers
                                  .where(
                                    (p) =>
                                        p.type == PrinterPOSType.kitchenPrinter,
                                  )
                                  .length,
                        ),
                        ButtonSegment<PrinterPOSType>(
                          value: PrinterPOSType.labelPrinter,
                          label: Text('Label printer'),
                          icon: Icon(Icons.sticky_note_2_rounded),
                          enabled:
                              widget.printerManager.maxLabelPrinters >
                              widget.printerManager.printers
                                  .where(
                                    (p) =>
                                        p.type == PrinterPOSType.labelPrinter,
                                  )
                                  .length,
                        ),
                      ],
                      selected:
                          selectedPrinterType != null
                              ? <PrinterPOSType>{selectedPrinterType!}
                              : <PrinterPOSType>{},
                      onSelectionChanged: (Set<PrinterPOSType> newSelection) {
                        setState(() {
                          // By default there is only a single segment that can be
                          // selected at one time, so its value is always the first
                          // item in the selected set.
                          selectedPrinterType = newSelection.first;
                        });
                      },
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Printer Name'),
                        controller: TextEditingController(text: printerName),
                        onChanged: (value) {
                          setState(() {
                            printerName = value;
                          });
                        },
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed:
                          printerName != null &&
                                  printerName!.isNotEmpty &&
                                  selectedPrinterType != null
                              ? () async {
                                await widget.printerManager.addPosPrinter(
                                  printerName ?? '',
                                  selectedPrinterType!,
                                );
                                back();
                              }
                              : null,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add printer'),
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
                  back();
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
