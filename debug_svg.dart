import 'dart:io';
import 'package:yaml/yaml.dart';
import 'lib/src/config.dart';
import 'lib/src/fetcher.dart';
import 'lib/src/svg_parser.dart';

/// Debug script to examine SVG content and symbol parsing
void main() async {
  try {
    print('🔍 Debug SVG Content and Symbol Parsing');
    print('');

    // Read configuration from pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;
    final iconfontConfig = pubspec['iconfont'] as Map;
    final config =
        IconFontConfig.fromMap(Map<String, dynamic>.from(iconfontConfig));

    print('📡 Fetching SVG content from: ${config.symbolUrl}');

    // Fetch SVG content
    final svgContent = await IconFontFetcher.fetchSvgContent(config.symbolUrl);

    print('📄 SVG Content (first 500 characters):');
    print(svgContent.substring(
        0, svgContent.length > 500 ? 500 : svgContent.length));
    print('...');
    print('');

    // Parse symbols
    final symbols = SvgParser.parseSymbols(svgContent);

    print('🔍 Found ${symbols.length} symbols:');
    for (int i = 0; i < symbols.length && i < 10; i++) {
      final symbol = symbols[i];
      print('  Symbol $i:');
      print('    ID: "${symbol.id}"');
      print('    ViewBox: "${symbol.viewBox}"');
      print('    Paths: ${symbol.paths.length}');
      print('');
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
