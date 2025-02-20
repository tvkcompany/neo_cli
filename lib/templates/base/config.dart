import '../template.dart';

/// The base template that all other templates build upon
final baseTemplate = Template(
  name: 'base',
  dependencies: {
    'hooks_riverpod': null,
    'flutter_hooks': null,
    'riverpod_annotation': null,
    'auto_route': null,
    'gap': null,
    'phosphor_flutter': null,
  },
  devDependencies: {
    'riverpod_generator': null,
    'build_runner': null,
    'custom_lint': null,
    'riverpod_lint': null,
    'auto_route_generator': null,
  },
);
