import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

class LabelPrinterSettings extends PrinterSettings {
  LabelPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
  });

  @override
  final IconData icon = Icons.sticky_note_2_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    languages: const [PrinterLanguage.zpl],
    connectionTypes: const [
      DiscoveryConnectionType.usb,
      DiscoveryConnectionType.tcp,
      DiscoveryConnectionType.sdk,
    ],
  );

  @override
  Map<String, dynamic> get extraSettingsToJson => {};
}

class LabelPrinterHandler extends PrinterProtocolHandler<LabelPrinterSettings> {
  LabelPrinterHandler({required super.settings, required super.manager});

  @override
  Future<bool> getStatus() async {
    if (settings.connectionParams == null) {
      return false;
    }
    final status = await manager.api.getZPLPrinterStatus(
      settings.connectionParams!,
    );
    return status.success;
  }

  @override
  Future<void> testPrint() async {
    final zpl = buildZplLabel(
      LabelData(
        itemName: 'Test item for print label test',
        unitAbr: 'kg',
        oldPrice: r'$250010.34',
        price: r'$250006.34',
        storeName: 'Test Store Name',
        date: '01/01/2025',
        qrText: '0000000000000000',
      ),
    );
    final result = await print(LabelPrintJob(zplRawString: zpl));
    if (!result.success) {
      throw Exception(result.message ?? 'Test print failed');
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
    if (job is! LabelPrintJob) {
      return PrintResult(success: false, message: 'Invalid job type');
    }
    final labelHTML = job.zplRawString;
    debugPrint('''Printing on Label Printer: $labelHTML''');
    final data = Uint8List.fromList(labelHTML.codeUnits);

    try {
      await manager.api.printZplRawData(settings.connectionParams!, data, 457);
    } catch (e) {
      debugPrint('Error printing label: $e');
      return PrintResult(success: false, message: e.toString());
    }
    return PrintResult(success: true);
  }

  @override
  List<Widget> get customWidgets => [];
}

class LabelPrintJob extends PrintJob {
  final String zplRawString;

  LabelPrintJob({required this.zplRawString});
}
