import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrintersPage extends StatefulWidget {
  const PrintersPage({required this.printerManager, super.key});

  final PrintersManager printerManager;

  @override
  State<PrintersPage> createState() => _PrintersPageState();
}

class _PrintersPageState extends State<PrintersPage> {
  @override
  void initState() {
    widget.printerManager.addListener(update);
    super.initState();
  }

  void update() {
    setState(() {});
  }

  Future<void> onAddPrinter() async {
    await showDialog(
      context: context,
      builder:
          (context) =>
              CreatePrinterDialog(printerManager: widget.printerManager),
    );
    setState(() {});
  }

  Future<void> toPrinterDetails(PosPrinter printer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrinterDetailsScreen(printer: printer),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    widget.printerManager.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.printerManager.canAddPrinter)
              IconButton.filledTonal(
                onPressed: onAddPrinter,
                icon: const Icon(Icons.add),
                tooltip: 'Add Printer',
              ),
            ...widget.printerManager.printers.map(
              (p) => PrinterCard(printer: p, onTap: toPrinterDetails),
            ),
          ],
        ),
      ),
    );
  }
}
