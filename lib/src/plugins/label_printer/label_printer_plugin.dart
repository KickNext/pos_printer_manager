import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

class LabelPrinterSettings extends PrinterSettings {
  LabelPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    LabelPrinterLanguage? language,
  }) : _language = language ?? LabelPrinterLanguage.zpl;

  LabelPrinterLanguage _language;

  /// Get current label printer language (ZPL or TSPL)
  LabelPrinterLanguage get language => _language;

  /// Set label printer language
  set language(LabelPrinterLanguage value) {
    _language = value;
    onSettingsChanged();
  }

  @override
  final IconData icon = Icons.sticky_note_2_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    connectionTypes: const [
      DiscoveryConnectionType.usb,
      DiscoveryConnectionType.tcp,
      DiscoveryConnectionType.sdk,
    ],
  );

  @override
  Map<String, dynamic> get extraSettingsToJson => {'language': _language.name};

  /// Create settings from JSON
  factory LabelPrinterSettings.fromJsonData(
    PrinterConnectionParamsDTO? connectionParams,
    Map<String, dynamic> json,
    Future<void> Function() onSettingsChanged,
  ) {
    LabelPrinterLanguage language = LabelPrinterLanguage.zpl;
    if (json['language'] != null) {
      try {
        language = LabelPrinterLanguage.values.byName(json['language']);
      } catch (_) {
        language = LabelPrinterLanguage.zpl;
      }
    }
    return LabelPrinterSettings(
      initConnectionParams: connectionParams,
      onSettingsChanged: onSettingsChanged,
      language: language,
    );
  }
}

class LabelPrinterHandler extends PrinterProtocolHandler<LabelPrinterSettings> {
  LabelPrinterHandler({required super.settings, required super.manager});

  @override
  Future<bool> getStatus() async {
    if (settings.connectionParams == null) {
      return false;
    }

    // Use appropriate status method based on language
    if (settings.language == LabelPrinterLanguage.tspl) {
      final status = await manager.api.getTSPLPrinterStatus(
        settings.connectionParams!,
      );
      return status.success;
    } else {
      final status = await manager.api.getZPLPrinterStatus(
        settings.connectionParams!,
      );
      return status.success;
    }
  }

  @override
  Future<void> testPrint() async {
    // Create test label data
    final testData = LabelData(
      itemName: 'Test item for print label test',
      unitAbr: 'kg',
      oldPrice: r'$250010.34',
      price: r'$250006.34',
      storeName: 'Test Store Name',
      date: '01/01/2025',
      qrText: '0000000000000000',
    );

    final result = await print(LabelPrintJob(labelData: testData));
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

    // Build label commands based on language
    final String labelCommands;
    if (settings.language == LabelPrinterLanguage.tspl) {
      labelCommands = buildTsplLabel(job.labelData);
    } else {
      labelCommands = buildZplLabel(job.labelData);
    }

    debugPrint(
      '''Printing on Label Printer (${settings.language.displayName}): $labelCommands''',
    );
    final data = Uint8List.fromList(labelCommands.codeUnits);

    try {
      // Use appropriate print method based on language
      if (settings.language == LabelPrinterLanguage.tspl) {
        // TSPL: 57mm width at 300 DPI = ~673 dots (with DIRECTION 1, height becomes width)
        await manager.api.printTsplRawData(
          settings.connectionParams!,
          data,
          673,
        );
      } else {
        // ZPL: 57mm width at 203 DPI = 457 dots
        await manager.api.printZplRawData(
          settings.connectionParams!,
          data,
          457,
        );
      }
    } catch (e) {
      debugPrint('Error printing label: $e');
      return PrintResult(success: false, message: e.toString());
    }
    return PrintResult(success: true);
  }

  @override
  List<Widget> get customWidgets => [_LanguageSelector(settings: settings)];
}

class _LanguageSelector extends StatelessWidget {
  final LabelPrinterSettings settings;

  const _LanguageSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Label Printer Language',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RadioGroup<LabelPrinterLanguage>(
            groupValue: settings.language,
            onChanged: (value) {
              if (value != null) {
                settings.language = value;
              }
            },
            child: Column(
              children:
                  LabelPrinterLanguage.values.map((lang) {
                    return InkWell(
                      onTap: () => settings.language = lang,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Radio<LabelPrinterLanguage>(value: lang),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _getLanguageDescription(lang),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageDescription(LabelPrinterLanguage lang) {
    switch (lang) {
      case LabelPrinterLanguage.zpl:
        return 'Zebra Programming Language';
      case LabelPrinterLanguage.tspl:
        return 'TSC Printer Language';
    }
  }
}

class LabelPrintJob extends PrintJob {
  final LabelData labelData;

  LabelPrintJob({required this.labelData});
}
