import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'support/file_cleanup.dart';

void main() {
  test(
    'cleanup succeeds after a transient Windows sharing violation',
    () async {
      final root = await Directory.systemTemp.createTemp('marker-cleanup-');
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      await File('${root.path}/image.png').writeAsString('fixture');
      var attempts = 0;
      await withWindowsFileLockRetry(
        () async {
          if (++attempts < 3) {
            throw FileSystemException(
              'File is in use',
              root.path,
              const OSError('Sharing violation', 32),
            );
          }
          await root.delete(recursive: true);
        },
        windows: true,
        retryDelay: Duration.zero,
      );
      expect(await root.exists(), isFalse);
      expect(attempts, greaterThan(1));
    },
  );

  test(
    'a persistent lock remains a test failure after bounded retries',
    () async {
      final error = FileSystemException(
        'File is in use',
        'fixture',
        const OSError('Lock violation', 33),
      );
      var attempts = 0;
      await expectLater(
        withWindowsFileLockRetry(
          () async {
            attempts++;
            throw error;
          },
          windows: true,
          retryDelay: Duration.zero,
        ),
        throwsA(same(error)),
      );
      expect(attempts, inInclusiveRange(2, 8));
    },
  );

  test(
    'access denied is reported immediately rather than hidden by retry',
    () async {
      final error = FileSystemException(
        'Access denied',
        'fixture',
        const OSError('Access denied', 5),
      );
      var attempts = 0;
      await expectLater(
        withWindowsFileLockRetry(
          () async {
            attempts++;
            throw error;
          },
          windows: true,
          retryDelay: Duration.zero,
        ),
        throwsA(same(error)),
      );
      expect(attempts, 1);
    },
  );

  test('sharing codes on non-Windows systems are not retried', () async {
    final error = FileSystemException(
      'Other failure',
      'fixture',
      const OSError('Other failure', 32),
    );
    var attempts = 0;
    await expectLater(
      withWindowsFileLockRetry(
        () async {
          attempts++;
          throw error;
        },
        windows: false,
        retryDelay: Duration.zero,
      ),
      throwsA(same(error)),
    );
    expect(attempts, 1);
  });
}
