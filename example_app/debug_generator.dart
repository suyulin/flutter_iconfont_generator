#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  print('Testing Dart execution...');

  final result = await Process.run(
    'dart',
    ['../bin/simple_generator.dart'],
    workingDirectory:
        '/Users/suyulin/work/github/flutter_iconfont_generator/example_app',
  );

  print('Exit code: ${result.exitCode}');
  print('STDOUT:');
  print(result.stdout);
  print('STDERR:');
  print(result.stderr);
}
