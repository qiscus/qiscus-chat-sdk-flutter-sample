import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void pop<T extends Object>([T result]) {
    Navigator.pop(this, result);
  }

  Future<T> push<T extends Object>(Widget widget) async {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  Future<T> pushReplacement<T extends Object, TO extends Object>(
    Widget widget,
  ) async {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }
}
