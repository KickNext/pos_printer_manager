/// Модуль Result-типов для функционального стиля обработки ошибок.
///
/// Предоставляет типобезопасный способ обработки успешных результатов
/// и ошибок без использования исключений. Это улучшает читаемость кода,
/// явно показывает возможные пути выполнения и упрощает тестирование.
///
/// ## Использование:
///
/// ```dart
/// // Возврат успешного результата
/// Result<User> getUser() => Result.success(User(name: 'John'));
///
/// // Возврат ошибки
/// Result<User> getUser() => Result.failure(
///   AppError.notFound('User not found'),
/// );
///
/// // Обработка результата
/// final result = await getUser();
/// result.when(
///   success: (user) => print('Hello, ${user.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
///
/// // Трансформация результата
/// final nameResult = result.map((user) => user.name);
///
/// // Цепочка операций
/// final result = await getUser()
///   .flatMap((user) => getOrders(user.id))
///   .map((orders) => orders.length);
/// ```
///
/// ## Интеграция с исключениями:
///
/// ```dart
/// // Конвертация в PrinterException для throw
/// final error = AppError.connection('Printer offline');
/// throw error.toPrinterException(); // PrinterConnectionException
///
/// // Создание AppError из PrinterException
/// try {
///   await connectPrinter();
/// } catch (e, st) {
///   final error = AppError.fromException(e, st);
///   return Result.failure(error);
/// }
/// ```
library;

import 'package:flutter/foundation.dart';

import 'package:pos_printer_manager/src/core/exceptions.dart';

/// Sealed класс для представления результата операции.
///
/// Может быть либо [Success] с данными типа [T],
/// либо [Failure] с ошибкой типа [AppError].
@immutable
sealed class Result<T> {
  const Result();

  /// Создает успешный результат с данными.
  const factory Result.success(T data) = Success<T>;

  /// Создает результат с ошибкой.
  const factory Result.failure(AppError error) = Failure<T>;

  /// Проверяет, является ли результат успешным.
  bool get isSuccess => this is Success<T>;

  /// Проверяет, является ли результат ошибкой.
  bool get isFailure => this is Failure<T>;

  /// Возвращает данные или null, если результат — ошибка.
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Failure<T>() => null,
  };

  /// Возвращает ошибку или null, если результат — успех.
  AppError? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };

  /// Возвращает данные или выбрасывает исключение.
  ///
  /// **Важно:** Используйте только когда уверены в успешности результата.
  /// Выбрасывает типизированное [PrinterException] при ошибке.
  T get dataOrThrow => switch (this) {
    Success<T>(:final data) => data,
    Failure<T>(:final error) => throw error.toPrinterException(),
  };

  /// Обрабатывает результат с помощью callback-функций.
  ///
  /// [success] вызывается при успешном результате.
  /// [failure] вызывается при ошибке.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) => switch (this) {
    Success<T>(:final data) => success(data),
    Failure<T>(:final error) => failure(error),
  };

  /// Обрабатывает результат с необязательным обработчиком ошибки.
  ///
  /// Если [failure] не указан, возвращает [orElse].
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(AppError error)? failure,
    required R orElse,
  }) => switch (this) {
    Success<T>(:final data) => success?.call(data) ?? orElse,
    Failure<T>(:final error) => failure?.call(error) ?? orElse,
  };

  /// Трансформирует данные успешного результата.
  ///
  /// Если результат — ошибка, возвращает ту же ошибку.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(:final data) => Result.success(transform(data)),
    Failure<T>(:final error) => Result.failure(error),
  };

  /// Трансформирует данные успешного результата в новый Result.
  ///
  /// Полезно для цепочки операций, каждая из которых может вернуть ошибку.
  Result<R> flatMap<R>(Result<R> Function(T data) transform) => switch (this) {
    Success<T>(:final data) => transform(data),
    Failure<T>(:final error) => Result.failure(error),
  };

  /// Асинхронная версия [map].
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async =>
      switch (this) {
        Success<T>(:final data) => Result.success(await transform(data)),
        Failure<T>(:final error) => Result.failure(error),
      };

  /// Асинхронная версия [flatMap].
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T data) transform,
  ) async => switch (this) {
    Success<T>(:final data) => await transform(data),
    Failure<T>(:final error) => Result.failure(error),
  };

  /// Возвращает данные или значение по умолчанию.
  T getOrElse(T Function() defaultValue) => switch (this) {
    Success<T>(:final data) => data,
    Failure<T>() => defaultValue(),
  };

  /// Возвращает данные или указанное значение.
  T getOrDefault(T defaultValue) => switch (this) {
    Success<T>(:final data) => data,
    Failure<T>() => defaultValue,
  };

  /// Выполняет действие при успешном результате.
  Result<T> onSuccess(void Function(T data) action) {
    if (this case Success<T>(:final data)) {
      action(data);
    }
    return this;
  }

  /// Выполняет действие при ошибке.
  Result<T> onFailure(void Function(AppError error) action) {
    if (this case Failure<T>(:final error)) {
      action(error);
    }
    return this;
  }

  /// Восстанавливает результат при ошибке.
  Result<T> recover(Result<T> Function(AppError error) recovery) =>
      switch (this) {
        Success<T>() => this,
        Failure<T>(:final error) => recovery(error),
      };

  /// Асинхронная версия [recover].
  Future<Result<T>> recoverAsync(
    Future<Result<T>> Function(AppError error) recovery,
  ) async => switch (this) {
    Success<T>() => this,
    Failure<T>(:final error) => await recovery(error),
  };
}

