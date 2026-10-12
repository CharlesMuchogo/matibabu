import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _import = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<File> _sources(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
    .toList();

Map<String, List<String>> _imports(String directory) => {
  for (final file in _sources(directory))
    file.path: _import
        .allMatches(file.readAsStringSync())
        .map((m) => m.group(1)!)
        .toList(),
};

void _expectNoImports(
  String layer,
  bool Function(String import) forbidden,
  String reason,
) {
  final violations = [
    for (final MapEntry(key: file, value: imports) in _imports(layer).entries)
      for (final import in imports)
        if (forbidden(import)) '$file -> $import',
  ];
  expect(violations, isEmpty, reason: reason);
}

void main() {
  const allowedInDomain = [
    'dart:',
    'package:equatable/',
    'package:json_annotation/',
    'package:matibabu/domain/',
  ];

  const infrastructure = [
    'package:dio/',
    'package:firebase_',
    'package:flutter_secure_storage/',
    'package:google_sign_in/',
    'package:web_socket_channel/',
  ];

  test('domain depends on nothing but itself and plain Dart packages', () {
    _expectNoImports(
      'lib/domain',
      (import) =>
          !import.endsWith('.g.dart') &&
          !allowedInDomain.any(import.startsWith),
      'Domain must stay free of Flutter, data and presentation code.',
    );
  });

  test('data never depends on presentation or state management', () {
    _expectNoImports(
      'lib/data',
      (import) =>
          import.startsWith('package:matibabu/presentation/') ||
          import.startsWith('package:flutter_bloc/') ||
          import.startsWith('package:hydrated_bloc/'),
      'Data implements domain contracts and must not know about the UI.',
    );
  });

  test('presentation only talks to domain contracts', () {
    _expectNoImports(
      'lib/presentation',
      (import) =>
          import.startsWith('package:matibabu/data/') ||
          infrastructure.any(import.startsWith),
      'Presentation must go through domain repositories, not data or SDKs.',
    );
  });

  test('only the composition root wires data into the app', () {
    final roots = {'lib/main.dart', 'lib/app.dart', 'lib/dependencies.dart'};
    final violations = [
      for (final MapEntry(key: file, value: imports) in _imports('lib').entries)
        if (!roots.contains(file) && !file.startsWith('lib/data/'))
          for (final import in imports)
            if (import.startsWith('package:matibabu/data/')) '$file -> $import',
    ];
    expect(violations, isEmpty);
  });

  test('hand-written code has no comments', () {
    final commented = [
      for (final file in [
        ..._sources('lib'),
        ..._sources('test'),
        ..._sources('integration_test'),
      ])
        for (final (index, line) in file.readAsLinesSync().indexed)
          if (RegExp(r'^\s*(//|/\*)').hasMatch(line))
            '${file.path}:${index + 1}',
    ];
    expect(commented, isEmpty);
  });
}
