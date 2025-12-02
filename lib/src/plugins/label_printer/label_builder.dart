/// Функции генерации команд ZPL и TSPL для этикеточных принтеров.
///
/// Этот модуль содержит билдеры для генерации команд печати этикеток
/// в форматах ZPL (Zebra Programming Language) и TSPL (TSC Printer Language).
///
/// ## Пример использования:
///
/// ```dart
/// final labelData = LabelData(
///   itemName: 'Product Name',
///   unitAbr: 'kg',
///   price: '\$10.99',
///   storeName: 'My Store',
///   date: '2025-01-01',
///   qrText: '1234567890123',
/// );
///
/// // Для ZPL принтера
/// final zplCommands = buildZplLabel(labelData);
///
/// // Для TSPL принтера
/// final tsplCommands = buildTsplLabel(labelData);
/// ```
library;

import 'package:pos_printer_manager/src/protocol/print_job.dart';

// LabelData теперь определён в protocol/print_job.dart
// и экспортируется через pos_printer_manager.dart

/// Строит ZPL-команды для печати этикетки.
///
/// [d] — данные для этикетки.
/// Возвращает готовую строку команд ZPL (^XA…^XZ).
///
/// ## Формат этикетки:
///
/// - Ширина: 457 точек (2.25" при 203 dpi)
/// - Название товара: до 3 строк, шрифт CF0,32
/// - Старая цена (если есть): зачёркнутая
/// - Текущая цена с единицей измерения
/// - QR-код в правом верхнем углу
/// - Название магазина и дата внизу
String buildZplLabel(LabelData d) {
  return '''
^XA
^PW457
^CF0,32
^FO20,20,0
^FB250,3,0,L,0^FD${d.itemName}^FS
${d.oldPrice != null ? '''
^CF0,30,30
^FO20,130^FD${d.oldPrice}^FS
^FO20,140^GB200,3,3^FS''' : ''}
^CF0,50,50
^FO20,160,0^FD${d.price} /${d.unitAbr}^FS
^FO437,20,1
^CF0,14
^FB150,1,0,R,0^FD${d.qrText}^FS
^FO437,35,1
^BQN,2,5,L
^FDLA,${d.qrText}^FS
^CF0,20
^FO20,220^FD${d.storeName}^FS
^FO437,220,1
^FB150,1,0,R,0^FD${d.date}^FS
^XZ
''';
}

/// Строит TSPL-команды для печати этикетки.
///
/// [d] — данные для этикетки.
/// Возвращает готовую строку команд TSPL.
///
/// ## Формат этикетки:
///
/// - Размер: 57 x 32 мм при 203 dpi
/// - GAP: 2 мм
/// - Название товара: до 3 строк
/// - Старая цена (если есть): зачёркнутая
/// - Текущая цена с единицей измерения
/// - QR-код в правом верхнем углу
/// - Название магазина и дата внизу
String buildTsplLabel(LabelData d) {
  // Размер этикетки: 2.25" x 1.25" (≈ 57 x 32 мм) при 203 dpi.
  // Координаты и размеры указаны в точках (dots).
  // Правый «столбец» — зона шириной 150 точек от правого края.
  const int labelWidthDots = 457; // 2.25" * 203 dpi ≈ 457
  const int rightColWidth = 150;
  final int rightColX = labelWidthDots - rightColWidth; // 307
  final int qrTextX = 280; // Сдвигаем QR текст чуть левее

  final oldPriceBlock = (d.oldPrice != null && d.oldPrice.toString().isNotEmpty)
      ? '''
TEXT 20,130,"2",0,1,1,"${d.oldPrice}"
BAR 20,136,200,3
'''
      : '';

  return '''
SIZE 57 mm, 32 mm
GAP 2 mm,0
DIRECTION 1
CLS
BLOCK 20,20,250,96,"3",0,1,1,"${d.itemName}"
$oldPriceBlock
TEXT 20,160,"4",0,1,1,"${d.price} /${d.unitAbr}"
TEXT $qrTextX,20,"1",0,1,1,"${d.qrText}"
QRCODE $rightColX,35,L,5,A,0,"${d.qrText}"
TEXT 20,220,"2",0,1,1,"${d.storeName}"
TEXT $rightColX,220,"2",0,1,1,"${d.date}"
PRINT 1
''';
}
