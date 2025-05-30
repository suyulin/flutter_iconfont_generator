import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/src/fetcher.dart';

void main() {
  group('IconFontFetcher', () {
    test('should fetch SVG content from valid URL', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''
          var _iconfont_svg_string_123 = '<svg><symbol id="icon-home" viewBox="0 0 1024 1024"><path d="M512 128L896 384v512H640V640H384v256H128V384z" fill="currentColor"></path></symbol></svg>';
        ''', 200);
      });

      // Override the http client for testing
      final originalClient = http.Client();
      http.Client = () => mockClient;

      try {
        final result = await IconFontFetcher.fetchSvgContent('https://example.com/font.js');
        expect(result, contains('<svg'));
        expect(result, contains('<symbol'));
        expect(result, contains('icon-home'));
      } finally {
        http.Client = () => originalClient;
      }
    });

    test('should throw exception for non-HTTP URLs', () async {
      expect(
        () => IconFontFetcher.fetchSvgContent('ftp://example.com'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw exception for HTTP error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final originalClient = http.Client();
      http.Client = () => mockClient;

      try {
        expect(
          () => IconFontFetcher.fetchSvgContent('https://example.com/font.js'),
          throwsA(isA<Exception>()),
        );
      } finally {
        http.Client = () => originalClient;
      }
    });

    test('should throw exception when no SVG content found', () async {
      final mockClient = MockClient((request) async {
        return http.Response('var test = "no svg here";', 200);
      });

      final originalClient = http.Client();
      http.Client = () => mockClient;

      try {
        expect(
          () => IconFontFetcher.fetchSvgContent('https://example.com/font.js'),
          throwsA(isA<Exception>()),
        );
      } finally {
        http.Client = () => originalClient;
      }
    });

    test('should convert symbol URL to JS URL', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('js'));
        return http.Response('''
          var _iconfont_svg_string_123 = '<svg><symbol id="icon-test" viewBox="0 0 1024 1024"><path d="M0 0h1024v1024H0z"></path></symbol></svg>';
        ''', 200);
      });

      final originalClient = http.Client();
      http.Client = () => mockClient;

      try {
        await IconFontFetcher.fetchSvgContent('https://at.alicdn.com/t/font_symbol.js');
      } finally {
        http.Client = () => originalClient;
      }
    });

    test('should handle network timeout', () async {
      final mockClient = MockClient((request) async {
        await Future.delayed(Duration(seconds: 2));
        throw Exception('Connection timeout');
      });

      final originalClient = http.Client();
      http.Client = () => mockClient;

      try {
        expect(
          () => IconFontFetcher.fetchSvgContent('https://example.com/font.js'),
          throwsA(isA<Exception>()),
        );
      } finally {
        http.Client = () => originalClient;
      }
    });

    test('should extract complex SVG with multiple symbols', () async {
      final complexSvg = '''
        var _iconfont_svg_string_123 = '<svg>
          <symbol id="icon-home" viewBox="0 0 1024 1024">
            <path d="M512 128L896 384v512H640V640H384v256H128V384z" fill="#333"></path>
          </symbol>
          <symbol id="icon-user" viewBox="0 0 1024 1024">
            <path d="M512 512c141.385 0 256-114.615 256-256S653.385 0 512 0 256 114.615 256 256s114.615 256 256 256z" fill="currentColor"></path>
            <path d="M512 640c-170.667 0-512 85.333-512 256v128h1024v-128c0-170.667-341.333-256-512-256z" fill="currentColor"></path>
          </symbol>
        </svg>';
      ''';

      final mockClient = MockClient((request) async {
        return http.Response(complexSvg, 200);
      });

      final originalClient = http.Client();
      http.Client = () => mockClient;

      try {
        final result = await IconFontFetcher.fetchSvgContent('https://example.com/font.js');
        expect(result, contains('icon-home'));
        expect(result, contains('icon-user'));
        expect(result, contains('viewBox="0 0 1024 1024"'));
      } finally {
        http.Client = () => originalClient;
      }
    });
  });
}
