import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iconfont_generator/src/config.dart';

void main() {
  group('IconFontConfig', () {
    test('should create config with default values', () {
      final config = IconFontConfig(
        symbolUrl: 'https://at.alicdn.com/t/font_123.js',
        saveDir: './lib/iconfont',
        trimIconPrefix: 'icon',
        defaultIconSize: 18,
        nullSafety: true,
      );

      expect(config.symbolUrl, equals('https://at.alicdn.com/t/font_123.js'));
      expect(config.saveDir, equals('./lib/iconfont'));
      expect(config.trimIconPrefix, equals('icon'));
      expect(config.defaultIconSize, equals(18));
      expect(config.nullSafety, isTrue);
    });

    test('should create config from map with all values', () {
      final map = {
        'symbol_url': 'https://at.alicdn.com/t/font_456.js',
        'save_dir': './lib/custom_icons',
        'trim_icon_prefix': 'custom',
        'default_icon_size': 24,
        'null_safety': false,
      };

      final config = IconFontConfig.fromMap(map);

      expect(config.symbolUrl, equals('https://at.alicdn.com/t/font_456.js'));
      expect(config.saveDir, equals('./lib/custom_icons'));
      expect(config.trimIconPrefix, equals('custom'));
      expect(config.defaultIconSize, equals(24));
      expect(config.nullSafety, isFalse);
    });

    test('should create config from map with default fallbacks', () {
      final map = <String, dynamic>{};

      final config = IconFontConfig.fromMap(map);

      expect(config.symbolUrl, equals(''));
      expect(config.saveDir, equals('./lib/iconfont'));
      expect(config.trimIconPrefix, equals('icon'));
      expect(config.defaultIconSize, equals(18));
      expect(config.nullSafety, isTrue);
    });

    test('should create config from map with partial values', () {
      final map = {
        'symbol_url': 'https://at.alicdn.com/t/font_789.js',
        'default_icon_size': 32,
      };

      final config = IconFontConfig.fromMap(map);

      expect(config.symbolUrl, equals('https://at.alicdn.com/t/font_789.js'));
      expect(config.saveDir, equals('./lib/iconfont'));
      expect(config.trimIconPrefix, equals('icon'));
      expect(config.defaultIconSize, equals(32));
      expect(config.nullSafety, isTrue);
    });

    test('should convert config to map', () {
      final config = IconFontConfig(
        symbolUrl: 'https://at.alicdn.com/t/font_test.js',
        saveDir: './lib/test_icons',
        trimIconPrefix: 'test',
        defaultIconSize: 20,
        nullSafety: false,
      );

      final map = config.toMap();

      expect(map['symbol_url'], equals('https://at.alicdn.com/t/font_test.js'));
      expect(map['save_dir'], equals('./lib/test_icons'));
      expect(map['trim_icon_prefix'], equals('test'));
      expect(map['default_icon_size'], equals(20));
      expect(map['null_safety'], isFalse);
    });

    test('should handle null values in map gracefully', () {
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
      expect(config.nullSafety, isTrue);
    });

    test('should validate required symbol_url', () {
      final config = IconFontConfig(
        symbolUrl: '',
        saveDir: './lib/iconfont',
        trimIconPrefix: 'icon',
        defaultIconSize: 18,
        nullSafety: true,
      );

      expect(config.symbolUrl, isEmpty);
    });

    test('should handle edge case values', () {
      final config = IconFontConfig(
        symbolUrl: 'https://at.alicdn.com/t/font_edge.js',
        saveDir: '',
        trimIconPrefix: '',
        defaultIconSize: 0,
        nullSafety: true,
      );

      expect(config.saveDir, isEmpty);
      expect(config.trimIconPrefix, isEmpty);
      expect(config.defaultIconSize, equals(0));
    });
  });
}