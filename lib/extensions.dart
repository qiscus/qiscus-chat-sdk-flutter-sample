import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

extension BuildContextX on BuildContext {
  void debugLog(dynamic arg, [dynamic error, StackTrace? stackTrace]) {
    read<Logger>().d(arg, error, stackTrace);
  }

  void pop<T extends Object>([T? result]) {
    Navigator.pop(this, result);
  }

  Future<T?> push<T extends Object>(Widget widget) async {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  Future<T?> pushReplacement<T extends Object, TO extends Object>(
    Widget widget,
  ) async {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }
}

extension FilePickerX on FilePicker {
  Future<File?> getFile({FileType type = FileType.image}) async {
    var result = await pickFiles(type: type);
    if (result?.files.first != null) {
      return File(result!.files.first.path!);
    }
    return null;
  }
}

extension IterableX<T> on Iterable<T> {
  T? safeWhere(bool Function(T) test) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }
}
