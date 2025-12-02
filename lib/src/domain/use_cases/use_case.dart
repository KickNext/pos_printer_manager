/// Базовый интерфейс для всех Use Cases.
///
/// Use Case инкапсулирует единственную бизнес-операцию приложения.
/// Каждый Use Case имеет чётко определённые входные параметры
/// и возвращает Result с типизированным результатом или ошибкой.
///
/// ## Принципы:
///
/// 1. **Единственная ответственность**: каждый Use Case выполняет
///    только одну бизнес-операцию.
///
/// 2. **Независимость от UI**: Use Cases не знают о виджетах,
///    контроллерах или других UI-компонентах.
///
/// 3. **Тестируемость**: Use Cases легко тестировать, так как
///    они принимают зависимости через конструктор.
///
/// 4. **Типобезопасность**: использование Result гарантирует
///    обработку всех возможных исходов.
///
/// ## Использование:
///
/// ```dart
/// class GetPrinterUseCase implements UseCase<String, PrinterConfig> {
///   final PrinterConfigRepository _repository;
///
///   GetPrinterUseCase(this._repository);
///
///   @override
///   Future<Result<PrinterConfig>> call(String printerId) async {
///     final config = await _repository.findById(printerId);
///     if (config == null) {
///       return Result.failure(AppError.notFound('Printer not found'));
///     }
///     return Result.success(config);
///   }
/// }
///
/// // Использование
/// final useCase = GetPrinterUseCase(repository);
/// final result = await useCase('printer-123');
/// result.when(
///   success: (config) => print('Found: ${config.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/result.dart';

/// Базовый интерфейс для Use Case с параметрами.
///
/// [Params] - тип входных параметров.
/// [Output] - тип результата при успехе.
abstract interface class UseCase<Params, Output> {
  /// Выполняет Use Case с указанными параметрами.
  ///
  /// Возвращает [Result] с [Output] при успехе или [AppError] при ошибке.
  Future<Result<Output>> call(Params params);
}

/// Базовый интерфейс для Use Case без параметров.
///
/// [Output] - тип результата при успехе.
abstract interface class UseCaseNoParams<Output> {
  /// Выполняет Use Case без параметров.
  ///
  /// Возвращает [Result] с [Output] при успехе или [AppError] при ошибке.
  Future<Result<Output>> call();
}

/// Базовый интерфейс для синхронного Use Case.
///
/// [Params] - тип входных параметров.
/// [Output] - тип результата при успехе.
abstract interface class SyncUseCase<Params, Output> {
  /// Выполняет синхронный Use Case с указанными параметрами.
  ///
  /// Возвращает [Result] с [Output] при успехе или [AppError] при ошибке.
  Result<Output> call(Params params);
}

/// Базовый интерфейс для синхронного Use Case без параметров.
///
/// [Output] - тип результата при успехе.
abstract interface class SyncUseCaseNoParams<Output> {
  /// Выполняет синхронный Use Case без параметров.
  ///
  /// Возвращает [Result] с [Output] при успехе или [AppError] при ошибке.
  Result<Output> call();
}

/// Базовый интерфейс для потокового Use Case.
///
/// Используется когда операция возвращает поток данных,
/// например, мониторинг состояния устройства.
///
/// [Params] - тип входных параметров.
/// [Output] - тип элементов потока.
abstract interface class StreamUseCase<Params, Output> {
  /// Выполняет Use Case и возвращает поток результатов.
  ///
  /// Каждый элемент потока — это [Result] с данными или ошибкой.
  Stream<Result<Output>> call(Params params);
}

/// Базовый интерфейс для потокового Use Case без параметров.
///
/// [Output] - тип элементов потока.
abstract interface class StreamUseCaseNoParams<Output> {
  /// Выполняет Use Case и возвращает поток результатов.
  Stream<Result<Output>> call();
}
