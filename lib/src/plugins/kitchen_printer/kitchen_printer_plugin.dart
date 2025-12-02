import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Логгер для операций с кухонным принтером.
final _logger = PrinterLogger.getLogger('KitchenPrinter');

/// Настройки кухонного принтера.
///
/// Определяет параметры подключения, категории блюд
/// и формат печати для кухонных принтеров.
///
/// Категории доступны только для чтения через [categories].
/// Для изменения используйте [updateCategories].
class KitchenPrinterSettings extends PrinterSettings {
  /// Создает настройки кухонного принтера.
  KitchenPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    required List<CategoryForPrinter> categories,
  }) : _categories = List<CategoryForPrinter>.from(categories);

  /// Размер бумаги (по умолчанию 80мм).
  final PaperSize paperSize = PaperSize.mm80;

  /// Внутренний изменяемый список категорий.
  final List<CategoryForPrinter> _categories;

  /// Категории блюд, назначенные этому принтеру.
  ///
  /// Возвращает неизменяемое представление списка.
  /// Для изменения используйте [updateCategories].
  List<CategoryForPrinter> get categories => UnmodifiableListView(_categories);

  @override
  final IconData icon = Icons.soup_kitchen_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    connectionTypes: const [
      DiscoveryConnectionType.usb,
      DiscoveryConnectionType.tcp,
      DiscoveryConnectionType.sdk,
    ],
  );

  /// Обновляет список категорий для этого принтера.
  ///
  /// [newCategories] — новый список категорий для замены текущего.
  Future<void> updateCategories(List<CategoryForPrinter> newCategories) async {
    _logger.info(
      'Updating categories',
      data: {'oldCount': _categories.length, 'newCount': newCategories.length},
    );

    // Создаём копию нового списка для защиты от внешних изменений
    final newCategoriesCopy = List<CategoryForPrinter>.from(newCategories);

    _categories
      ..clear()
      ..addAll(newCategoriesCopy);

    await onSettingsChanged();

    _logger.debug('Categories updated', data: {'count': _categories.length});
  }

  @override
  Map<String, dynamic> get extraSettingsToJson => {
    'categories': _categories.map((e) => e.toJson()).toList(),
  };
}

/// Обработчик протокола для кухонного принтера.
///
/// Реализует печать заказов через ESC/POS raw-команды.
class KitchenPrinterHandler
    extends PrinterProtocolHandler<KitchenPrinterSettings> {
  /// Создает обработчик кухонного принтера.
  KitchenPrinterHandler({required super.settings, required super.manager});

  @override
  Future<bool> getStatus() async {
    if (settings.connectionParams == null) {
      _logger.debug('Cannot get status: no connection params');
      return false;
    }
    final status = await manager.api.getPrinterStatus(
      settings.connectionParams!,
    );
    _logger.debug('Printer status', data: {'success': status.success});
    return status.success;
  }

  @override
  Future<void> testPrint() async {
    _logger.info('Starting test print');
    final result = await print(
      KitchenPrintJob(data: buildEscTestPrintCommand("Test print")),
    );
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
    if (job is! KitchenPrintJob) {
      _logger.warning(
        'Print failed: invalid job type',
        data: {'type': job.runtimeType.toString()},
      );
      return PrintResult(success: false, message: 'Invalid job type');
    }

    final dataForPrint = job.data;
    _logger.debug(
      'Printing kitchen order',
      data: {'dataLength': dataForPrint.length},
    );

    try {
      await manager.api.printEscRawData(
        settings.connectionParams!,
        dataForPrint,
        settings.paperSize.value,
      );
      _logger.info('Kitchen order printed successfully');
      return PrintResult(success: true);
    } catch (e, st) {
      _logger.error('Error printing kitchen order', error: e, stackTrace: st);
      return PrintResult(success: false, message: e.toString());
    }
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

// Примечание: KitchenPrintJob теперь определён в protocol/print_job.dart
// и экспортируется через pos_printer_manager.dart
