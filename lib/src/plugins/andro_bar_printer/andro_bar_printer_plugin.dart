import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

class AndroBarPrinterSettings extends PrinterSettings {
  AndroBarPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    required this.categories,
  });

  final PaperSize paperSize = PaperSize.mm80;

  final List<CategoryForPrinter> categories;

  @override
  final IconData icon = Icons.local_bar_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    languages: const [PrinterLanguage.esc],
    connectionTypes: const [DiscoveryConnectionType.tcp],
  );

  Future<void> updateCategories(List<CategoryForPrinter> newCategories) async {
    if (identical(newCategories, categories)) {
      final snapshot = List<CategoryForPrinter>.from(newCategories);
      categories
        ..clear()
        ..addAll(snapshot);
    } else {
      categories
        ..clear()
        ..addAll(newCategories);
    }
    await onSettingsChanged();
  }

  @override
  Map<String, dynamic> get extraSettingsToJson => {
    'categories': categories.map((e) => e.toJson()).toList(),
  };
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
    final result = await print(
      AndroBarPrintJob(data: buildEscTestPrintCommand("Test print")),
    );
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

  @override
  List<Widget> get customWidgets => [
    SizedBox(
      width: 360,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          ...settings.categories.map(
            (category) => Chip(
              label: Text(category.displayName),
              color: WidgetStateProperty.all(category.color),
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCategories = await manager.getCategoriesForPrinter(
                currentCategories: settings.categories,
              );
              await settings.updateCategories(newCategories);
            },
            child: const Text('Update Categories'),
          ),
        ],
      ),
    ),
  ];
}

class AndroBarPrintJob extends PrintJob {
  final Uint8List data;

  AndroBarPrintJob({required this.data});
}
