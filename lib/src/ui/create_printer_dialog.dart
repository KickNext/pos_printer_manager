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
                  children: [
                    Text(
                      'Add printer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    // Пояснение для выбора типа принтера
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Please select the printer type:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    // Адаптивная сетка выбора типа принтера через Wrap (2 колонки, без фиксированных размеров)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildPrinterTypeChip(
                          type: PrinterPOSType.receiptPrinter,
                          label: 'Receipt printer',
                          icon: Icons.receipt_long_rounded,
                          enabled:
                              widget.printerManager.maxReceiptPrinters >
                              widget.printerManager.printers
                                  .where(
                                    (p) =>
                                        p.type == PrinterPOSType.receiptPrinter,
                                  )
                                  .length,
                        ),
                        _buildPrinterTypeChip(
                          type: PrinterPOSType.kitchenPrinter,
                          label: 'Kitchen printer',
                          icon: Icons.soup_kitchen_rounded,
                          enabled:
                              widget.printerManager.maxKitchenPrinters >
                              widget.printerManager.printers
                                  .where(
                                    (p) =>
                                        p.type == PrinterPOSType.kitchenPrinter,
                                  )
                                  .length,
                        ),
                        _buildPrinterTypeChip(
                          type: PrinterPOSType.labelPrinter,
                          label: 'Label printer',
                          icon: Icons.sticky_note_2_rounded,
                          enabled:
                              widget.printerManager.maxLabelPrinters >
                              widget.printerManager.printers
                                  .where(
                                    (p) =>
                                        p.type == PrinterPOSType.labelPrinter,
                                  )
                                  .length,
                        ),
                        _buildPrinterTypeChip(
                          type: PrinterPOSType.androBar,
                          label: 'AndroBar',
                          icon: Icons.local_bar_rounded,
                          enabled:
                              true, // Можно добавить ограничение по аналогии, если потребуется
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    ElevatedButton(
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
                      child: const Text('Add printer'),
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

  Widget _buildPrinterTypeChip({
    required PrinterPOSType type,
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      ),
      selected: selectedPrinterType == type,
      onSelected:
          enabled
              ? (selected) {
                setState(() {
                  selectedPrinterType = selected ? type : null;
                });
              }
              : null,
      selectedColor: Theme.of(context).colorScheme.primary,
      disabledColor: Colors.grey.shade300,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color:
            enabled
                ? (selectedPrinterType == type ? Colors.white : Colors.black87)
                : Colors.grey,
      ),
      avatar: null,
      showCheckmark: false,
      elevation: 2,
    );
  }
}
