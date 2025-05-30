import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';
import 'src/config.dart';
import 'src/fetcher.dart';
import 'src/svg_parser.dart';
import 'src/generator.dart';

/// Builder for generating iconfont code
class IconFontBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      // Read pubspec.yaml to get iconfont configuration
      final pubspecContent = await File('pubspec.yaml').readAsString();
      final pubspec = loadYaml(pubspecContent) as Map;

      final iconfontConfig = pubspec['iconfont'] as Map?;
      if (iconfontConfig == null) {
        log.warning('No iconfont configuration found in pubspec.yaml');
        return;
      }

      final config =
          IconFontConfig.fromMap(Map<String, dynamic>.from(iconfontConfig));

      if (config.symbolUrl.isEmpty ||
          config.symbolUrl.contains('请参考README.md')) {
        log.warning('Please configure a valid symbol_url in pubspec.yaml');
        return;
      }

      log.info('Fetching icons from: ${config.symbolUrl}');

      // Fetch SVG content
      final svgContent =
          await IconFontFetcher.fetchSvgContent(config.symbolUrl);

      // Parse symbols
      final symbols = SvgParser.parseSymbols(svgContent);

      if (symbols.isEmpty) {
        log.warning('No icons found in the SVG content');
        return;
      }

      log.info('Found ${symbols.length} icons');

      // Generate code
      await CodeGenerator.generateIconFont(symbols, config);

      log.info('Successfully generated iconfont code');
    } catch (e, stackTrace) {
      log.severe('Error generating iconfont: $e', e, stackTrace);
      rethrow;
    }
  }
}

/// Builder factory function
Builder iconFontBuilder(BuilderOptions options) => IconFontBuilder();
