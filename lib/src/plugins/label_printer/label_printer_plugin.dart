import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:flutter/foundation.dart';

/// Логгер для операций с этикеточным принтером.
final _logger = PrinterLogger.getLogger('LabelPrinter');

/// Настройки этикеточного принтера.
///
/// Определяет параметры подключения и язык команд
/// (ZPL или TSPL) для этикеточных принтеров.
class LabelPrinterSettings extends PrinterSettings {
  /// Создает настройки этикеточного принтера.
  LabelPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    LabelPrinterLanguage? language,
  }) : _language = language ?? LabelPrinterLanguage.zpl;

  LabelPrinterLanguage _language;

  /// Текущий язык команд принтера (ZPL или TSPL).
  LabelPrinterLanguage get language => _language;

  /// Устанавливает язык команд принтера.
  set language(LabelPrinterLanguage value) {
    _logger.info(
      'Changing printer language',
      data: {'from': _language.name, 'to': value.name},
    );
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

  /// Создает настройки из JSON-данных.
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
        _logger.warning(
          'Unknown language in config, defaulting to ZPL',
          data: {'value': json['language']},
        );
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

/// Обработчик протокола для этикеточного принтера.
///
/// Реализует печать этикеток через ZPL или TSPL команды
/// в зависимости от настроек.
class LabelPrinterHandler extends PrinterProtocolHandler<LabelPrinterSettings> {
  /// Создает обработчик этикеточного принтера.
  LabelPrinterHandler({required super.settings, required super.manager});

  @override
  Future<bool> getStatus() async {
    if (settings.connectionParams == null) {
      _logger.debug('Cannot get status: no connection params');
      return false;
    }

    // Используем соответствующий метод статуса в зависимости от языка
    if (settings.language == LabelPrinterLanguage.tspl) {
      final status = await manager.api.getTSPLPrinterStatus(
        settings.connectionParams!,
      );
      _logger.debug('TSPL printer status', data: {'success': status.success});
      return status.success;
    } else {
      final status = await manager.api.getZPLPrinterStatus(
        settings.connectionParams!,
      );
      _logger.debug('ZPL printer status', data: {'success': status.success});
      return status.success;
    }
  }

  @override
  Future<void> testPrint() async {
    _logger.info(
      'Starting test print',
      data: {'language': settings.language.displayName},
    );

    // Создаем тестовые данные этикетки
    final testData = LabelData(
      itemName: 'Test "item" for print label test',
      unitAbr: 'kg',
      oldPrice: r'$250010.34',
      price: r'$250006.34',
      storeName: 'Test Store Name',
      date: '01/01/2025',
      qrText: '0000000000000000',
    );

    final result = await print(LabelPrintJob(labelData: testData));
    if (!result.success) {
      _logger.warning('Test print failed', data: {'message': result.message});
      throw Exception(result.message ?? 'Test print failed');
    }
    _logger.info('Test print completed');
  }

  @override
  Future<PrintResult> print(PrintJob job) async {
    if (settings.connectionParams == null) {
      _logger.warning('Print failed: no connection params');
      return PrintResult(
        success: false,
        message: 'Connection parameters are null',
      );
    }
    if (job is! LabelPrintJob) {
      _logger.warning(
        'Print failed: invalid job type',
        data: {'type': job.runtimeType.toString()},
      );
      return PrintResult(success: false, message: 'Invalid job type');
    }

    // Генерируем команды в зависимости от языка
    final String labelCommands;
    if (settings.language == LabelPrinterLanguage.tspl) {
      labelCommands = buildTsplLabel(job.labelData);
    } else {
      labelCommands = buildZplLabel(job.labelData);
    }

    _logger.debug(
      'Printing label',
      data: {
        'language': settings.language.displayName,
        'commandsLength': labelCommands.length,
      },
    );
    final data = Uint8List.fromList(labelCommands.codeUnits);

    try {
      // Используем соответствующий метод печати в зависимости от языка
      if (settings.language == LabelPrinterLanguage.tspl) {
        // TSPL: 57mm width at 300 DPI = ~673 dots
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
      _logger.info('Label printed successfully');
      return PrintResult(success: true);
    } catch (e, st) {
      _logger.error('Error printing label', error: e, stackTrace: st);
      return PrintResult(success: false, message: e.toString());
    }
  }

  @override
  List<Widget> get customWidgets => [_LanguageSelector(settings: settings)];
}

/// Виджет выбора языка этикеточного принтера.
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
              children: LabelPrinterLanguage.values.map((lang) {
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

  /// Возвращает описание языка принтера.
  String _getLanguageDescription(LabelPrinterLanguage lang) {
    switch (lang) {
      case LabelPrinterLanguage.zpl:
        return 'Zebra Programming Language';
      case LabelPrinterLanguage.tspl:
        return 'TSC Printer Language';
    }
  }
}

// Примечание: LabelPrintJob теперь определён в protocol/print_job.dart
// и экспортируется через pos_printer_manager.dart
