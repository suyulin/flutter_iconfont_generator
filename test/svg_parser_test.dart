import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iconfont_generator/src/svg_parser.dart';

void main() {
  group('SvgSymbol', () {
    test('should create symbol with required properties', () {
      final paths = [
        SvgPath(
          d: 'M10 10 L20 20',
          fill: '#000000',
          attributes: {'d': 'M10 10 L20 20', 'fill': '#000000'},
        ),
      ];

      final symbol = SvgSymbol(
        id: 'test-icon',
        viewBox: '0 0 24 24',
        paths: paths,
      );

      expect(symbol.id, equals('test-icon'));
      expect(symbol.viewBox, equals('0 0 24 24'));
      expect(symbol.paths, hasLength(1));
      expect(symbol.paths.first.d, equals('M10 10 L20 20'));
    });
  });

  group('SvgPath', () {
    test('should create path with required properties', () {
      final attributes = {'d': 'M10 10 L20 20', 'stroke': '#000'};
      final path = SvgPath(
        d: 'M10 10 L20 20',
        fill: '#ff0000',
        attributes: attributes,
      );

      expect(path.d, equals('M10 10 L20 20'));
      expect(path.fill, equals('#ff0000'));
      expect(path.attributes, equals(attributes));
    });

    test('should create path without fill', () {
      final path = SvgPath(
        d: 'M0 0 L10 10',
        attributes: {'d': 'M0 0 L10 10'},
      );

      expect(path.d, equals('M0 0 L10 10'));
      expect(path.fill, isNull);
      expect(path.attributes, hasLength(1));
    });
  });

  group('SvgParser', () {
    test('should parse simple SVG with single symbol', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-home" viewBox="0 0 1024 1024">
    <path d="M512 85.333333L938.666667 512H853.333333V896H597.333333V640H426.666667V896H170.666667V512H85.333333L512 85.333333Z" fill="#000000"/>
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(1));
      expect(symbols.first.id, equals('icon-home'));
      expect(symbols.first.viewBox, equals('0 0 1024 1024'));
      expect(symbols.first.paths, hasLength(1));
      expect(symbols.first.paths.first.fill, equals('#000000'));
    });

    test('should parse SVG with multiple symbols', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-home" viewBox="0 0 24 24">
    <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
  </symbol>
  <symbol id="icon-user" viewBox="0 0 24 24">
    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(2));
      expect(symbols[0].id, equals('icon-home'));
      expect(symbols[1].id, equals('icon-user'));
    });

    test('should handle symbol without id', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol viewBox="0 0 24 24">
    <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(1));
      expect(symbols.first.id, equals(''));
    });

    test('should use default viewBox when not specified', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-test">
    <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(1));
      expect(symbols.first.viewBox, equals('0 0 1024 1024'));
    });

    test('should parse paths with multiple attributes', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-complex" viewBox="0 0 100 100">
    <path d="M10 10 L90 90" fill="#ff0000" stroke="#000000" stroke-width="2" opacity="0.8"/>
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(1));
      expect(symbols.first.paths, hasLength(1));
      
      final path = symbols.first.paths.first;
      expect(path.d, equals('M10 10 L90 90'));
      expect(path.fill, equals('#ff0000'));
      expect(path.attributes['stroke'], equals('#000000'));
      expect(path.attributes['stroke-width'], equals('2'));
      expect(path.attributes['opacity'], equals('0.8'));
    });

    test('should handle empty SVG content', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, isEmpty);
    });

    test('should handle symbol with no paths', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-empty" viewBox="0 0 24 24">
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(1));
      expect(symbols.first.paths, isEmpty);
    });

    test('should handle path without d attribute', () {
      const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg">
  <symbol id="icon-no-d" viewBox="0 0 24 24">
    <path fill="#000000"/>
  </symbol>
</svg>''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols, hasLength(1));
      expect(symbols.first.paths, hasLength(1));
      expect(symbols.first.paths.first.d, equals(''));
    });

    test('should handle malformed XML gracefully', () {
      expect(
        () => SvgParser.parseSymbols('invalid xml content'),
        throwsA(isA<Exception>()),
      );
    });
  });
}