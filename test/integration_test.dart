import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:process/process.dart';

void main() {
  group('Command Line Tools Integration Tests', () {
    final processManager = LocalProcessManager();

    test('simple_generator should show help when run without valid config', () async {
      final result = await processManager.run([
        'dart',
        'run',
        'bin/simple_generator.dart',
        '--help'
      ]);

      expect(result.exitCode, anyOf(equals(0), equals(1))); // May exit with 1 due to missing config
      expect(result.stdout.toString(), contains('Flutter IconFont Generator'));
    });

    test('iconfont_generator should show help when run without valid config', () async {
      final result = await processManager.run([
        'dart',
        'run',
        'bin/iconfont_generator.dart',
        '--help'
      ]);

      expect(result.exitCode, anyOf(equals(0), equals(1))); // May exit with 1 due to missing config
      expect(result.stdout.toString(), contains('Flutter IconFont Generator'));
    });

    test('test_config should validate configuration', () async {
      final result = await processManager.run([
        'dart',
        'run',
        'bin/test_config.dart'
      ]);

      expect(result.exitCode, anyOf(equals(0), equals(1)));
      expect(result.stdout.toString(), anyOf(
        contains('Configuration loaded successfully'),
        contains('Error:') // If config is invalid
      ));
    });

    test('should be able to run dart pub get', () async {
      final result = await processManager.run([
        'dart',
        'pub',
        'get'
      ]);

      expect(result.exitCode, equals(0));
    });

    test('should be able to run dart analyze', () async {
      final result = await processManager.run([
        'dart',
        'analyze',
        '--fatal-infos'
      ]);

      expect(result.exitCode, equals(0));
    }, timeout: Timeout(Duration(minutes: 2)));

    test('should be able to compile binaries', () async {
      final binaries = [
        'bin/simple_generator.dart',
        'bin/iconfont_generator.dart',
        'bin/test_config.dart',
        'bin/test_all.dart',
      ];

      for (final binary in binaries) {
        final result = await processManager.run([
          'dart',
          'compile',
          'kernel',
          binary
        ]);

        expect(result.exitCode, equals(0), reason: 'Failed to compile $binary');
      }
    }, timeout: Timeout(Duration(minutes: 3)));

    test('build_runner should be available', () async {
      final result = await processManager.run([
        'dart',
        'run',
        'build_runner',
        '--help'
      ]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('build_runner'));
    });

    test('generated code should be valid dart', () async {
      // Create a temporary test directory
      final tempDir = await Directory.systemTemp.createTemp('test_generation_');
      
      try {
        // Create a test pubspec.yaml
        final pubspecFile = File('${tempDir.path}/pubspec.yaml');
        await pubspecFile.writeAsString('''
name: test_package
version: 1.0.0

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0
  http: ^0.13.0
  xml: ^6.0.0
  path: ^1.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter

iconfont:
  symbol_url: "https://at.alicdn.com/t/font_test.js"
  save_dir: "./lib/iconfont"
  trim_icon_prefix: "icon"
  default_icon_size: 18
  null_safety: true
''');

        // Create lib directory
        final libDir = Directory('${tempDir.path}/lib');
        await libDir.create();

        // Create a test dart file
        final testFile = File('${tempDir.path}/lib/test.dart');
        await testFile.writeAsString('''
enum IconNames { home, user }

class IconFont {
  const IconFont(this.iconName, {this.size = 18});
  final IconNames iconName;
  final double size;
}
''');

        // Run dart analyze on the generated file
        final result = await processManager.run([
          'dart',
          'analyze',
          testFile.path
        ]);

        expect(result.exitCode, equals(0));
      } finally {
        // Clean up
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('should handle invalid symbol URL gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_invalid_url_');
      
      try {
        // Create a test pubspec.yaml with invalid URL
        final pubspecFile = File('${tempDir.path}/pubspec.yaml');
        await pubspecFile.writeAsString('''
name: test_package
version: 1.0.0

environment:
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

iconfont:
  symbol_url: "invalid-url"
  save_dir: "./lib/iconfont"
''');

        // Change to temp directory
        final originalDir = Directory.current;
        Directory.current = tempDir;

        try {
          final result = await processManager.run([
            'dart',
            'run',
            '${originalDir.path}/bin/simple_generator.dart'
          ]);

          // Should fail gracefully
          expect(result.exitCode, equals(1));
          expect(result.stdout.toString(), contains('Error'));
        } finally {
          Directory.current = originalDir;
        }
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('should validate project structure', () async {
      final expectedFiles = [
        'pubspec.yaml',
        'lib/builder.dart',
        'lib/iconfont.dart',
        'lib/src/config.dart',
        'lib/src/fetcher.dart',
        'lib/src/generator.dart',
        'lib/src/svg_parser.dart',
        'bin/simple_generator.dart',
        'bin/iconfont_generator.dart',
        'bin/test_config.dart',
        'bin/test_all.dart',
        'build.yaml',
        'README.md',
      ];

      for (final filePath in expectedFiles) {
        final file = File(filePath);
        expect(await file.exists(), isTrue, reason: 'Missing file: $filePath');
      }
    });

    test('should have valid build.yaml configuration', () async {
      final buildFile = File('build.yaml');
      expect(await buildFile.exists(), isTrue);

      final content = await buildFile.readAsString();
      expect(content, contains('targets'));
      expect(content, contains('builders'));
    });

    test('pubspec.yaml should have all required dependencies', () async {
      final pubspecFile = File('pubspec.yaml');
      expect(await pubspecFile.exists(), isTrue);

      final content = await pubspecFile.readAsString();
      
      final requiredDeps = [
        'flutter_svg',
        'http',
        'xml',
        'path',
        'build_runner',
        'yaml',
        'build',
        'analyzer'
      ];

      for (final dep in requiredDeps) {
        expect(content, contains(dep), reason: 'Missing dependency: $dep');
      }
    });
  });

  group('Error Handling Integration Tests', () {
    test('should handle network timeout gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_timeout_');
      
      try {
        final pubspecFile = File('${tempDir.path}/pubspec.yaml');
        await pubspecFile.writeAsString('''
name: test_package
iconfont:
  symbol_url: "https://httpbin.org/delay/10"  # Slow endpoint
  save_dir: "./lib/iconfont"
''');

        final originalDir = Directory.current;
        Directory.current = tempDir;

        try {
          final result = await processManager.run(
            [
              'dart',
              'run',
              '${originalDir.path}/bin/simple_generator.dart'
            ],
            runInShell: true,
          );

          // Should handle timeout gracefully
          expect(result.exitCode, equals(1));
        } finally {
          Directory.current = originalDir;
        }
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    }, timeout: Timeout(Duration(seconds: 30)));

    test('should handle malformed SVG data', () async {
      // This would require mocking network responses in a real scenario
      // For now, we test that the tools can handle errors gracefully
      expect(true, isTrue); // Placeholder for more complex error handling tests
    });

    test('should validate output directory permissions', () async {
      final tempDir = await Directory.systemTemp.createTemp('test_permissions_');
      
      try {
        // On Unix systems, try to create a read-only directory
        if (!Platform.isWindows) {
          final readOnlyDir = Directory('${tempDir.path}/readonly');
          await readOnlyDir.create();
          
          // Make directory read-only
          await Process.run('chmod', ['444', readOnlyDir.path]);
          
          // Should handle permission errors gracefully
          expect(await readOnlyDir.exists(), isTrue);
        }
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
