import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

class AndroBarPrinterSettings extends PrinterSettings {
  AndroBarPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    required this.categoriesIds,
  });

  final PaperSize paperSize = PaperSize.mm80;

  final List<String> categoriesIds;

  @override
  final IconData icon = Icons.local_bar_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    languages: const [PrinterLanguage.esc],
    connectionTypes: const [DiscoveryConnectionType.tcp],
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

  @override
  List<Widget> get customWidgets => [
    categoriesIds.isNotEmpty
        ? Text('Categories: ${categoriesIds.join(', ')}')
        : const Text('No categories selected'),
    ElevatedButton(
      onPressed: () async {
        // Logic to select categories
        // This is just a placeholder for the actual implementation
        final newCategories = [
          'Category1',
          'Category2',
          'Category3',
          'Category4',
          'Category5',
          'Category6',
          'Category7',
          'Category8',
          'Category9',
        ];
        await updateCategoriesIds(Random().nextBool() ? newCategories : []);
      },
      child: const Text('Select Categories'),
    ),
  ];
}

class AndroBarPrinterHandler
    extends PrinterProtocolHandler<AndroBarPrinterSettings> {
  AndroBarPrinterHandler({required super.settings, required super.manager});

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
    await print(AndroBarPrintJob(data: buildEscTestPrintCommand("Test print")));
  }

  @override
  Future<PrintResult> print(PrintJob job) async {
    if (settings.connectionParams == null) {
      return PrintResult(
        success: false,
        message: 'Connection parameters are null',
      );
    }
    if (job is! AndroBarPrintJob) {
      return PrintResult(success: false, message: 'Invalid job type');
    }
    final dataForPrint = job.data;
    debugPrint('Printing on AndroBar Printer: $dataForPrint');
    try {
      await manager.api.printEscRawData(
        settings.connectionParams!,
        dataForPrint,
        settings.paperSize.value,
      );
    } catch (e) {
      debugPrint('Error printing AndroBar order: $e');
      return PrintResult(success: false, message: e.toString());
    }
    return PrintResult(success: true);
  }
}

class AndroBarPrintJob extends PrintJob {
  final Uint8List data;

  AndroBarPrintJob({required this.data});
}
