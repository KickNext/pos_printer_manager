/// Генератор уникальных идентификаторов для сущностей приложения.
///
/// Использует UUID v4 для генерации гарантированно уникальных
/// идентификаторов. UUID v4 основан на случайных числах и имеет
/// пренебрежимо малую вероятность коллизий.
///
/// ## Пример использования:
///
/// ```dart
/// // Генерация нового ID
/// final printerId = IdGenerator.generate();
/// // Результат: 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
///
/// // Проверка формата
/// if (IdGenerator.isValid(id)) {
///   print('Valid UUID');
/// }
/// ```
///
/// ## Формат:
///
/// UUID v4 имеет формат: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
/// где x — любая шестнадцатеричная цифра, y — одна из [8, 9, a, b].
library;

import 'package:uuid/uuid.dart';

/// Генератор уникальных идентификаторов.
///
/// Централизованный компонент для генерации ID во всём приложении.
/// Обеспечивает единообразие формата идентификаторов.
abstract final class IdGenerator {
  /// Внутренний экземпляр генератора UUID.
  static const _uuid = Uuid();

  /// Регулярное выражение для валидации UUID v4.
  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Генерирует новый уникальный идентификатор.
  ///
  /// Возвращает строку в формате UUID v4.
  ///
  /// ## Пример:
  /// ```dart
  /// final id = IdGenerator.generate();
  /// // 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
  /// ```
  static String generate() => _uuid.v4();

  /// Проверяет, является ли строка валидным UUID v4.
  ///
  /// [id] — строка для проверки.
  /// Возвращает true, если строка соответствует формату UUID v4.
  ///
  /// ## Пример:
  /// ```dart
  /// IdGenerator.isValid('f47ac10b-58cc-4372-a567-0e02b2c3d479'); // true
  /// IdGenerator.isValid('not-a-uuid'); // false
  /// IdGenerator.isValid('123456789'); // false (legacy timestamp ID)
  /// ```
  static bool isValid(String id) => _uuidRegex.hasMatch(id);

  /// Проверяет, является ли строка legacy ID (timestamp-based).
  ///
  /// Legacy ID — это идентификаторы, сгенерированные через
  /// `DateTime.now().millisecondsSinceEpoch.toString()`.
  ///
  /// [id] — строка для проверки.
  /// Возвращает true, если строка похожа на timestamp-based ID.
  static bool isLegacyId(String id) {
    // Legacy ID — это числовая строка длиной 13 символов (миллисекунды)
    if (id.length != 13) return false;
    return int.tryParse(id) != null;
  }

  /// Генерирует короткий идентификатор для отображения.
  ///
  /// Возвращает первые 8 символов UUID (до первого дефиса).
  /// Полезно для отображения в UI, где полный UUID слишком длинный.
  ///
  /// [id] — полный UUID.
  ///
  /// ## Пример:
  /// ```dart
  /// final shortId = IdGenerator.shorten('f47ac10b-58cc-4372-a567-0e02b2c3d479');
  /// // 'f47ac10b'
  /// ```
  static String shorten(String id) {
    if (id.length < 8) return id;
    final dashIndex = id.indexOf('-');
    if (dashIndex > 0) return id.substring(0, dashIndex);
    return id.substring(0, 8);
  }
}
