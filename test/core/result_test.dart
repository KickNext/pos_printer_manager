import 'package:flutter_test/flutter_test.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('создается успешно с данными', () {
        const result = Result<int>.success(42);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.dataOrNull, equals(42));
        expect(result.errorOrNull, isNull);
      });

      test('dataOrThrow возвращает данные', () {
        const result = Result<String>.success('test');

        expect(result.dataOrThrow, equals('test'));
      });

      test('when вызывает success callback', () {
        const result = Result<int>.success(42);
        var called = false;

        result.when(
          success: (data) {
            called = true;
            expect(data, equals(42));
          },
          failure: (_) => fail('Should not be called'),
        );

        expect(called, isTrue);
      });

      test('map трансформирует данные', () {
        const result = Result<int>.success(10);

        final mapped = result.map((data) => data * 2);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, equals(20));
      });

      test('flatMap трансформирует в новый Result', () {
        const result = Result<int>.success(10);

        final flatMapped = result.flatMap(
          (data) => Result<String>.success('Value: $data'),
        );

        expect(flatMapped.isSuccess, isTrue);
        expect(flatMapped.dataOrNull, equals('Value: 10'));
      });

      test('getOrElse возвращает данные', () {
        const result = Result<int>.success(42);

        expect(result.getOrElse(() => 0), equals(42));
      });

      test('getOrDefault возвращает данные', () {
        const result = Result<int>.success(42);

        expect(result.getOrDefault(0), equals(42));
      });

      test('onSuccess выполняет action', () {
        const result = Result<int>.success(42);
        var value = 0;

        result.onSuccess((data) => value = data);

        expect(value, equals(42));
      });

      test('onFailure не выполняет action', () {
        const result = Result<int>.success(42);
        var called = false;

        result.onFailure((_) => called = true);

        expect(called, isFalse);
      });

      test('recover возвращает исходный результат', () {
        const result = Result<int>.success(42);

        final recovered = result.recover((_) => const Result.success(0));

        expect(recovered.dataOrNull, equals(42));
      });

      test('equals работает корректно', () {
        const result1 = Result<int>.success(42);
        const result2 = Result<int>.success(42);
        const result3 = Result<int>.success(0);

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });
    });

    group('Failure', () {
      test('создается успешно с ошибкой', () {
        const error = AppError.validation('Invalid input');
        const result = Result<int>.failure(error);

        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.dataOrNull, isNull);
        expect(result.errorOrNull, equals(error));
      });

      test('dataOrThrow выбрасывает исключение', () {
        const error = AppError.notFound('Not found');
        const result = Result<int>.failure(error);

        // dataOrThrow теперь выбрасывает типизированное PrinterException
        expect(() => result.dataOrThrow, throwsA(isA<PrinterException>()));
      });

      test('when вызывает failure callback', () {
        const error = AppError.network('Connection failed');
        const result = Result<int>.failure(error);
        var called = false;

        result.when(
          success: (_) => fail('Should not be called'),
          failure: (err) {
            called = true;
            expect(err, equals(error));
          },
        );

        expect(called, isTrue);
      });

      test('map сохраняет ошибку', () {
        const error = AppError.validation('Invalid');
        const result = Result<int>.failure(error);

        final mapped = result.map((data) => data * 2);

        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, equals(error));
      });

      test('flatMap сохраняет ошибку', () {
        const error = AppError.permission('Denied');
        const result = Result<int>.failure(error);

        final flatMapped = result.flatMap(
          (data) => Result<String>.success('Value: $data'),
        );

        expect(flatMapped.isFailure, isTrue);
        expect(flatMapped.errorOrNull, equals(error));
      });

      test('getOrElse возвращает значение по умолчанию', () {
        const result = Result<int>.failure(AppError.unknown('Error'));

        expect(result.getOrElse(() => 99), equals(99));
      });

      test('getOrDefault возвращает значение по умолчанию', () {
        const result = Result<int>.failure(AppError.unknown('Error'));

        expect(result.getOrDefault(99), equals(99));
      });

      test('onSuccess не выполняет action', () {
        const result = Result<int>.failure(AppError.unknown('Error'));
        var called = false;

        result.onSuccess((_) => called = true);

        expect(called, isFalse);
      });

      test('onFailure выполняет action', () {
        const error = AppError.connection('Disconnected');
        const result = Result<int>.failure(error);
        AppError? receivedError;

        result.onFailure((err) => receivedError = err);

        expect(receivedError, equals(error));
      });

      test('recover трансформирует результат', () {
        const result = Result<int>.failure(AppError.unknown('Error'));

        final recovered = result.recover((_) => const Result.success(42));

        expect(recovered.isSuccess, isTrue);
        expect(recovered.dataOrNull, equals(42));
      });
    });

    group('maybeWhen', () {
      test('возвращает результат success callback при успехе', () {
        const result = Result<int>.success(42);

        final value = result.maybeWhen(success: (data) => data * 2, orElse: 0);

        expect(value, equals(84));
      });

      test('возвращает orElse при отсутствии success callback', () {
        const result = Result<int>.success(42);

        final value = result.maybeWhen(orElse: 0);

        expect(value, equals(0));
      });

      test('возвращает результат failure callback при ошибке', () {
        const result = Result<int>.failure(AppError.validation('Invalid'));

        final value = result.maybeWhen(
          failure: (error) => error.message,
          orElse: '',
        );

        expect(value, equals('Invalid'));
      });
    });

    group('Async operations', () {
      test('mapAsync трансформирует данные асинхронно', () async {
        const result = Result<int>.success(10);

        final mapped = await result.mapAsync((data) async => 'Value: $data');

        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, equals('Value: 10'));
      });

      test('flatMapAsync трансформирует в новый Result асинхронно', () async {
        const result = Result<int>.success(10);

        final flatMapped = await result.flatMapAsync(
          (data) async => Result<String>.success('Value: $data'),
        );

        expect(flatMapped.isSuccess, isTrue);
        expect(flatMapped.dataOrNull, equals('Value: 10'));
      });

      test('recoverAsync восстанавливает результат асинхронно', () async {
        const result = Result<int>.failure(AppError.unknown('Error'));

        final recovered = await result.recoverAsync(
          (_) async => const Result.success(42),
        );

        expect(recovered.isSuccess, isTrue);
        expect(recovered.dataOrNull, equals(42));
      });
    });
  });

  group('AppError', () {
    test('создается с правильным типом для network', () {
      const error = AppError.network('Connection failed');

      expect(error.type, equals(AppErrorType.network));
      expect(error.message, equals('Connection failed'));
    });

    test('создается с правильным типом для connection', () {
      const error = AppError.connection('Disconnected');

      expect(error.type, equals(AppErrorType.connection));
    });

    test('создается с правильным типом для permission', () {
      const error = AppError.permission('Access denied');

      expect(error.type, equals(AppErrorType.permission));
    });

    test('создается с правильным типом для notFound', () {
      const error = AppError.notFound('Resource not found');

      expect(error.type, equals(AppErrorType.notFound));
    });

    test('создается с правильным типом для validation', () {
      const error = AppError.validation('Invalid input');

      expect(error.type, equals(AppErrorType.validation));
    });

    test('создается с правильным типом для configuration', () {
      const error = AppError.configuration('Invalid config');

      expect(error.type, equals(AppErrorType.configuration));
    });

    test('создается с правильным типом для printing', () {
      const error = AppError.printing('Print failed');

      expect(error.type, equals(AppErrorType.printing));
    });

    test('создается с правильным типом для deviceBusy', () {
      const error = AppError.deviceBusy('Device is busy');

      expect(error.type, equals(AppErrorType.deviceBusy));
    });

    test('создается с правильным типом для timeout', () {
      const error = AppError.timeout('Operation timed out');

      expect(error.type, equals(AppErrorType.timeout));
    });

    test('создается с правильным типом для cancelled', () {
      const error = AppError.cancelled('Operation cancelled');

      expect(error.type, equals(AppErrorType.cancelled));
    });

    test('создается с правильным типом для unknown', () {
      const error = AppError.unknown('Unknown error');

      expect(error.type, equals(AppErrorType.unknown));
    });

    test('fromException создает ошибку из исключения', () {
      final exception = Exception('Something went wrong');

      final error = AppError.fromException(exception);

      expect(error.type, equals(AppErrorType.unknown));
      expect(error.cause, equals(exception));
    });

    test('fromException распознает permission в сообщении', () {
      final exception = Exception('USB permission denied');

      final error = AppError.fromException(exception);

      expect(error.type, equals(AppErrorType.permission));
    });

    test('fromException распознает timeout в сообщении', () {
      final exception = Exception('Connection timeout');

      final error = AppError.fromException(exception);

      expect(error.type, equals(AppErrorType.timeout));
    });

    test('fromException возвращает тот же AppError', () {
      const originalError = AppError.validation('Test');

      final error = AppError.fromException(originalError);

      expect(identical(error, originalError), isTrue);
    });

    test('toPrinterException создает типизированное исключение', () {
      const error = AppError.validation('Test');

      final exception = error.toPrinterException();

      expect(exception, isA<PrinterConnectionException>());
      expect(exception.message, equals('Test'));
    });

    test('toPrinterException создает PrinterConnectionException для connection', () {
      const error = AppError.connection('Connection failed');

      final exception = error.toPrinterException(printerId: 'printer-1');

      expect(exception, isA<PrinterConnectionException>());
      expect((exception as PrinterConnectionException).printerId, equals('printer-1'));
    });

    test('toPrinterException создает PrintingException для printing', () {
      const error = AppError.printing('Print failed');

      final exception = error.toPrinterException();

      expect(exception, isA<PrintingException>());
    });

    test('toPrinterException создает PrinterNotFoundException для notFound', () {
      const error = AppError.notFound('Printer not found');

      final exception = error.toPrinterException(printerId: 'printer-123');

      expect(exception, isA<PrinterNotFoundException>());
      expect((exception as PrinterNotFoundException).printerId, equals('printer-123'));
    });

    // ignore: deprecated_member_use_from_same_package
    test('toException создает AppException (deprecated)', () {
      const error = AppError.validation('Test');

      // ignore: deprecated_member_use_from_same_package
      final exception = error.toException();

      expect(exception, isA<AppException>());
      expect(exception.error, equals(error));
    });

    test('copyWith создает копию с изменениями', () {
      const error = AppError.validation('Original');

      final copy = error.copyWith(message: 'Modified');

      expect(copy.type, equals(AppErrorType.validation));
      expect(copy.message, equals('Modified'));
    });

    test('equals работает корректно', () {
      const error1 = AppError.validation('Test');
      const error2 = AppError.validation('Test');
      const error3 = AppError.validation('Other');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });
  });

  group('runCatching', () {
    test('возвращает Success при успешном выполнении', () async {
      final result = await runCatching(() async => 42);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(42));
    });

    test('возвращает Failure при исключении', () async {
      final result = await runCatching<int>(
        () async => throw Exception('Error'),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.unknown));
    });
  });

  group('runCatchingSync', () {
    test('возвращает Success при успешном выполнении', () {
      final result = runCatchingSync(() => 42);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(42));
    });

    test('возвращает Failure при исключении', () {
      final result = runCatchingSync<int>(() => throw Exception('Error'));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, equals(AppErrorType.unknown));
    });
  });

  group('Extensions', () {
    test('toSuccess оборачивает значение в Success', () {
      final result = 42.toSuccess();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(42));
    });

    test('Future.toResult конвертирует успешный Future', () async {
      final result = await Future.value(42).toResult();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(42));
    });

    test('Future.toResult конвертирует неуспешный Future', () async {
      final result = await Future<int>.error(Exception('Error')).toResult();

      expect(result.isFailure, isTrue);
    });
  });
}
