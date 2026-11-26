import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:marker/src/resources/resource_service.dart';
import 'package:marker/src/resources/resource_references.dart';

part 'cases/resource_service_imports_cases.dart';
part 'cases/resource_service_relocation_cases.dart';
part 'cases/resource_service_deleted_files_cases.dart';

Uint8List png([int suffix = 0]) => Uint8List.fromList([
  ...base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
  ),
  suffix,
]);

late Directory folder;
late String document;
late DocumentResourceService service;

void main() {
  setUp(() async {
    folder = await Directory.systemTemp.createTemp('marker-资源-');
    document = p.join(folder.path, '中文 文档.md');
    await File(document).writeAsString('original');
    service = DocumentResourceService();
  });
  tearDown(() => folder.delete(recursive: true));
  _registerResourceServiceImportsCases();
  _registerResourceServiceRelocationCases();
  _registerResourceServiceDeletedFilesCases();
}

class _FailingWriter extends DocumentResourceService {
  _FailingWriter(this.destination);
  final String destination;
  @override
  Future<void> atomicWrite(File target, String text) async {
    if (target.path == destination) {
      await File(
        p.join(p.dirname(destination), 'copy.assets', 'user.txt'),
      ).writeAsString('keep');
      throw FileSystemException('Simulated publication failure', target.path);
    }
    return super.atomicWrite(target, text);
  }
}

class _RenameFailure extends DocumentResourceService {
  _RenameFailure(this.target);
  final String target;
  @override
  Future<void> atomicWrite(File file, String text) {
    if (file.path == target) {
      throw FileSystemException('Publication failed', target);
    }
    return super.atomicWrite(file, text);
  }
}
