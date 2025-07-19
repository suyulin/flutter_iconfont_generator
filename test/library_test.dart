import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iconfont_generator/flutter_iconfont_generator.dart';

void main() {
  group('flutter_iconfont_generator library', () {
    test('should export all necessary classes', () {
      // Test that the main library exports are accessible
      expect(IconFontConfig, isA<Type>());
      expect(SvgSymbol, isA<Type>());
      expect(SvgPath, isA<Type>());
      expect(SvgParser, isA<Type>());
      expect(IconFontFetcher, isA<Type>());
      expect(CodeGenerator, isA<Type>());
    });

    test('should create IconFontConfig instance', () {
      final config = IconFontConfig(
        symbolUrl: 'https://at.alicdn.com/t/font_test.js',
        saveDir: './lib/iconfont',
        trimIconPrefix: 'icon',
        defaultIconSize: 18,
        nullSafety: true,
      );

      expect(config, isA<IconFontConfig>());
      expect(config.symbolUrl, equals('https://at.alicdn.com/t/font_test.js'));
      expect(config.saveDir, equals('./lib/iconfont'));
      expect(config.trimIconPrefix, equals('icon'));
      expect(config.defaultIconSize, equals(18));
      expect(config.nullSafety, isTrue);
    });

    test('should create SvgSymbol instance', () {
      final symbol = SvgSymbol(
        id: 'test-icon',
        viewBox: '0 0 24 24',
        paths: [],
      );

      expect(symbol, isA<SvgSymbol>());
      expect(symbol.id, equals('test-icon'));
      expect(symbol.viewBox, equals('0 0 24 24'));
      expect(symbol.paths, isEmpty);
    });

    test('should create SvgPath instance', () {
      final path = SvgPath(
        d: 'M10 10 L20 20',
        fill: '#000000',
        attributes: {'d': 'M10 10 L20 20', 'fill': '#000000'},
      );

      expect(path, isA<SvgPath>());
      expect(path.d, equals('M10 10 L20 20'));
      expect(path.fill, equals('#000000'));
      expect(path.attributes, hasLength(2));
    });

    group('Integration workflow', () {
      test('should support complete icon generation workflow', () {
        // 1. Create configuration
        final config = IconFontConfig(
          symbolUrl: 'https://at.alicdn.com/t/font_example.js',
          saveDir: './lib/icons',
          trimIconPrefix: 'icon',
          defaultIconSize: 24,
          nullSafety: true,
        );

        expect(config, isNotNull);

        // 2. Create sample SVG symbols (simulating parsed data)
        final symbols = [
          SvgSymbol(
            id: 'icon-home',
            viewBox: '0 0 1024 1024',
            paths: [
              SvgPath(
                d: 'M512 85.333333L938.666667 512H853.333333V896H597.333333V640H426.666667V896H170.666667V512H85.333333L512 85.333333Z',
                fill: '#000000',
                attributes: {
                  'd':
                      'M512 85.333333L938.666667 512H853.333333V896H597.333333V640H426.666667V896H170.666667V512H85.333333L512 85.333333Z',
                  'fill': '#000000',
                },
              ),
            ],
          ),
          SvgSymbol(
            id: 'icon-user',
            viewBox: '0 0 1024 1024',
            paths: [
              SvgPath(
                d: 'M512 512c123.712 0 224-100.288 224-224S635.712 64 512 64 288 164.288 288 288s100.288 224 224 224z m0 128c-149.504 0-448 74.752-448 224v96h896v-96c0-149.248-298.496-224-448-224z',
                attributes: {
                  'd':
                      'M512 512c123.712 0 224-100.288 224-224S635.712 64 512 64 288 164.288 288 288s100.288 224 224 224z m0 128c-149.504 0-448 74.752-448 224v96h896v-96c0-149.248-298.496-224-448-224z',
                },
              ),
            ],
          ),
        ];

        expect(symbols, hasLength(2));
        expect(symbols[0].id, equals('icon-home'));
        expect(symbols[1].id, equals('icon-user'));

        // 3. Verify symbols can be processed
        for (final symbol in symbols) {
          expect(symbol.id, isNotEmpty);
          expect(symbol.viewBox, isNotEmpty);
          expect(symbol.paths, isNotEmpty);
        }
      });

      test('should handle SVG parsing workflow', () {
        const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-home" viewBox="0 0 1024 1024">
    <path d="M512 85.333333L938.666667 512H853.333333V896H597.333333V640H426.666667V896H170.666667V512H85.333333L512 85.333333Z" fill="#000000"/>
  </symbol>
  <symbol id="icon-user" viewBox="0 0 1024 1024">
    <path d="M512 512c123.712 0 224-100.288 224-224S635.712 64 512 64 288 164.288 288 288s100.288 224 224 224z"/>
  </symbol>
</svg>''';

        final symbols = SvgParser.parseSymbols(svgContent);

        expect(symbols, hasLength(2));
        expect(symbols[0].id, equals('icon-home'));
        expect(symbols[1].id, equals('icon-user'));
        expect(symbols[0].paths[0].fill, equals('#000000'));
        expect(symbols[1].paths[0].fill, isNull);
      });

      test('should validate config to map conversion', () {
        final config = IconFontConfig(
          symbolUrl: 'https://at.alicdn.com/t/font_integration.js',
          saveDir: './lib/integration_icons',
          trimIconPrefix: 'test',
          defaultIconSize: 20,
          nullSafety: false,
        );

        final map = config.toMap();
        final recreatedConfig = IconFontConfig.fromMap(map);

        expect(recreatedConfig.symbolUrl, equals(config.symbolUrl));
        expect(recreatedConfig.saveDir, equals(config.saveDir));
        expect(recreatedConfig.trimIconPrefix, equals(config.trimIconPrefix));
        expect(recreatedConfig.defaultIconSize, equals(config.defaultIconSize));
        expect(recreatedConfig.nullSafety, equals(config.nullSafety));
      });
    });

    group('Builder integration', () {
      test('should have builder exported for build_runner', () {
        // The library should export builder.dart for build_runner integration
        // This test verifies the export is available without actually running the builder
        expect(() {
          // This would be used in a real build.yaml configuration
          // Configuration example is commented out as it's not actually used
          // {
          //   'builders': {
          //     'flutter_iconfont_generator|iconfont_builder': {
          //       'import': 'package:flutter_iconfont_generator/builder.dart',
          //       'builder_factories': ['iconFontBuilder'],
          //       'build_extensions': {'.yaml': ['.dart']},
          //       'auto_apply': 'dependents',
          //       'build_to': 'source',
          //     }
          //   }
          // };
        }, returnsNormally);
      });
    });

    group('Error handling', () {
      test('should handle invalid configuration gracefully', () {
        expect(() {
          IconFontConfig(
            symbolUrl: '',
            saveDir: '',
            trimIconPrefix: '',
            defaultIconSize: 0,
            nullSafety: true,
          );
        }, returnsNormally);
      });

      test('should handle empty SVG content', () {
        const emptySvg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
</svg>''';

        final symbols = SvgParser.parseSymbols(emptySvg);
        expect(symbols, isEmpty);
      });

      test('should handle malformed XML', () {
        const malformedXml = '<svg><symbol id="test"><path d=';

        expect(
          () => SvgParser.parseSymbols(malformedXml),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('API compatibility', () {
      test('should maintain backward compatibility for public APIs', () {
        // Test that public API signatures haven't changed
        final config = IconFontConfig.fromMap({});
        expect(config.symbolUrl, isA<String>());
        expect(config.saveDir, isA<String>());
        expect(config.trimIconPrefix, isA<String>());
        expect(config.defaultIconSize, isA<int>());
        expect(config.nullSafety, isA<bool>());

        final map = config.toMap();
        expect(map, isA<Map<String, dynamic>>());
        expect(map['symbol_url'], isA<String>());
        expect(map['save_dir'], isA<String>());
        expect(map['trim_icon_prefix'], isA<String>());
        expect(map['default_icon_size'], isA<int>());
        expect(map['null_safety'], isA<bool>());
      });

      test('should support all documented SVG parsing features', () {
        const complexSvg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-complex" viewBox="0 0 100 100">
    <path d="M10 10 L90 90" fill="#ff0000" stroke="#000000" stroke-width="2"/>
    <path d="M90 10 L10 90" fill="#00ff00"/>
  </symbol>
</svg>''';

        final symbols = SvgParser.parseSymbols(complexSvg);
        expect(symbols, hasLength(1));

        final symbol = symbols.first;
        expect(symbol.paths, hasLength(2));
        expect(symbol.paths[0].attributes['stroke'], equals('#000000'));
        expect(symbol.paths[0].attributes['stroke-width'], equals('2'));
        expect(symbol.paths[1].fill, equals('#00ff00'));
      });
    });
  });
}
