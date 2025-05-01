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

  PrinterPOSType selectedPrinterType = PrinterPOSType.receiptPrinter;

  void back() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Printer Configuration'),
            TextField(
              decoration: InputDecoration(labelText: 'Printer Name'),
              controller: TextEditingController(text: printerName),
              onChanged: (value) {
                setState(() {
                  printerName = value;
                });
              },
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  PrinterPOSType.values.map((type) {
                    return ListTile(
                      title: Text(type.displayName),
                      leading: Radio<PrinterPOSType>(
                        value: type,
                        groupValue: selectedPrinterType,
                        onChanged: (PrinterPOSType? value) {
                          setState(() {
                            selectedPrinterType = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                if (printerName != null && printerName!.isNotEmpty) {
                  await widget.printerManager.addPosPrinter(
                    printerName ?? '',
                    selectedPrinterType,
                  );
                  back();
                }
              },
              child: Text('Add Printer'),
            ),
          ],
        ),
      ),
    );
  }
}
