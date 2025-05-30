import 'package:flutter_test/flutter_test.dart';
import '../lib/src/config.dart';

void main() {
  group('IconFontConfig', () {
    test('should create from map with all values', () {
      final map = {
        'symbol_url': 'https://at.alicdn.com/t/font_xxx.js',
        'save_dir': './lib/icons',
        'trim_icon_prefix': 'ico',
        'default_icon_size': 24,
        'null_safety': true,
      };

      final config = IconFontConfig.fromMap(map);

      expect(config.symbolUrl, equals('https://at.alicdn.com/t/font_xxx.js'));
      expect(config.saveDir, equals('./lib/icons'));
      expect(config.trimIconPrefix, equals('ico'));
      expect(config.defaultIconSize, equals(24));
      expect(config.nullSafety, equals(true));
    });

    test('should use default values when map is empty', () {
      final config = IconFontConfig.fromMap(<String, dynamic>{});

      expect(config.symbolUrl, equals(''));
      expect(config.saveDir, equals('./lib/iconfont'));
      expect(config.trimIconPrefix, equals('icon'));
      expect(config.defaultIconSize, equals(18));
      expect(config.nullSafety, equals(true));
    });

    test('should handle null values in map', () {
      final map = {
        'symbol_url': null,
        'save_dir': null,
        'trim_icon_prefix': null,
        'default_icon_size': null,
        'null_safety': null,
      };

      final config = IconFontConfig.fromMap(map);

      expect(config.symbolUrl, equals(''));
      expect(config.saveDir, equals('./lib/iconfont'));
      expect(config.trimIconPrefix, equals('icon'));
      expect(config.defaultIconSize, equals(18));
      expect(config.nullSafety, equals(true));
    });

    test('should convert back to map', () {
      const config = IconFontConfig(
        symbolUrl: 'https://test.com/font.js',
        saveDir: './lib/test',
        trimIconPrefix: 'test',
        defaultIconSize: 20,
        nullSafety: false,
      );

      final map = config.toMap();

      expect(map['symbol_url'], equals('https://test.com/font.js'));
      expect(map['save_dir'], equals('./lib/test'));
      expect(map['trim_icon_prefix'], equals('test'));
      expect(map['default_icon_size'], equals(20));
      expect(map['null_safety'], equals(false));
    });

    test('should handle mixed types in map', () {
      final map = {
        'symbol_url': 'https://example.com',
        'default_icon_size': '32', // String instead of int
        'null_safety': 'false', // String instead of bool
      };

      final config = IconFontConfig.fromMap(map);

      expect(config.symbolUrl, equals('https://example.com'));
      expect(config.defaultIconSize, equals('32')); // Should preserve type
      expect(config.nullSafety, equals('false')); // Should preserve type
    });
  });
}
