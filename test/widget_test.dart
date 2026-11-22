import 'package:marker/src/providers/theme_provider.dart';
import 'package:marker/src/theme/highlight_style.dart';
import 'package:marker/src/widgets/markdown_editing_controller.dart';
import 'package:marker/src/providers/external_files.dart';
import 'package:marker/src/widgets/marker_dialog.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:marker/src/widgets/markdown_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marker/main.dart';

part 'cases/widget_document_cases.dart';
part 'cases/widget_layout_cases.dart';
part 'cases/widget_editor_settings_cases.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  _registerWidgetDocumentCases();
  _registerWidgetLayoutCases();
  _registerWidgetEditorSettingsCases();
}