/// Успешный результат с данными.
@immutable
final class Success<T> extends Result<T> {
  /// Данные успешного результата.
  final T data;

  /// Создает успешный результат.
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Результат с ошибкой.
@immutable
final class Failure<T> extends Result<T> {
  /// Информация об ошибке.
  final AppError error;

  /// Создает результат с ошибкой.
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Тип ошибки приложения.
///
/// Категоризирует ошибки для удобной обработки и отображения.
enum AppErrorType {
  /// Ошибка сети (таймаут, отсутствие соединения).
  network,

  /// Ошибка подключения к устройству (USB, Bluetooth).
  connection,

  /// Ошибка разрешений (USB, сеть).
  permission,

  /// Ресурс не найден.
  notFound,

  /// Ошибка валидации данных.
  validation,

  /// Ошибка конфигурации.
  configuration,

  /// Ошибка печати.
  printing,

  /// Устройство занято или недоступно.
  deviceBusy,

  /// Таймаут операции.
  timeout,

  /// Операция отменена.
  cancelled,

  /// Неизвестная или системная ошибка.
  unknown,
}

/// Структурированная ошибка приложения.
///
/// Содержит тип ошибки, сообщение и опциональную техническую информацию
/// для логирования и отладки.
@immutable
class AppError {
  /// Тип ошибки для категоризации.
  final AppErrorType type;

  /// Человекочитаемое сообщение об ошибке.
  final String message;

  /// Исходное исключение (для логирования).
  final Object? cause;

  /// Stack trace исходного исключения.
  final StackTrace? stackTrace;

  /// Дополнительный контекст ошибки.
  final Map<String, dynamic>? context;

  /// Создает ошибку приложения.
  const AppError({
    required this.type,
    required this.message,
    this.cause,
    this.stackTrace,
    this.context,
  });

