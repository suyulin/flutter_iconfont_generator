import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import '../lib/src/generator.dart';
import '../lib/src/config.dart';
import '../lib/src/svg_parser.dart';

void main() {
  group('CodeGenerator', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('test_generator_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should generate icon font code with null safety', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: 'icon',
        defaultIconSize: 24,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'icon-home',
          viewBox: '0 0 1024 1024',
          paths: [
            SvgPath(
              d: 'M512 128L896 384v512H640V640H384v256H128V384z',
              fill: 'currentColor',
              attributes: {'fill': 'currentColor'},
            ),
          ],
        ),
        SvgSymbol(
          id: 'icon-user',
          viewBox: '0 0 1024 1024',
          paths: [
            SvgPath(
              d: 'M512 512c141.385 0 256-114.615 256-256S653.385 0 512 0',
              fill: '#333',
              attributes: {'fill': '#333'},
            ),
          ],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      expect(await outputFile.exists(), isTrue);

      final content = await outputFile.readAsString();
      expect(content, contains('enum IconNames'));
      expect(content, contains('home, user')); // Trimmed icon names
      expect(content, contains('class IconFont extends StatelessWidget'));
      expect(content, contains('size = 24')); // Default size
      expect(content, contains('String? color')); // Null safety
      expect(content, contains('List<String>? colors')); // Null safety
      expect(content, contains('case IconNames.home:'));
      expect(content, contains('case IconNames.user:'));
      expect(content, contains('super.key')); // Null safety syntax
    });

    test('should generate icon font code without null safety', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: 'icon',
        defaultIconSize: 18,
        nullSafety: false,
      );

      final symbols = [
        SvgSymbol(
          id: 'icon-test',
          viewBox: '0 0 1024 1024',
          paths: [
            SvgPath(
              d: 'M0 0h1024v1024H0z',
              fill: 'red',
              attributes: {'fill': 'red'},
            ),
          ],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      final content = await outputFile.readAsString();
      
      expect(content, contains('String color')); // No null safety
      expect(content, contains('List<String> colors')); // No null safety
      expect(content, contains('Key key')); // Old syntax
      expect(content, contains('size = 18')); // Default size
      expect(content, isNot(contains('String?'))); // No null safety
    });

    test('should handle icons with numeric prefixes', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: '',
        defaultIconSize: 20,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: '123test',
          viewBox: '0 0 1024 1024',
          paths: [
            SvgPath(
              d: 'M0 0h100v100H0z',
              attributes: {},
            ),
          ],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      final content = await outputFile.readAsString();
      
      expect(content, contains('_123test')); // Should add underscore for numeric start
    });

    test('should trim icon prefix correctly', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: 'ico',
        defaultIconSize: 16,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'ico-home',
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
        SvgSymbol(
          id: 'icon-user', // Different prefix, should not be trimmed
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      final content = await outputFile.readAsString();
      
      expect(content, contains('home')); // ico- prefix removed
      expect(content, contains('icon_user')); // icon- prefix not removed
    });

    test('should handle special characters in icon names', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: '',
        defaultIconSize: 18,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'test-icon-name',
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
        SvgSymbol(
          id: 'Test@Icon#Name',
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      final content = await outputFile.readAsString();
      
      expect(content, contains('test_icon_name')); // Converted to snake_case
      expect(content, contains('test_icon_name')); // Special chars converted
    });

    test('should create save directory if it does not exist', () async {
      final nonExistentDir = '${tempDir.path}/new/nested/directory';
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: nonExistentDir,
        trimIconPrefix: '',
        defaultIconSize: 18,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'test',
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('$nonExistentDir/iconfont.dart');
      expect(await outputFile.exists(), isTrue);
    });

    test('should clean existing dart files before generating', () async {
      // Create an existing dart file
      final existingFile = File('${tempDir.path}/old_icons.dart');
      await existingFile.writeAsString('// Old file content');

      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: '',
        defaultIconSize: 18,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'test',
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      expect(await existingFile.exists(), isFalse); // Should be deleted
      
      final newFile = File('${tempDir.path}/iconfont.dart');
      expect(await newFile.exists(), isTrue); // New file should exist
    });

    test('should generate correct SVG cases for multi-color icons', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: '',
        defaultIconSize: 18,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'multicolor',
          viewBox: '0 0 1024 1024',
          paths: [
            SvgPath(
              d: 'M0 0h512v512H0z',
              fill: '#ff0000',
              attributes: {'fill': '#ff0000', 'opacity': '0.8'},
            ),
            SvgPath(
              d: 'M512 512h512v512H512z',
              fill: '#00ff00',
              attributes: {'fill': '#00ff00'},
            ),
          ],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      final content = await outputFile.readAsString();
      
      expect(content, contains('getColor(0')); // First path color
      expect(content, contains('getColor(1')); // Second path color
      expect(content, contains('opacity="0.8"')); // Path attributes preserved
    });

    test('should handle empty symbols list', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: '',
        defaultIconSize: 18,
        nullSafety: true,
      );

      await CodeGenerator.generateIconFont([], config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      expect(await outputFile.exists(), isTrue);

      final content = await outputFile.readAsString();
      expect(content, contains('enum IconNames'));
      expect(content, contains('class IconFont')); // Should still generate basic structure
    });

    test('should generate string to enum conversion cases', () async {
      final config = IconFontConfig(
        symbolUrl: 'https://example.com',
        saveDir: tempDir.path,
        trimIconPrefix: 'icon',
        defaultIconSize: 18,
        nullSafety: true,
      );

      final symbols = [
        SvgSymbol(
          id: 'icon-home',
          viewBox: '0 0 1024 1024',
          paths: [SvgPath(d: 'M0 0h100v100H0z', attributes: {})],
        ),
      ];

      await CodeGenerator.generateIconFont(symbols, config);

      final outputFile = File('${tempDir.path}/iconfont.dart');
      final content = await outputFile.readAsString();
      
      expect(content, contains('case \'home\':')); // String conversion case
      expect(content, contains('return IconNames.home;')); // Return enum value
    });
  });
}
