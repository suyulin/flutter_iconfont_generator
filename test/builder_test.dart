import 'package:flutter_test/flutter_test.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'dart:io';
import '../lib/builder.dart';

void main() {
  group('IconFontBuilder', () {
    test('should have correct build extensions', () {
      final builder = IconFontBuilder();
      expect(builder.buildExtensions, equals({'.dart': ['.g.dart']}));
    });

    test('should build successfully with valid configuration', () async {
      // Create a temporary pubspec.yaml with valid config
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
            iconfont:
              symbol_url: "https://at.alicdn.com/t/c/font_8d5l8fzk5b87iudi.js"
              save_dir: "./lib/iconfont"
              trim_icon_prefix: "icon"
              default_icon_size: 18
              null_safety: true
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) {
          // Allow warnings for network calls during testing
          if (log.level.name != 'WARNING') {
            fail('Unexpected log: ${log.message}');
          }
        },
      );
    });

    test('should warn when no iconfont configuration found', () async {
      final logs = <LogRecord>[];
      
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) => logs.add(log),
      );

      expect(
        logs.any((log) => 
          log.level.name == 'WARNING' && 
          log.message.contains('No iconfont configuration found')
        ),
        isTrue,
      );
    });

    test('should warn when symbol_url is invalid', () async {
      final logs = <LogRecord>[];
      
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
            iconfont:
              symbol_url: "请参考README.md"
              save_dir: "./lib/iconfont"
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) => logs.add(log),
      );

      expect(
        logs.any((log) => 
          log.level.name == 'WARNING' && 
          log.message.contains('Please configure a valid symbol_url')
        ),
        isTrue,
      );
    });

    test('should warn when symbol_url is empty', () async {
      final logs = <LogRecord>[];
      
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
            iconfont:
              symbol_url: ""
              save_dir: "./lib/iconfont"
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) => logs.add(log),
      );

      expect(
        logs.any((log) => 
          log.level.name == 'WARNING' && 
          log.message.contains('Please configure a valid symbol_url')
        ),
        isTrue,
      );
    });

    test('should handle malformed pubspec.yaml', () async {
      expect(() async {
        await testBuilder(
          iconFontBuilder(BuilderOptions({})),
          {
            'pubspec.yaml': '''
              name: test_package
              dependencies:
                flutter: invalid yaml [
            ''',
            'lib/iconfont.dart': '''
              const String _generatorMarker = 'iconfont_generator';
            ''',
          },
          outputs: {},
        );
      }, throwsA(isA<Exception>()));
    });

    test('should log info messages during processing', () async {
      final logs = <LogRecord>[];
      
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
            iconfont:
              symbol_url: "https://example.com/test.js"
              save_dir: "./lib/iconfont"
              trim_icon_prefix: "icon"
              default_icon_size: 18
              null_safety: true
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) => logs.add(log),
      );

      // Should log fetching URL info
      expect(
        logs.any((log) => 
          log.level.name == 'INFO' && 
          log.message.contains('Fetching icons from:')
        ),
        isTrue,
      );
    });

    test('should handle configuration with all optional parameters', () async {
      final logs = <LogRecord>[];
      
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
            iconfont:
              symbol_url: "https://example.com/test.js"
              save_dir: "./lib/custom_icons"
              trim_icon_prefix: "ico"
              default_icon_size: 24
              null_safety: false
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) => logs.add(log),
      );

      // Should process without errors (network errors expected in test)
      expect(
        logs.any((log) => log.level.name == 'SEVERE'),
        isTrue, // Network error expected in test environment
      );
    });

    test('should create IconFontBuilder from factory function', () {
      final builder = iconFontBuilder(BuilderOptions({}));
      expect(builder, isA<IconFontBuilder>());
    });

    test('should handle missing pubspec.yaml file', () async {
      expect(() async {
        await testBuilder(
          iconFontBuilder(BuilderOptions({})),
          {
            'lib/iconfont.dart': '''
              const String _generatorMarker = 'iconfont_generator';
            ''',
          },
          outputs: {},
        );
      }, throwsA(isA<Exception>()));
    });

    test('should parse configuration from Map correctly', () async {
      final logs = <LogRecord>[];
      
      await testBuilder(
        iconFontBuilder(BuilderOptions({})),
        {
          'pubspec.yaml': '''
            name: test_package
            dependencies:
              flutter:
                sdk: flutter
            iconfont:
              symbol_url: https://test.com/font.js
              save_dir: ./lib/test_icons
              trim_icon_prefix: test
              default_icon_size: 32
              null_safety: true
          ''',
          'lib/iconfont.dart': '''
            const String _generatorMarker = 'iconfont_generator';
          ''',
        },
        outputs: {},
        onLog: (log) => logs.add(log),
      );

      // Should log the URL from config
      expect(
        logs.any((log) => 
          log.level.name == 'INFO' && 
          log.message.contains('https://test.com/font.js')
        ),
        isTrue,
      );
    });
  });
}
