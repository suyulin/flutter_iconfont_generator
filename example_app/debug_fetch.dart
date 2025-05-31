import 'dart:io';
import 'package:yaml/yaml.dart';
import '../lib/src/config.dart';
import '../lib/src/fetcher.dart';
import '../lib/src/svg_parser.dart';

Future<void> main() async {
  try {
    print('Debug: Reading pubspec.yaml');
    final pubspecContent = await File('pubspec.yaml').readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;

    final iconfontConfig = pubspec['iconfont'] as Map?;
    if (iconfontConfig == null) {
      print('Error: No iconfont config found');
      return;
    }

    final config =
        IconFontConfig.fromMap(Map<String, dynamic>.from(iconfontConfig));
    print('Debug: Symbol URL: ${config.symbolUrl}');

    print('Debug: Fetching SVG content...');
    final svgContent = await IconFontFetcher.fetchSvgContent(config.symbolUrl);
    print('Debug: SVG content length: ${svgContent.length}');
    print(
        'Debug: First 500 chars of SVG: ${svgContent.substring(0, svgContent.length > 500 ? 500 : svgContent.length)}');

    print('Debug: Parsing symbols...');
    final symbols = SvgParser.parseSymbols(svgContent);
    print('Debug: Found ${symbols.length} symbols');

    if (symbols.isNotEmpty) {
      print('Debug: First symbol: ${symbols.first.id}');
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
