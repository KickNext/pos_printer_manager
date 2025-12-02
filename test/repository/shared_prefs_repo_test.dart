/// Unit-тесты для [PrinterConfigRepository] и [SharedPrefsPrinterConfigRepository].
///
/// Проверяют корректность работы CRUD операций репозитория
/// конфигураций принтеров.
///
/// Примечание: Тесты для SharedPrefsPrinterConfigRepository требуют
/// инициализации асинхронной платформы SharedPreferences, что сложно
/// настроить в unit-тестах. Поэтому тесты репозитория помечены как
/// @Tags(['integration']) и должны запускаться отдельно.
///
/// Для запуска: flutter test --tags integration
@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  group('SharedPrefsPrinterConfigRepository', () {
    late SharedPrefsPrinterConfigRepository repository;

    /// Создает тестовую конфигурацию принтера.
    PrinterConfig createConfig({
      String? id,
      String name = 'Test Printer',
      PrinterPOSType printerPosType = PrinterPOSType.receiptPrinter,
      Map<String, dynamic>? rawSettings,
    }) {
      return PrinterConfig(
        id: id ?? IdGenerator.generate(),
        name: name,
        printerPosType: printerPosType,
        rawSettings: rawSettings ?? {
          'address': '192.168.1.100',
          'port': 9100,
        },
      );
    }

    setUp(() async {
      // Инициализируем in-memory SharedPreferences для асинхронного API
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      repository = SharedPrefsPrinterConfigRepository();
    });

    group('loadConfigs', () {
      test('возвращает пустой список для пустого хранилища', () async {
        final configs = await repository.loadConfigs();

        expect(configs, isEmpty);
      });

      test('возвращает сохраненные конфигурации', () async {
        final config1 = createConfig(name: 'Printer 1');
        final config2 = createConfig(name: 'Printer 2');
        await repository.saveConfigs([config1, config2]);

        final configs = await repository.loadConfigs();

        expect(configs.length, equals(2));
        expect(configs.map((c) => c.name), containsAll(['Printer 1', 'Printer 2']));
      });
    });

    group('saveConfigs', () {
      test('сохраняет список конфигураций', () async {
        final configs = [
          createConfig(name: 'Printer 1'),
          createConfig(name: 'Printer 2'),
        ];

        await repository.saveConfigs(configs);
        final loaded = await repository.loadConfigs();

        expect(loaded.length, equals(2));
      });

      test('перезаписывает существующие данные', () async {
        await repository.saveConfigs([createConfig(name: 'Old Printer')]);
        await repository.saveConfigs([createConfig(name: 'New Printer')]);

        final loaded = await repository.loadConfigs();

        expect(loaded.length, equals(1));
        expect(loaded.first.name, equals('New Printer'));
      });
    });

    group('findById', () {
      test('находит существующую конфигурацию', () async {
        final config = createConfig(id: 'test-id-123');
        await repository.saveConfigs([config]);

        final found = await repository.findById('test-id-123');

        expect(found, isNotNull);
        expect(found!.id, equals('test-id-123'));
      });

      test('возвращает null для несуществующего ID', () async {
        await repository.saveConfigs([createConfig()]);

        final found = await repository.findById('non-existent-id');

        expect(found, isNull);
      });
    });

    group('deleteById', () {
      test('удаляет конфигурацию по ID', () async {
        final config1 = createConfig(id: 'id-1', name: 'Printer 1');
        final config2 = createConfig(id: 'id-2', name: 'Printer 2');
        await repository.saveConfigs([config1, config2]);

        final result = await repository.deleteById('id-1');

        expect(result, isTrue);
        final remaining = await repository.loadConfigs();
        expect(remaining.length, equals(1));
        expect(remaining.first.name, equals('Printer 2'));
      });

      test('возвращает false для несуществующего ID', () async {
        await repository.saveConfigs([createConfig()]);

        final result = await repository.deleteById('non-existent-id');

        expect(result, isFalse);
      });
    });

    group('upsert', () {
      test('добавляет новую конфигурацию', () async {
        final config = createConfig(id: 'new-id', name: 'New Printer');

        await repository.upsert(config);

        final loaded = await repository.loadConfigs();
        expect(loaded.length, equals(1));
        expect(loaded.first.name, equals('New Printer'));
      });

      test('обновляет существующую конфигурацию', () async {
        final config = createConfig(id: 'existing-id', name: 'Original Name');
        await repository.saveConfigs([config]);

        final updated = PrinterConfig(
          id: 'existing-id',
          name: 'Updated Name',
          printerPosType: PrinterPOSType.receiptPrinter,
          rawSettings: {'address': '192.168.1.200', 'port': 9200},
        );
        await repository.upsert(updated);

        final loaded = await repository.loadConfigs();
        expect(loaded.length, equals(1));
        expect(loaded.first.name, equals('Updated Name'));
        expect(loaded.first.rawSettings['address'], equals('192.168.1.200'));
      });
    });

    group('exists', () {
      test('возвращает true для существующей конфигурации', () async {
        final config = createConfig(id: 'existing-id');
        await repository.saveConfigs([config]);

        final result = await repository.exists('existing-id');

        expect(result, isTrue);
      });

      test('возвращает false для несуществующей конфигурации', () async {
        final result = await repository.exists('non-existent-id');

        expect(result, isFalse);
      });
    });

    group('count', () {
      test('возвращает 0 для пустого репозитория', () async {
        final result = await repository.count();

        expect(result, equals(0));
      });

      test('возвращает правильное количество', () async {
        await repository.saveConfigs([
          createConfig(),
          createConfig(),
          createConfig(),
        ]);

        final result = await repository.count();

        expect(result, equals(3));
      });
    });

    group('clear', () {
      test('удаляет все конфигурации', () async {
        await repository.saveConfigs([
          createConfig(),
          createConfig(),
        ]);

        await repository.clear();

        final loaded = await repository.loadConfigs();
        expect(loaded, isEmpty);
      });

      test('безопасно вызывается на пустом репозитории', () async {
        // Не должно выбрасывать исключений
        await repository.clear();

        final loaded = await repository.loadConfigs();
        expect(loaded, isEmpty);
      });
    });

    group('интеграционные тесты', () {
      test('полный CRUD цикл', () async {
        // Create
        final config = createConfig(id: 'crud-test', name: 'CRUD Printer');
        await repository.upsert(config);
        expect(await repository.exists('crud-test'), isTrue);

        // Read
        final found = await repository.findById('crud-test');
        expect(found, isNotNull);
        expect(found!.name, equals('CRUD Printer'));

        // Update
        final updated = PrinterConfig(
          id: 'crud-test',
          name: 'Updated CRUD Printer',
          printerPosType: PrinterPOSType.receiptPrinter,
          rawSettings: config.rawSettings,
        );
        await repository.upsert(updated);
        final afterUpdate = await repository.findById('crud-test');
        expect(afterUpdate!.name, equals('Updated CRUD Printer'));

        // Delete
        await repository.deleteById('crud-test');
        expect(await repository.exists('crud-test'), isFalse);
      });

      test('множественные операции сохраняют целостность', () async {
        // Добавляем несколько конфигураций
        for (var i = 0; i < 5; i++) {
          await repository.upsert(createConfig(id: 'printer-$i', name: 'Printer $i'));
        }

        // Удаляем некоторые
        await repository.deleteById('printer-1');
        await repository.deleteById('printer-3');

        // Обновляем одну
        await repository.upsert(PrinterConfig(
          id: 'printer-2',
          name: 'Updated Printer 2',
          printerPosType: PrinterPOSType.kitchenPrinter,
          rawSettings: {'address': '10.0.0.1', 'port': 9100},
        ));

        // Проверяем результат
        expect(await repository.count(), equals(3));
        expect(await repository.exists('printer-0'), isTrue);
        expect(await repository.exists('printer-1'), isFalse);
        expect(await repository.exists('printer-2'), isTrue);
        expect(await repository.exists('printer-3'), isFalse);
        expect(await repository.exists('printer-4'), isTrue);

        final printer2 = await repository.findById('printer-2');
        expect(printer2!.name, equals('Updated Printer 2'));
        expect(printer2.printerPosType, equals(PrinterPOSType.kitchenPrinter));
      });
    });
  });
}
