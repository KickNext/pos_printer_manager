/// Модуль заданий печати для различных типов принтеров.
///
/// Определяет базовый класс [PrintJob] и его конкретные реализации
/// для разных типов принтеров (чековые, кухонные, этикеточные).
///
/// ## Типы заданий:
///
/// - [ReceiptPrintJob] — печать HTML-чека на чековом принтере
/// - [KitchenPrintJob] — печать ESC/POS данных на кухонном принтере
/// - [LabelPrintJob] — печать этикетки на этикеточном принтере
///
/// ## Пример использования:
///
/// ```dart
/// // Печать чека
/// final job = ReceiptPrintJob(receiptHTML: '<h1>Receipt</h1>');
/// await printer.tryPrint(job);
///
/// // Печать кухонного заказа
/// final kitchenJob = KitchenPrintJob(
///   data: buildEscTestPrintCommand('Order #123'),
/// );
/// await kitchenPrinter.tryPrint(kitchenJob);
///
/// // Обработка с pattern matching
/// void processJob(PrintJob job) {
///   switch (job) {
///     case ReceiptPrintJob(:final receiptHTML):
///       print('Receipt: $receiptHTML');
///     case KitchenPrintJob(:final data):
///       print('Kitchen order: ${data.length} bytes');
///     case LabelPrintJob(:final labelData):
///       print('Label: ${labelData.itemName}');
///   }
/// }
/// ```
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Базовый sealed класс для заданий печати.
///
/// Использование sealed класса обеспечивает exhaustive pattern matching
/// в switch-выражениях — компилятор гарантирует обработку всех подтипов.
///
/// Каждый тип принтера использует свой подкласс [PrintJob]:
/// - Чековые принтеры: [ReceiptPrintJob]
/// - Кухонные принтеры: [KitchenPrintJob]
/// - Этикеточные принтеры: [LabelPrintJob]
@immutable
sealed class PrintJob {
  /// Создаёт задание печати.
  const PrintJob();

  /// Возвращает описание задания для логирования.
  String get description;
}

/// Задание на печать чека.
///
/// Содержит HTML-контент, который будет преобразован в ESC/POS команды
/// и напечатан на чековом принтере.
@immutable
final class ReceiptPrintJob extends PrintJob {
  /// HTML-контент чека для печати.
  ///
  /// Поддерживаются базовые HTML-теги: h1-h6, p, table, tr, td, img.
  final String receiptHTML;

  /// Создает задание на печать чека.
  ///
  /// [receiptHTML] — HTML-контент чека.
  const ReceiptPrintJob({required this.receiptHTML});

  @override
  String get description => 'ReceiptPrintJob(htmlLength: ${receiptHTML.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptPrintJob && receiptHTML == other.receiptHTML;

  @override
  int get hashCode => receiptHTML.hashCode;

  @override
  String toString() => description;
}

/// Задание на печать кухонного заказа.
///
/// Содержит raw ESC/POS данные, готовые для отправки на принтер.
/// Используется для печати заказов на кухонных принтерах.
@immutable
final class KitchenPrintJob extends PrintJob {
  /// Raw ESC/POS данные для печати.
  ///
  /// Данные должны быть уже сформированы в виде ESC/POS команд.
  /// Используйте [buildEscTestPrintCommand] для создания тестовых данных.
  final Uint8List data;

  /// Создает задание на печать кухонного заказа.
  ///
  /// [data] — raw ESC/POS данные.
  const KitchenPrintJob({required this.data});

  @override
  String get description => 'KitchenPrintJob(dataLength: ${data.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KitchenPrintJob && listEquals(data, other.data);

  @override
  int get hashCode => Object.hashAll(data);

  @override
  String toString() => description;
}

/// Задание на печать для AndroBar принтера.
///
/// Содержит raw ESC/POS данные для отправки на AndroBar.
/// Используется аналогично [KitchenPrintJob].
@immutable
final class AndroBarPrintJob extends PrintJob {
  /// Raw ESC/POS данные для печати.
  final Uint8List data;

  /// Создает задание на печать для AndroBar.
  ///
  /// [data] — raw ESC/POS данные.
  const AndroBarPrintJob({required this.data});

  @override
  String get description => 'AndroBarPrintJob(dataLength: ${data.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroBarPrintJob && listEquals(data, other.data);

  @override
  int get hashCode => Object.hashAll(data);

  @override
  String toString() => description;
}

/// Задание на печать этикетки.
///
/// Содержит данные для генерации этикетки в формате ZPL или TSPL.
@immutable
final class LabelPrintJob extends PrintJob {
  /// Данные для генерации этикетки.
  final LabelData labelData;

  /// Создает задание на печать этикетки.
  ///
  /// [labelData] — данные для этикетки.
  const LabelPrintJob({required this.labelData});

  @override
  String get description => 'LabelPrintJob(item: ${labelData.itemName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelPrintJob && labelData == other.labelData;

  @override
  int get hashCode => labelData.hashCode;

  @override
  String toString() => description;
}

/// Данные для генерации этикетки.
///
/// Содержит информацию о товаре для печати на этикетке.
@immutable
class LabelData {
  /// Название товара.
  final String itemName;

  /// Единица измерения (сокращённо).
  final String unitAbr;

  /// Старая цена (для акций).
  final String? oldPrice;

  /// Текущая цена.
  final String price;

  /// Название магазина.
  final String storeName;

  /// Дата (для ценника).
  final String date;

  /// Текст для QR-кода (обычно штрих-код товара).
  final String qrText;

  /// Создаёт данные для этикетки.
  const LabelData({
    required this.itemName,
    required this.unitAbr,
    this.oldPrice,
    required this.price,
    required this.storeName,
    required this.date,
    required this.qrText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelData &&
          itemName == other.itemName &&
          unitAbr == other.unitAbr &&
          oldPrice == other.oldPrice &&
          price == other.price &&
          storeName == other.storeName &&
          date == other.date &&
          qrText == other.qrText;

  @override
  int get hashCode => Object.hash(
    itemName, unitAbr, oldPrice, price, storeName, date, qrText,
  );

  @override
  String toString() => 'LabelData(item: $itemName, price: $price)';
}

/// Генерирует ESC/POS команды для тестовой печати.
///
/// [message] — текст сообщения для печати.
/// Возвращает [Uint8List] с ESC/POS командами.
///
/// ## Структура команд:
///
/// 1. ESC @ — инициализация принтера
/// 2. Текст сообщения в кодировке Latin-1
/// 3. LF — перевод строки
/// 4. GS V A 16 — частичный отрез бумаги
Uint8List buildEscTestPrintCommand(String message) {
  final esc = <int>[
    0x1B, 0x40, // ESC @ = инициализация принтера
  ];

  // Кодируем текст в Latin-1 (для кириллицы нужен cp866 или gbk)
  final textBytes = latin1.encode(message);
  esc.addAll(textBytes);

  esc.addAll([0x0A]); // LF — перевод строки
  esc.addAll([0x1D, 0x56, 0x41, 0x10]); // GS V A 16 — частичный отрез

  return Uint8List.fromList(esc);
}