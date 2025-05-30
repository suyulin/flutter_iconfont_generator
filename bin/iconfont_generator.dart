#!/usr/bin/env dart

import 'dart:io';
import 'package:yaml/yaml.dart';
import '../lib/src/config.dart';
import '../lib/src/fetcher.dart';
import '../lib/src/svg_parser.dart';
import '../lib/src/generator.dart';

/// Command line tool for generating iconfont
Future<void> main(List<String> arguments) async {
  try {
    print('🚀 Flutter IconFont Generator');
    print('');

    // Read configuration from pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('❌ Error: pubspec.yaml not found in current directory');
      exit(1);
    }

    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;

    final iconfontConfig = pubspec['iconfont'] as Map?;
    if (iconfontConfig == null) {
      print('❌ Error: No iconfont configuration found in pubspec.yaml');
      print('');
      print('Please add iconfont configuration to your pubspec.yaml:');
      print('');
      print('iconfont:');
      print('  symbol_url: "your_iconfont_symbol_url_here"');
      print('  save_dir: "./lib/iconfont"');
      print('  trim_icon_prefix: "icon"');
      print('  default_icon_size: 18');
      print('  null_safety: true');
      exit(1);
    }

    final config =
        IconFontConfig.fromMap(Map<String, dynamic>.from(iconfontConfig));

    if (config.symbolUrl.isEmpty || config.symbolUrl.contains('请参考README.md')) {
      print('❌ Error: Please configure a valid symbol_url in pubspec.yaml');
      exit(1);
    }

    print('📡 Fetching icons from: ${config.symbolUrl}');

    // Fetch SVG content
    final svgContent = await IconFontFetcher.fetchSvgContent(config.symbolUrl);

    // Parse symbols
    final symbols = SvgParser.parseSymbols(svgContent);

    if (symbols.isEmpty) {
      print('❌ Warning: No icons found in the SVG content');
      return;
    }

    print('✅ Found ${symbols.length} icons');

    // Generate code
    await CodeGenerator.generateIconFont(symbols, config);

    print('🎉 Successfully generated iconfont code!');
    print('📁 Output directory: ${config.saveDir}');
  } catch (e, stackTrace) {
    print('❌ Error generating iconfont: $e');
    if (arguments.contains('--verbose')) {
      print('');
      print('Stack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}