  /// Создает ошибку сети.
  const AppError.network(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.network;

  /// Создает ошибку подключения.
  const AppError.connection(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.connection;

  /// Создает ошибку разрешений.
  const AppError.permission(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.permission;

  /// Создает ошибку "не найдено".
  const AppError.notFound(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.notFound;

  /// Создает ошибку валидации.
  const AppError.validation(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.validation;

  /// Создает ошибку конфигурации.
  const AppError.configuration(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.configuration;

  /// Создает ошибку печати.
  const AppError.printing(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.printing;

  /// Создает ошибку "устройство занято".
  const AppError.deviceBusy(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.deviceBusy;

  /// Создает ошибку таймаута.
  const AppError.timeout(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.timeout;

  /// Создает ошибку отмены операции.
  const AppError.cancelled(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.cancelled;

  /// Создает неизвестную ошибку.
  const AppError.unknown(
    this.message, {
    this.cause,
    this.stackTrace,
    this.context,
  }) : type = AppErrorType.unknown;

  /// Создает ошибку из исключения.
  ///
  /// Автоматически определяет тип ошибки на основе типа исключения.
  /// Поддерживает типизированные исключения из [PrinterException] иерархии.
  factory AppError.fromException(Object exception, [StackTrace? stackTrace]) {
    // Если это уже AppError — возвращаем как есть
    if (exception is AppError) {
      return exception;
    }

    // Если это AppException — извлекаем внутренний AppError
    if (exception is AppException) {
      return exception.error;
    }

    // Обрабатываем типизированные PrinterException
    if (exception is PrinterException) {
      return _fromPrinterException(exception, stackTrace);
    }

    final message = exception.toString();

    // Определяем тип ошибки по содержимому сообщения
    if (message.contains('permission') || message.contains('Permission')) {
      return AppError.permission(
        message,
        cause: exception,
        stackTrace: stackTrace,
      );
    }
    if (message.contains('timeout') || message.contains('Timeout')) {
      return AppError.timeout(
        message,
        cause: exception,
        stackTrace: stackTrace,
      );
    }
    if (message.contains('connection') || message.contains('Connection')) {
      return AppError.connection(
        message,
        cause: exception,
        stackTrace: stackTrace,
      );
    }
    if (message.contains('network') || message.contains('Network')) {
      return AppError.network(
        message,
        cause: exception,
        stackTrace: stackTrace,
      );
    }

    return AppError.unknown(message, cause: exception, stackTrace: stackTrace);
  }

  /// Конвертирует [PrinterException] в [AppError].
  static AppError _fromPrinterException(
    PrinterException exception,
    StackTrace? stackTrace,
  ) {
    return switch (exception) {
      PluginNotRegisteredException e => AppError.configuration(
        e.message,
        cause: e,
        stackTrace: stackTrace,
        context: {'printerType': e.printerType.name},
      ),
      PrinterConfigurationException e => AppError.configuration(
        e.message,
        cause: e,
        stackTrace: stackTrace,
        context: {
          if (e.printerId != null) 'printerId': e.printerId,
          if (e.details != null) 'details': e.details,
        },
      ),
      PrinterConnectionException e => AppError.connection(
        e.message,
        cause: e,
        stackTrace: stackTrace,
        context: {
          if (e.printerId != null) 'printerId': e.printerId,
          if (e.errorCode != null) 'errorCode': e.errorCode,
          if (e.details != null) 'details': e.details,
        },
      ),
      PrintingException e => AppError.printing(
        e.message,
        cause: e,
        stackTrace: stackTrace,
        context: {
          if (e.printerId != null) 'printerId': e.printerId,
          if (e.jobType != null) 'jobType': e.jobType,
          if (e.details != null) 'details': e.details,
        },
      ),
      PrinterNotFoundException e => AppError.notFound(
        e.message,
        cause: e,
        stackTrace: stackTrace,
        context: {'printerId': e.printerId},
      ),
      PluginAlreadyRegisteredException e => AppError.configuration(
        e.message,
        cause: e,
        stackTrace: stackTrace,
        context: {'printerType': e.printerType.name},
      ),
    };
  }

  /// Конвертирует в исключение для throw.
  ///
  /// @deprecated Используйте [toPrinterException] для типизированных исключений.
  @Deprecated('Use toPrinterException() for typed exceptions')
  AppException toException() => AppException(this);

  /// Конвертирует в типизированное исключение [PrinterException].
  ///
  /// Возвращает наиболее подходящий тип исключения на основе [type].
  PrinterException toPrinterException({String? printerId}) {
    return switch (type) {
      AppErrorType.connection => PrinterConnectionException(
        message,
        printerId: printerId ?? context?['printerId'] as String?,
        details: context?['details'] as String?,
      ),
      AppErrorType.configuration => PrinterConfigurationException(
        message,
        printerId: printerId ?? context?['printerId'] as String?,
        details: context?['details'] as String?,
      ),
      AppErrorType.printing => PrintingException(
        message,
        printerId: printerId ?? context?['printerId'] as String?,
        jobType: context?['jobType'] as String?,
        details: context?['details'] as String?,
      ),
      AppErrorType.notFound => PrinterNotFoundException(
        printerId ?? context?['printerId'] as String? ?? 'unknown',
      ),
      // Для остальных типов используем общее PrinterConnectionException
      AppErrorType.network ||
      AppErrorType.permission ||
      AppErrorType.timeout ||
      AppErrorType.deviceBusy ||
      AppErrorType.cancelled ||
      AppErrorType.validation ||
      AppErrorType.unknown => PrinterConnectionException(
        message,
        printerId: printerId ?? context?['printerId'] as String?,
        details: context?['details'] as String?,
      ),
    };
  }

  /// Копирует ошибку с изменениями.
  AppError copyWith({
    AppErrorType? type,
    String? message,
    Object? cause,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      type: type ?? this.type,
      message: message ?? this.message,
      cause: cause ?? this.cause,
      stackTrace: stackTrace ?? this.stackTrace,
      context: context ?? this.context,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message;

  @override
  int get hashCode => Object.hash(type, message);

  @override
  String toString() => 'AppError($type: $message)';
}

/// Исключение приложения для throw/catch.
///
/// Обертка над [AppError] для случаев, когда необходимо использовать
/// традиционный механизм исключений.
class AppException implements Exception {
  /// Структурированная ошибка.
  final AppError error;

  /// Создает исключение из ошибки.
  const AppException(this.error);

  @override
  String toString() => error.message;
}

/// Расширения для работы с Result.
extension ResultExtensions<T> on T {
  /// Оборачивает значение в успешный Result.
  Result<T> toSuccess() => Result.success(this);
}

/// Расширения для работы с `Future<Result>`.
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Трансформирует данные успешного результата.
  Future<Result<R>> mapResult<R>(R Function(T data) transform) async {
    final result = await this;
    return result.map(transform);
  }

  /// Трансформирует данные успешного результата в новый Result.
  Future<Result<R>> flatMapResult<R>(
    Result<R> Function(T data) transform,
  ) async {
    final result = await this;
    return result.flatMap(transform);
  }
}

/// Утилиты для создания Result из Future.
extension FutureToResult<T> on Future<T> {
  /// Конвертирует Future в Result, перехватывая исключения.
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (e, st) {
      return Result.failure(AppError.fromException(e, st));
    }
  }
}

/// Функция для выполнения операции с возвратом Result.
///
/// Автоматически перехватывает исключения и конвертирует в Failure.
Future<Result<T>> runCatching<T>(Future<T> Function() operation) async {
  try {
    final result = await operation();
    return Result.success(result);
  } catch (e, st) {
    return Result.failure(AppError.fromException(e, st));
  }
}

/// Синхронная версия [runCatching].
Result<T> runCatchingSync<T>(T Function() operation) {
  try {
    final result = operation();
    return Result.success(result);
  } catch (e, st) {
    return Result.failure(AppError.fromException(e, st));
  }
}
