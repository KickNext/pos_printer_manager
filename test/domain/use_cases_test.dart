/// Unit-тесты для Use Cases слоя.
///
/// Тесты проверяют корректность работы всех Use Cases,
/// включая валидацию параметров, обработку ошибок и
/// корректность возвращаемых результатов.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_printer_manager/src/core/result.dart';
import 'package:pos_printer_manager/src/domain/use_cases/add_printer_use_case.dart';
import 'package:pos_printer_manager/src/domain/use_cases/get_printer_use_case.dart';
import 'package:pos_printer_manager/src/domain/use_cases/remove_printer_use_case.dart';
import 'package:pos_printer_manager/src/domain/use_cases/update_printer_config_use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';
import 'package:pos_printer_manager/src/models/printer_config.dart';
import 'package:pos_printer_manager/src/plugins/printer_type.dart';

void main() {
  group('GetPrinterUseCase', () {
    late GetPrinterUseCase useCase;
    late List<_MockPosPrinter> printers;

    setUp(() {
      printers = [
        _MockPosPrinter(id: 'printer-1', name: 'Receipt Printer'),
        _MockPosPrinter(id: 'printer-2', name: 'Kitchen Printer'),
        _MockPosPrinter(id: 'printer-3', name: 'Label Printer'),
      ];

      useCase = GetPrinterUseCase(
        getPrinters: () => printers.cast<PosPrinter>(),
      );
    });

    test('возвращает принтер по существующему ID', () {
      final result = useCase('printer-2');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, equals('printer-2'));
    });

    test('возвращает Failure для несуществующего ID', () {
      final result = useCase('non-existent');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.notFound));
    });

    test('возвращает Failure для пустого ID', () {
      final result = useCase('');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });

    test('возвращает Failure для ID из пробелов', () {
      final result = useCase('   ');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });
  });

  group('RemovePrinterUseCase', () {
    late RemovePrinterUseCase useCase;
    late List<_MockPosPrinter> printers;
    late List<PrinterConfig> savedConfigs;

    setUp(() {
      printers = [
        _MockPosPrinter(id: 'printer-1', name: 'Printer 1'),
        _MockPosPrinter(id: 'printer-2', name: 'Printer 2'),
      ];
      savedConfigs = [];

      useCase = RemovePrinterUseCase(
        getPrinters: () => printers.cast<PosPrinter>(),
        removePrinter: (id) => printers.removeWhere((p) => p.id == id),
        saveConfigs: (configs) async => savedConfigs = configs,
      );
    });

    test('успешно удаляет существующий принтер', () async {
      final result = await useCase('printer-1');

      expect(result.isSuccess, isTrue);
      expect(printers.length, equals(1));
      expect(printers.first.id, equals('printer-2'));
    });

    test('сохраняет конфигурации после удаления', () async {
      await useCase('printer-1');

      expect(savedConfigs.length, equals(1));
      expect(savedConfigs.first.id, equals('printer-2'));
    });

    test('возвращает Failure для несуществующего принтера', () async {
      final result = await useCase('non-existent');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.notFound));
      expect(printers.length, equals(2)); // Ничего не удалено
    });

    test('возвращает Failure для пустого ID', () async {
      final result = await useCase('');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });
  });

  group('AddPrinterUseCase', () {
    late AddPrinterUseCase useCase;
    late List<PosPrinter> printers;

    setUp(() {
      printers = [];

      useCase = AddPrinterUseCase(
        printerFactory: _MockPrinterFactory(),
        getPrinters: () => printers,
        saveConfigs: (configs) async {},
      );
    });

    test('успешно добавляет новый принтер', () async {
      final params = AddPrinterParams(
        name: 'New Printer',
        type: PrinterPOSType.receiptPrinter,
      );

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.config.name, equals('New Printer'));
    });

    test('возвращает Failure для принтера с пустым именем', () async {
      final params = AddPrinterParams(
        name: '',
        type: PrinterPOSType.receiptPrinter,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });

    test('возвращает Failure для принтера с именем из пробелов', () async {
      final params = AddPrinterParams(
        name: '   ',
        type: PrinterPOSType.receiptPrinter,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });
  });

  group('UpdatePrinterConfigUseCase', () {
    late UpdatePrinterConfigUseCase useCase;
    late List<_MockPosPrinter> printers;
    late List<PrinterConfig> savedConfigs;

    setUp(() {
      printers = [_MockPosPrinter(id: 'printer-1', name: 'Original Name')];
      savedConfigs = [];

      useCase = UpdatePrinterConfigUseCase(
        getPrinters: () => printers.cast<PosPrinter>(),
        saveConfigs: (configs) async => savedConfigs = configs,
      );
    });

    test('успешно обновляет имя принтера', () async {
      final params = UpdatePrinterParams(
        printerId: 'printer-1',
        name: 'Updated Name',
      );

      final result = await useCase(params);

      // UseCase обновляет конфигурацию принтера и возвращает успех
      expect(result.isSuccess, isTrue);
      // Проверяем, что принтер найден и результат содержит конфигурацию
      expect(result.dataOrNull, isNotNull);
    });

    test('успешно обновляет настройки принтера', () async {
      final params = UpdatePrinterParams(
        printerId: 'printer-1',
        settings: {'copies': 2},
      );

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
    });

    test('сохраняет конфигурации после обновления', () async {
      final params = UpdatePrinterParams(
        printerId: 'printer-1',
        name: 'Updated Name',
      );

      await useCase(params);

      expect(savedConfigs.isNotEmpty, isTrue);
    });

    test('возвращает Failure для несуществующего принтера', () async {
      final params = UpdatePrinterParams(
        printerId: 'non-existent',
        name: 'New Name',
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.notFound));
    });

    test('возвращает Failure для пустого ID', () async {
      final params = UpdatePrinterParams(printerId: '', name: 'Name');

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });

    test('возвращает Failure для пустого имени', () async {
      final params = UpdatePrinterParams(printerId: 'printer-1', name: '');

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });

    test('возвращает Failure когда нечего обновлять', () async {
      final params = UpdatePrinterParams(printerId: 'printer-1');

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.validation));
    });
  });
}

/// Мок-класс для PosPrinter для тестирования.
///
/// Поддерживает изменяемую конфигурацию через [updateConfig].
class _MockPosPrinter implements PosPrinter {
  @override
  final String id;

  PrinterConfig _config;

  _MockPosPrinter({required this.id, required String name})
    : _config = PrinterConfig(
        id: id,
        name: name,
        printerPosType: PrinterPOSType.receiptPrinter,
        rawSettings: const {},
      );

  @override
  PrinterConfig get config => _config;

  @override
  void updateConfig(PrinterConfig newConfig) {
    assert(newConfig.id == id, 'Cannot change printer ID');
    _config = newConfig;
  }

  // Остальные методы не используются в тестах
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Мок-фабрика для создания принтеров.
class _MockPrinterFactory implements PrinterFactory {
  @override
  PosPrinter create(PrinterConfig config) {
    return _MockPosPrinter(id: config.id, name: config.name);
  }
}
