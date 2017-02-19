import 'dart:async';

import 'package:dart_dev/dart_dev.dart' show dev, config;

Future<Null> main(List<String> args) async {
  // https://github.com/Workiva/dart_dev

  config.analyze.entryPoints = [
    'lib',
    'lib/src',
    'extension',
    'test',
    'tool',
  ];

  config.coverage.pubServe = true;

  config.format
    ..directories = [
      'lib/',
      'extension',
      'test',
      'tool/',
    ];

  await dev(args);
}
