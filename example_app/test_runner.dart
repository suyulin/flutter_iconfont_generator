import 'dart:io';

void main() async {
  print('Testing build_runner...');

  final result = await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--verbose'],
    workingDirectory:
        '/Users/suyulin/work/github/flutter_iconfont_generator/example_app',
  );

  print('Exit code: ${result.exitCode}');
  print('Stdout: ${result.stdout}');
  print('Stderr: ${result.stderr}');
}
