class LabelData {
  final String itemName;
  final String unitAbr;
  final String? oldPrice;
  final String price;
  final String storeName;
  final String date;
  final String qrText;

  const LabelData({
    required this.itemName,
    required this.unitAbr,
    required this.oldPrice,
    required this.price,
    required this.storeName,
    required this.date,
    required this.qrText,
  });
}

/// Основная функция-строитель для ZPL.
/// Возвращает готовую строку ^XA…^XZ
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

String buildTsplLabel(LabelData d) {
  // Размер этикетки: 2.25" x 1.25" (≈ 57 x 32 мм) при 203 dpi.
  // Координаты и размеры далее указаны в точках (dots).
  // Правый «столбец» — зона шириной 150 точек от правого края.
  const int labelWidthDots = 457; // 2.25" * 203 dpi ≈ 457
  const int rightColWidth = 150;
  final int rightColX = labelWidthDots - rightColWidth; // 307
  final int qrTextX = 280; // Сдвигаем QR текст чуть левее

  final oldPriceBlock =
      (d.oldPrice != null && d.oldPrice.toString().isNotEmpty)
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
QRCODE ${rightColX},35,L,5,A,0,"${d.qrText}"
TEXT 20,220,"2",0,1,1,"${d.storeName}"
TEXT $rightColX,220,"2",0,1,1,"${d.date}"
PRINT 1
''';
}
