import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends HydratedBloc<CategoriesEvent, CategoriesState>
    with SafeHandler {
  final DoctorRepository _repository;

  CategoriesBloc({required DoctorRepository repository})
    : _repository = repository,
      super(const CategoriesState()) {
    on<CategoriesRequested>(_onRequested, transformer: droppable());
  }

  @override
  String get storagePrefix => 'CategoriesBloc';

  Future<void> _onRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state.categories.isEmpty) {
      emit(state.copyWith(status: Status.loading));
    }
    await guard(
      () async => emit(
        CategoriesState(
          status: Status.loaded,
          categories: await _repository.categories(),
        ),
      ),
      (message) =>
          emit(state.copyWith(status: Status.failure, message: message)),
    );
  }

  @override
  CategoriesState? fromJson(Map<String, dynamic> json) =>
      CategoriesState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(CategoriesState state) =>
      state.status == Status.loaded ? state.toMap() : null;
}
