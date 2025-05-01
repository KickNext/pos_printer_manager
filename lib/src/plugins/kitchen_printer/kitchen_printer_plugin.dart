import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

class KitchenPrinterSettings extends PrinterSettings {
  KitchenPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
  });

  final PaperSize paperSize = PaperSize.mm80;

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

class KitchenPrinterHandler
    extends PrinterProtocolHandler<KitchenPrinterSettings> {
  KitchenPrinterHandler({required super.settings, required super.manager});

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
    await print(KitchenPrintJob(data: buildEscTestPrintCommand("Test print")));
  }

  @override
  Future<PrintResult> print(PrintJob job) async {
    if (settings.connectionParams == null) {
      return PrintResult(
        success: false,
        message: 'Connection parameters are null',
      );
    }
    if (job is! KitchenPrintJob) {
      return PrintResult(success: false, message: 'Invalid job type');
    }
    final dataForPrint = job.data;
    debugPrint('Printing on Kitchen Printer: $dataForPrint');
    try {
      await manager.api.printEscRawData(
        settings.connectionParams!,
        dataForPrint,
        settings.paperSize.value,
      );
    } catch (e) {
      debugPrint('Error printing kitchen order: $e');
      return PrintResult(success: false, message: e.toString());
    }
    return PrintResult(success: true);
  }
}

class KitchenPrintJob extends PrintJob {
  final Uint8List data;

  KitchenPrintJob({required this.data});
}
