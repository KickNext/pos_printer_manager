import 'dart:convert';

import 'package:flutter/foundation.dart';

abstract class PrintJob {}

Uint8List buildEscTestPrintCommand(String message) {
  final esc = <int>[
    0x1B, 0x40, // ESC @ = инициализация
  ];

  final textBytes = latin1.encode(message); // или cp866/gbk если надо
  esc.addAll(textBytes);

  esc.addAll([0x0A]); // перевод строки
  esc.addAll([0x1D, 0x56, 0x41, 0x10]); // частичный отрез (режет бумагу)

  return Uint8List.fromList(esc);
}