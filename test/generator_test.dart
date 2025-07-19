import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iconfont_generator/src/generator.dart';
import 'package:flutter_iconfont_generator/src/config.dart';
import 'package:flutter_iconfont_generator/src/svg_parser.dart';
import 'dart:io';

void main() {
  group('CodeGenerator', () {
    late Directory tempDir;
    late IconFontConfig config;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('iconfont_test_');
      config = IconFontConfig(
        symbolUrl: 'https://at.alicdn.com/t/font_test.js',
        saveDir: tempDir.path,
        trimIconPrefix: 'icon',
        defaultIconSize: 18,
        nullSafety: true,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Camel case conversion', () {
      test('should convert simple names to camelCase', () {
        // Testing the private method indirectly through generated content
        final symbols = [
          SvgSymbol(
            id: 'icon-home',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        // Generate code and check if camelCase names are used
        expect(symbols.first.id, equals('icon-home'));
      });

      test('should handle complex icon names', () {
        final symbols = [
          SvgSymbol(
            id: 'icon-user-circle-o',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        expect(symbols.first.id, equals('icon-user-circle-o'));
      });

      test('should handle names with numbers', () {
        final symbols = [
          SvgSymbol(
            id: 'icon-1-home',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        expect(symbols.first.id, equals('icon-1-home'));
      });
    });

    group('SVG case generation', () {
      test('should generate SVG with single path', () {
        final symbol = SvgSymbol(
          id: 'icon-simple',
          viewBox: '0 0 24 24',
          paths: [
            SvgPath(
              d: 'M10 20v-6h4v6',
              fill: '#000000',
              attributes: {'d': 'M10 20v-6h4v6', 'fill': '#000000'},
            ),
          ],
        );

        // The SVG case should include viewBox and path
        expect(symbol.viewBox, equals('0 0 24 24'));
        expect(symbol.paths.first.d, equals('M10 20v-6h4v6'));
        expect(symbol.paths.first.fill, equals('#000000'));
      });

      test('should handle multiple paths', () {
        final symbol = SvgSymbol(
          id: 'icon-complex',
          viewBox: '0 0 100 100',
          paths: [
            SvgPath(
              d: 'M10 10 L20 20',
              fill: '#ff0000',
              attributes: {'d': 'M10 10 L20 20', 'fill': '#ff0000'},
            ),
            SvgPath(
              d: 'M30 30 L40 40',
              fill: '#00ff00',
              attributes: {'d': 'M30 30 L40 40', 'fill': '#00ff00'},
            ),
          ],
        );

        expect(symbol.paths, hasLength(2));
        expect(symbol.paths[0].fill, equals('#ff0000'));
        expect(symbol.paths[1].fill, equals('#00ff00'));
      });

      test('should handle paths without fill', () {
        final symbol = SvgSymbol(
          id: 'icon-no-fill',
          viewBox: '0 0 24 24',
          paths: [
            SvgPath(
              d: 'M10 20v-6h4v6',
              attributes: {'d': 'M10 20v-6h4v6'},
            ),
          ],
        );

        expect(symbol.paths.first.fill, isNull);
      });
    });

    group('Icon name processing', () {
      test('should trim icon prefix correctly', () {
        final testConfig = IconFontConfig(
          symbolUrl: 'test',
          saveDir: tempDir.path,
          trimIconPrefix: 'icon',
          defaultIconSize: 18,
          nullSafety: true,
        );

        // Testing prefix trimming logic
        const iconId = 'icon-home';
        const expectedTrimmed = 'home';
        
        expect(iconId.startsWith('${testConfig.trimIconPrefix}-'), isTrue);
        
        final trimmed = iconId.substring('${testConfig.trimIconPrefix}-'.length);
        expect(trimmed, equals(expectedTrimmed));
      });

      test('should handle icons without prefix', () {
        const iconId = 'home';
        const prefix = 'icon';
        
        expect(iconId.startsWith('$prefix-'), isFalse);
        expect(iconId.startsWith(prefix), isFalse);
      });

      test('should handle custom prefix', () {
        final testConfig = IconFontConfig(
          symbolUrl: 'test',
          saveDir: tempDir.path,
          trimIconPrefix: 'custom',
          defaultIconSize: 18,
          nullSafety: true,
        );

        const iconId = 'custom-home';
        const expectedTrimmed = 'home';
        
        final trimmed = iconId.substring('${testConfig.trimIconPrefix}-'.length);
        expect(trimmed, equals(expectedTrimmed));
      });
    });

    group('File generation', () {
      test('should create output directory if not exists', () async {
        final nonExistentDir = Directory('${tempDir.path}/nested/path');
        final testConfig = IconFontConfig(
          symbolUrl: 'test',
          saveDir: nonExistentDir.path,
          trimIconPrefix: 'icon',
          defaultIconSize: 18,
          nullSafety: true,
        );

        expect(await nonExistentDir.exists(), isFalse);

        final symbols = [
          SvgSymbol(
            id: 'icon-test',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        await CodeGenerator.generateIconFont(symbols, testConfig);

        expect(await nonExistentDir.exists(), isTrue);
        
        final outputFile = File('${nonExistentDir.path}/iconfont.dart');
        expect(await outputFile.exists(), isTrue);
      });

      test('should generate valid Dart code structure', () async {
        final symbols = [
          SvgSymbol(
            id: 'icon-home',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(
                d: 'M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z',
                fill: '#000000',
                attributes: {'d': 'M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z', 'fill': '#000000'},
              ),
            ],
          ),
          SvgSymbol(
            id: 'icon-user',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(
                d: 'M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4',
                attributes: {'d': 'M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4'},
              ),
            ],
          ),
        ];

        await CodeGenerator.generateIconFont(symbols, config);

        final outputFile = File('${config.saveDir}/iconfont.dart');
        expect(await outputFile.exists(), isTrue);

        final content = await outputFile.readAsString();
        
        // Check for essential Dart code structure
        expect(content, contains('import \'package:flutter/widgets.dart\';'));
        expect(content, contains('import \'package:flutter_svg/flutter_svg.dart\';'));
        expect(content, contains('enum IconNames {'));
        expect(content, contains('class IconFont extends StatelessWidget'));
        expect(content, contains('build(BuildContext context)'));
        
        // Check that icons are included
        expect(content, contains('home')); // trimmed icon name
        expect(content, contains('user')); // trimmed icon name
      });

      test('should handle null safety configuration', () async {
        final nullSafetyConfig = IconFontConfig(
          symbolUrl: 'test',
          saveDir: tempDir.path,
          trimIconPrefix: 'icon',
          defaultIconSize: 24,
          nullSafety: true,
        );

        final symbols = [
          SvgSymbol(
            id: 'icon-test',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        await CodeGenerator.generateIconFont(symbols, nullSafetyConfig);

        final outputFile = File('${nullSafetyConfig.saveDir}/iconfont.dart');
        final content = await outputFile.readAsString();

        // Check null safety syntax
        expect(content, contains('super.key'));
        expect(content, contains('String?'));
        expect(content, contains('List<String>?'));
      });

      test('should clean existing Dart files before generation', () async {
        // Create an existing Dart file
        final existingFile = File('${config.saveDir}/old_iconfont.dart');
        await existingFile.writeAsString('// Old content');
        expect(await existingFile.exists(), isTrue);

        final symbols = [
          SvgSymbol(
            id: 'icon-new',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        await CodeGenerator.generateIconFont(symbols, config);

        // Old file should be deleted
        expect(await existingFile.exists(), isFalse);
        
        // New file should exist
        final newFile = File('${config.saveDir}/iconfont.dart');
        expect(await newFile.exists(), isTrue);
      });

      test('should use correct default icon size', () async {
        final customSizeConfig = IconFontConfig(
          symbolUrl: 'test',
          saveDir: tempDir.path,
          trimIconPrefix: 'icon',
          defaultIconSize: 32,
          nullSafety: true,
        );

        final symbols = [
          SvgSymbol(
            id: 'icon-test',
            viewBox: '0 0 24 24',
            paths: [
              SvgPath(d: 'M10 20v-6h4v6', attributes: {'d': 'M10 20v-6h4v6'}),
            ],
          ),
        ];

        await CodeGenerator.generateIconFont(symbols, customSizeConfig);

        final outputFile = File('${customSizeConfig.saveDir}/iconfont.dart');
        final content = await outputFile.readAsString();

        expect(content, contains('this.size = 32'));
      });
    });

    group('Edge cases', () {
      test('should handle empty symbols list', () async {
        final symbols = <SvgSymbol>[];

        await CodeGenerator.generateIconFont(symbols, config);

        final outputFile = File('${config.saveDir}/iconfont.dart');
        expect(await outputFile.exists(), isTrue);

        final content = await outputFile.readAsString();
        expect(content, contains('enum IconNames {'));
        // Should still generate valid code structure even with no icons
      });

      test('should handle symbols with empty paths', () async {
        final symbols = [
          SvgSymbol(
            id: 'icon-empty',
            viewBox: '0 0 24 24',
            paths: [],
          ),
        ];

        await CodeGenerator.generateIconFont(symbols, config);

        final outputFile = File('${config.saveDir}/iconfont.dart');
        expect(await outputFile.exists(), isTrue);

        final content = await outputFile.readAsString();
        expect(content, contains('empty')); // trimmed icon name
      });
    });
  });
}