import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/app_exception.dart';

enum Status {
  initial,
  loading,
  loaded,
  failure;

  bool get isLoading => this == loading;

  bool get isFailure => this == failure;
}

const genericErrorMessage = 'Something went wrong. Try again.';

mixin SafeHandler<S> on BlocBase<S> {
  Future<void> guard(
    Future<void> Function() body,
    void Function(String message) onFailure,
  ) async {
    try {
      await body();
    } on AppException catch (e) {
      onFailure(e.message);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      onFailure(genericErrorMessage);
    }
  }
}

Map<String, dynamic> normalizeJson(Map<dynamic, dynamic> map) =>
    jsonDecode(jsonEncode(map)) as Map<String, dynamic>;

List<T> listFromJson<T>(
  Object? list,
  T Function(Map<String, dynamic> json) parse,
) => (list as List? ?? const [])
    .map((item) => parse(normalizeJson(item as Map)))
    .toList();
