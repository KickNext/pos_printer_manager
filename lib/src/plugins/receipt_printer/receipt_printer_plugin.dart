import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class ReceiptPrinterSettings extends PrinterSettings {
  ReceiptPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
  });

  final PaperSize paperSize = PaperSize.mm80;

  @override
  final IconData icon = Icons.receipt_long_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    languages: const [PrinterLanguage.esc],
    connectionTypes: const [
      DiscoveryConnectionType.usb,
      DiscoveryConnectionType.tcp,
      DiscoveryConnectionType.sdk,
    ],
  );

  @override
  Map<String, dynamic> get extraSettingsToJson => {};
}

class ReceiptPrinterHandler
    extends PrinterProtocolHandler<ReceiptPrinterSettings> {
  ReceiptPrinterHandler({required super.settings, required super.manager});

  @override
  Future<bool> getStatus() async {
    if (settings.connectionParams == null) {
      return false;
    }
    final status = await manager.api.getPrinterStatus(
      settings.connectionParams!,
    );
    return status.success;
  }

  @override
  Future<void> testPrint() async {
    final result = await print(
      ReceiptPrintJob(receiptHTML: '<h1>Test print</h1>'),
    );
    if (!result.success) {
      throw Exception(result.message ?? 'Test print failed');
    }
  }

  Future<void> openCashDrawer() async {
    if (settings.connectionParams == null) {
      return;
    }
    try {
      await manager.api.openCashBox(settings.connectionParams!);
    } catch (e) {
      debugPrint('Error opening cash drawer: $e');
    }
  }

  @override
  Future<PrintResult> print(PrintJob job) async {
    if (settings.connectionParams == null) {
      return PrintResult(
        success: false,
        message: 'Connection parameters are null',
      );
    }
    if (job is! ReceiptPrintJob) {
      return PrintResult(success: false, message: 'Invalid job type');
    }
    final receiptHTML = job.receiptHTML;
    debugPrint('Printing on Receipt Printer: $receiptHTML');
    try {
      await manager.api.printEscHTML(
        settings.connectionParams!,
        receiptHTML,
        settings.paperSize.value,
      );
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      return PrintResult(success: false, message: e.toString());
    }
    return PrintResult(success: true);
  }

  @override
  List<Widget> get customWidgets => [];
}

class ReceiptPrintJob extends PrintJob {
  final String receiptHTML;

  ReceiptPrintJob({required this.receiptHTML});
}
