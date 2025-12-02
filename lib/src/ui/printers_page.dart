import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Main page for displaying and managing printers.
///
/// Shows a list of configured printers with the ability to add new printers
/// and navigate to printer details for configuration.
class PrintersPage extends StatefulWidget {
  /// Creates a printers page widget.
  const PrintersPage({required this.printerManager, super.key});

  /// The printer manager instance for accessing printers.
  final PrintersManager printerManager;

  @override
  State<PrintersPage> createState() => _PrintersPageState();
}

class _PrintersPageState extends State<PrintersPage> {
  @override
  void initState() {
    super.initState();
    widget.printerManager.addListener(_update);
  }

  /// Rebuilds the UI when printer manager state changes.
  void _update() {
    setState(() {});
  }

  /// Opens the printer setup wizard dialog.
  Future<void> _onAddPrinter() async {
    final newPrinter = await showDialog<PosPrinter>(
      context: context,
      builder: (context) => PrinterSetupWizard(
        printerManager: widget.printerManager,
        onComplete: (printer) => Navigator.of(context).pop(printer),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );

    // If a printer was created, navigate to its details
    if (newPrinter != null && mounted) {
      await _navigateToPrinterDetails(newPrinter);
    }
  }

  /// Navigates to printer details screen.
  Future<void> _navigateToPrinterDetails(PosPrinter printer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrinterDetailsScreen(printer: printer),
      ),
    );
    // Refresh state after returning from details
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.printerManager.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PrinterListOrganism(
          printerManager: widget.printerManager,
          onPrinterTap: _navigateToPrinterDetails,
          onAddPrinter: widget.printerManager.canAddPrinterOfType()
              ? _onAddPrinter
              : null,
        ),
      ),
    );
  }
}
