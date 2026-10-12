import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  @override
  String get storagePrefix => 'ThemeCubit';

  void select(ThemeMode mode) => emit(mode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) =>
      ThemeMode.values.asNameMap()[json['mode']];

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'mode': state.name};
}
