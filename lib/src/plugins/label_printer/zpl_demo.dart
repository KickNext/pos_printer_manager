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

/// Основная функция-строитель.
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
