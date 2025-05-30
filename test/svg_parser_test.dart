import 'package:flutter_test/flutter_test.dart';
import '../lib/src/svg_parser.dart';

void main() {
  group('SvgParser', () {
    test('should parse simple SVG symbol', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-home" viewBox="0 0 1024 1024">
            <path d="M512 128L896 384v512H640V640H384v256H128V384z" fill="currentColor"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].id, equals('icon-home'));
      expect(symbols[0].viewBox, equals('0 0 1024 1024'));
      expect(symbols[0].paths.length, equals(1));
      expect(symbols[0].paths[0].d, equals('M512 128L896 384v512H640V640H384v256H128V384z'));
      expect(symbols[0].paths[0].fill, equals('currentColor'));
    });

    test('should parse multiple symbols', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-home" viewBox="0 0 1024 1024">
            <path d="M512 128L896 384v512H640V640H384v256H128V384z" fill="#333"></path>
          </symbol>
          <symbol id="icon-user" viewBox="0 0 1024 1024">
            <path d="M512 512c141.385 0 256-114.615 256-256S653.385 0 512 0"></path>
            <path d="M512 640c-170.667 0-512 85.333-512 256v128h1024v-128c0-170.667-341.333-256-512-256z"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(2));
      expect(symbols[0].id, equals('icon-home'));
      expect(symbols[1].id, equals('icon-user'));
      expect(symbols[1].paths.length, equals(2));
    });

    test('should handle symbol without id', () {
      const svgContent = '''
        <svg>
          <symbol viewBox="0 0 1024 1024">
            <path d="M0 0h1024v1024H0z"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].id, equals(''));
      expect(symbols[0].viewBox, equals('0 0 1024 1024'));
    });

    test('should handle symbol without viewBox', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-test">
            <path d="M0 0h1024v1024H0z"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].id, equals('icon-test'));
      expect(symbols[0].viewBox, equals('0 0 1024 1024')); // Default viewBox
    });

    test('should handle path without d attribute', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-empty" viewBox="0 0 1024 1024">
            <path fill="red"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].paths.length, equals(1));
      expect(symbols[0].paths[0].d, equals(''));
      expect(symbols[0].paths[0].fill, equals('red'));
    });

    test('should parse path attributes correctly', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-complex" viewBox="0 0 1024 1024">
            <path d="M0 0h1024v1024H0z" fill="red" stroke="blue" stroke-width="2" opacity="0.5"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].paths.length, equals(1));
      
      final path = symbols[0].paths[0];
      expect(path.d, equals('M0 0h1024v1024H0z'));
      expect(path.fill, equals('red'));
      expect(path.attributes['stroke'], equals('blue'));
      expect(path.attributes['stroke-width'], equals('2'));
      expect(path.attributes['opacity'], equals('0.5'));
    });

    test('should handle empty SVG', () {
      const svgContent = '<svg></svg>';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(0));
    });

    test('should handle malformed SVG gracefully', () {
      const svgContent = '<svg><symbol><path></svg>';

      expect(() => SvgParser.parseSymbols(svgContent), throwsA(isA<Exception>()));
    });

    test('should handle symbol without paths', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-empty" viewBox="0 0 1024 1024">
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].id, equals('icon-empty'));
      expect(symbols[0].paths.length, equals(0));
    });

    test('should handle complex nested elements', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-nested" viewBox="0 0 1024 1024">
            <g>
              <path d="M0 0h512v512H0z" fill="red"></path>
              <path d="M512 512h512v512H512z" fill="blue"></path>
            </g>
            <path d="M256 256h512v512H256z" fill="green"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].paths.length, equals(3)); // Should find all paths including nested ones
    });

    test('should preserve path order', () {
      const svgContent = '''
        <svg>
          <symbol id="icon-order" viewBox="0 0 1024 1024">
            <path d="first" fill="red"></path>
            <path d="second" fill="green"></path>
            <path d="third" fill="blue"></path>
          </symbol>
        </svg>
      ''';

      final symbols = SvgParser.parseSymbols(svgContent);

      expect(symbols.length, equals(1));
      expect(symbols[0].paths.length, equals(3));
      expect(symbols[0].paths[0].d, equals('first'));
      expect(symbols[0].paths[1].d, equals('second'));
      expect(symbols[0].paths[2].d, equals('third'));
    });
  });

  group('SvgSymbol', () {
    test('should create symbol with all properties', () {
      final paths = [
        SvgPath(
          d: 'M0 0h100v100H0z',
          fill: 'red',
          attributes: {'opacity': '0.5'},
        ),
      ];

      final symbol = SvgSymbol(
        id: 'test-icon',
        viewBox: '0 0 100 100',
        paths: paths,
      );

      expect(symbol.id, equals('test-icon'));
      expect(symbol.viewBox, equals('0 0 100 100'));
      expect(symbol.paths.length, equals(1));
      expect(symbol.paths[0].d, equals('M0 0h100v100H0z'));
    });
  });

  group('SvgPath', () {
    test('should create path with all properties', () {
      final attributes = {
        'stroke': 'blue',
        'stroke-width': '2',
        'opacity': '0.8',
      };

      final path = SvgPath(
        d: 'M10 10L90 90',
        fill: 'green',
        attributes: attributes,
      );

      expect(path.d, equals('M10 10L90 90'));
      expect(path.fill, equals('green'));
      expect(path.attributes['stroke'], equals('blue'));
      expect(path.attributes['stroke-width'], equals('2'));
      expect(path.attributes['opacity'], equals('0.8'));
    });

    test('should create path without fill', () {
      final path = SvgPath(
        d: 'M0 0L100 100',
        attributes: {},
      );

      expect(path.d, equals('M0 0L100 100'));
      expect(path.fill, isNull);
      expect(path.attributes.isEmpty, isTrue);
    });
  });
}
