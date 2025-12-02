/// Unit-тесты для [IdGenerator].
///
/// Проверяют корректность генерации UUID v4 и валидации идентификаторов.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_printer_manager/src/core/id_generator.dart';

void main() {
  group('IdGenerator', () {
    group('generate', () {
      test('генерирует валидный UUID v4', () {
        final id = IdGenerator.generate();

        expect(IdGenerator.isValid(id), isTrue);
      });

      test('генерирует уникальные идентификаторы', () {
        final ids = <String>{};
        
        // Генерируем 1000 ID и проверяем уникальность
        for (var i = 0; i < 1000; i++) {
          ids.add(IdGenerator.generate());
        }

        expect(ids.length, equals(1000));
      });

      test('генерирует ID в правильном формате', () {
        final id = IdGenerator.generate();
        
        // UUID v4 имеет формат: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        expect(id.length, equals(36));
        expect(id.split('-').length, equals(5));
        expect(id[14], equals('4')); // Версия UUID
        expect('89ab'.contains(id[19].toLowerCase()), isTrue); // Вариант
      });
    });

    group('isValid', () {
      test('возвращает true для валидного UUID v4', () {
        final validUuids = [
          'f47ac10b-58cc-4372-a567-0e02b2c3d479',
          'A987FBC9-4BED-4078-8F07-9141BA07C9F3',
          '12345678-1234-4123-8123-123456789012',
        ];

        for (final uuid in validUuids) {
          expect(IdGenerator.isValid(uuid), isTrue, reason: 'UUID: $uuid');
        }
      });

      test('возвращает false для невалидных строк', () {
        final invalidStrings = [
          '',
          'not-a-uuid',
          '12345',
          '1234567890123', // legacy timestamp ID
          'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', // не hex
          'f47ac10b-58cc-3372-a567-0e02b2c3d479', // версия 3, не 4
          'f47ac10b-58cc-4372-c567-0e02b2c3d479', // неправильный вариант
        ];

        for (final str in invalidStrings) {
          expect(IdGenerator.isValid(str), isFalse, reason: 'String: $str');
        }
      });
    });

    group('isLegacyId', () {
      test('возвращает true для timestamp-based ID', () {
        final legacyIds = [
          '1701619200000', // 13 цифр
          '1234567890123',
        ];

        for (final id in legacyIds) {
          expect(IdGenerator.isLegacyId(id), isTrue, reason: 'ID: $id');
        }
      });

      test('возвращает false для UUID и других строк', () {
        final nonLegacyIds = [
          'f47ac10b-58cc-4372-a567-0e02b2c3d479',
          '123456789012', // 12 цифр, не 13
          '12345678901234', // 14 цифр, не 13
          'not-a-number',
          '',
        ];

        for (final id in nonLegacyIds) {
          expect(IdGenerator.isLegacyId(id), isFalse, reason: 'ID: $id');
        }
      });
    });

    group('shorten', () {
      test('возвращает первые 8 символов UUID', () {
        const uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        
        expect(IdGenerator.shorten(uuid), equals('f47ac10b'));
      });

      test('возвращает строку как есть если короче 8 символов', () {
        const shortId = 'short';
        
        expect(IdGenerator.shorten(shortId), equals('short'));
      });

      test('обрабатывает строку без дефиса', () {
        const noDashId = 'abcdefghijklmnop';
        
        expect(IdGenerator.shorten(noDashId), equals('abcdefgh'));
      });
    });
  });
}
