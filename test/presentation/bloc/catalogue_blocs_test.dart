import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/presentation/bloc/categories/categories_bloc.dart';
import 'package:matibabu/presentation/bloc/doctors/doctors_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockDoctorRepository repository;

  setUp(() {
    mockHydratedStorage();
    repository = MockDoctorRepository();
  });

  group('CategoriesBloc', () {
    blocTest<CategoriesBloc, CategoriesState>(
      'loads categories',
      setUp: () => when(
        () => repository.categories(),
      ).thenAnswer((_) async => [dentistry]),
      build: () => CategoriesBloc(repository: repository),
      act: (bloc) => bloc.add(const CategoriesRequested()),
      expect: () => [
        const CategoriesState(status: Status.loading),
        const CategoriesState(status: Status.loaded, categories: [dentistry]),
      ],
    );

    blocTest<CategoriesBloc, CategoriesState>(
      'keeps cached categories when a refresh fails',
      setUp: () => when(
        () => repository.categories(),
      ).thenThrow(const AppException('offline')),
      build: () => CategoriesBloc(repository: repository),
      seed: () =>
          const CategoriesState(status: Status.loaded, categories: [dentistry]),
      act: (bloc) => bloc.add(const CategoriesRequested()),
      expect: () => [
        const CategoriesState(
          status: Status.failure,
          categories: [dentistry],
          message: 'offline',
        ),
      ],
    );

    test('hydrates only loaded state', () {
      final bloc = CategoriesBloc(repository: repository);
      const loaded = CategoriesState(
        status: Status.loaded,
        categories: [dentistry],
      );
      expect(bloc.fromJson(bloc.toJson(loaded)!), loaded);
      expect(
        bloc.toJson(const CategoriesState(status: Status.loading)),
        isNull,
      );
    });
  });

  group('DoctorsBloc', () {
    DoctorsBloc build({String? categoryId}) => DoctorsBloc(
      repository: repository,
      storageId: 'test',
      categoryId: categoryId,
      debounce: Duration.zero,
    );

    blocTest<DoctorsBloc, DoctorsState>(
      'loads doctors in a category',
      setUp: () => when(
        () => repository.doctors(categoryId: 'category-3', query: ''),
      ).thenAnswer((_) async => [doctor]),
      build: () => build(categoryId: 'category-3'),
      act: (bloc) => bloc.add(const DoctorsRequested()),
      expect: () => [
        const DoctorsState(status: Status.loading),
        const DoctorsState(status: Status.loaded, doctors: [doctor]),
      ],
    );

    blocTest<DoctorsBloc, DoctorsState>(
      'searches with only the latest query',
      setUp: () {
        when(
          () => repository.doctors(query: any(named: 'query')),
        ).thenAnswer((_) async => []);
        when(
          () => repository.doctors(query: 'jane'),
        ).thenAnswer((_) async => [doctor]);
      },
      build: build,
      seed: () => const DoctorsState(status: Status.loaded, doctors: [doctor]),
      act: (bloc) => bloc
        ..add(const DoctorsQueryChanged('ja'))
        ..add(const DoctorsQueryChanged('jane')),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const DoctorsState(
          status: Status.loaded,
          doctors: [doctor],
          query: 'ja',
        ),
        const DoctorsState(
          status: Status.loaded,
          doctors: [doctor],
          query: 'jane',
        ),
      ],
      verify: (_) => verifyNever(() => repository.doctors(query: 'ja')),
    );

    test('uses a separate storage key per list', () {
      expect(build().storageToken, 'DoctorsBloctest');
    });
  });
}
