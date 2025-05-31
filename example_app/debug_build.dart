#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('Starting build_runner test...');

  // Change to the example_app directory
  Directory.current =
      '/Users/suyulin/work/github/flutter_iconfont_generator/example_app';

  print('Current directory: ${Directory.current.path}');

  // Run flutter pub get
  print('Running flutter pub get...');
  var result = await Process.run('flutter', ['pub', 'get']);
  print('pub get exit code: ${result.exitCode}');
  if (result.exitCode != 0) {
    print('pub get stderr: ${result.stderr}');
    return;
  }

  // Run build_runner
  print('Running build_runner...');
  result =
      await Process.run('dart', ['run', 'build_runner', 'build', '--verbose']);

  print('build_runner exit code: ${result.exitCode}');
  print('build_runner stdout: ${result.stdout}');
  print('build_runner stderr: ${result.stderr}');

  // Check if file was generated
  var generatedFile = File('lib/iconfont.g.dart');
  if (generatedFile.existsSync()) {
    print('✅ Generated file exists!');
    print('File size: ${generatedFile.lengthSync()} bytes');
  } else {
    print('❌ Generated file does not exist');
  }
}
