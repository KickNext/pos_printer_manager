import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

class KitchenPrinterSettings extends PrinterSettings {
  KitchenPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    required this.categoriesIds,
  });

  final PaperSize paperSize = PaperSize.mm80;

  final List<String> categoriesIds;
  
  @override
  final IconData icon = Icons.soup_kitchen_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    languages: const [PrinterLanguage.esc],
    connectionTypes: const [
      DiscoveryConnectionType.usb,
      DiscoveryConnectionType.tcp,
      DiscoveryConnectionType.sdk,
    ],
  );

  Future<void> updateCategoriesIds(List<String> newCategoriesIds) async {
    categoriesIds.clear();
    categoriesIds.addAll(newCategoriesIds);
    await onSettingsChanged();
  }

  @override
  Map<String, dynamic> get extraSettingsToJson => {
    'categoriesIds': categoriesIds,
  };
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
