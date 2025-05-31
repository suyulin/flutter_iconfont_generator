#!/usr/bin/env dart

import 'dart:io';
import 'package:yaml/yaml.dart';
import '../lib/src/config.dart';
import '../lib/src/fetcher.dart';
import '../lib/src/svg_parser.dart';
import '../lib/src/generator.dart';

/// Command line tool for generating iconfont
Future<void> main(List<String> arguments) async {
  final verbose = arguments.contains('--verbose') || arguments.contains('-v');
  final showHelp = arguments.contains('--help') || arguments.contains('-h');

  if (showHelp) {
    _showUsage();
    return;
  }

  try {
    print('🚀 Flutter IconFont Generator v2.0.0');
    if (verbose) print('Running with verbose output...');
    print('');

    // Read configuration
    final configPath = _getOptionValue(arguments, '--config') ?? 'pubspec.yaml';
    final configFile = File(configPath);
    if (!await configFile.exists()) {
      print('❌ Error: Configuration file not found: $configPath');
      print('   Please run this command in your Flutter project root');
      print('');
      _showConfigExample();
      exit(1);
    }

    final pubspecContent = await configFile.readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;

    final iconfontConfig = pubspec['iconfont'] as Map?;
    if (iconfontConfig == null) {
      print('❌ Error: No iconfont configuration found in $configPath');
      print('');
      _showConfigExample();
      exit(1);
    }

    // Create config and apply command line overrides
    final config =
        IconFontConfig.fromMap(Map<String, dynamic>.from(iconfontConfig));
    final finalConfig = _applyCommandLineOverrides(config, arguments);

    if (finalConfig.symbolUrl.isEmpty ||
        finalConfig.symbolUrl.contains('请参考README.md')) {
      print('❌ Error: Please configure a valid symbol_url');
      print('   Use --url option or configure it in $configPath');
      print('   Get your symbol URL from iconfont.cn project settings');
      exit(1);
    }

    if (verbose) {
      print('📋 Configuration:');
      print('   Symbol URL: ${finalConfig.symbolUrl}');
      print('   Output Directory: ${finalConfig.saveDir}');
      print('   Trim Prefix: ${finalConfig.trimIconPrefix}');
      print('   Default Size: ${finalConfig.defaultIconSize}');
      print('   Null Safety: ${finalConfig.nullSafety}');
      print('');
    }

    print('📡 Fetching icons from iconfont.cn...');

    // Fetch SVG content
    final svgContent =
        await IconFontFetcher.fetchSvgContent(finalConfig.symbolUrl);
    if (verbose) print('✅ Fetched ${svgContent.length} characters of SVG data');

    // Parse symbols
    final symbols = SvgParser.parseSymbols(svgContent);

    if (symbols.isEmpty) {
      print('❌ Warning: No icons found in the SVG content');
      print('   Please check your symbol_url configuration');
      return;
    }

    print('✅ Found ${symbols.length} icons');
    if (verbose) {
      print('   Icons: ${symbols.map((s) => s.id).join(', ')}');
    }

    // Generate code
    await CodeGenerator.generateIconFont(symbols, finalConfig);

    print('🎉 Successfully generated iconfont code!');
    print('📁 Output: ${finalConfig.saveDir}/iconfont.dart');
    print('');
    print('💡 Usage in your Flutter app:');
    print(
        '   import \'package:your_app/${finalConfig.saveDir.replaceAll('./', '')}/iconfont.dart\';');
    print('   IconFont(IconNames.yourIconName)');
  } catch (e, stackTrace) {
    print('❌ Error generating iconfont: $e');
    if (verbose) {
      print('');
      print('Stack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}

IconFontConfig _applyCommandLineOverrides(
    IconFontConfig config, List<String> arguments) {
  return IconFontConfig(
    symbolUrl: _getOptionValue(arguments, '--url') ?? config.symbolUrl,
    saveDir: _getOptionValue(arguments, '--output') ?? config.saveDir,
    trimIconPrefix:
        _getOptionValue(arguments, '--prefix') ?? config.trimIconPrefix,
    defaultIconSize: int.tryParse(_getOptionValue(arguments, '--size') ?? '') ??
        config.defaultIconSize,
    nullSafety: config.nullSafety,
  );
}

/// Get command line option value
String? _getOptionValue(List<String> args, String option) {
  for (int i = 0; i < args.length - 1; i++) {
    if (args[i] == option) {
      return args[i + 1];
    }
  }
  return null;
}

void _showUsage() {
  print(
      'Flutter IconFont Generator - Generate Flutter icon widgets from iconfont.cn');
  print('');
  print('Usage: iconfont_generator [options]');
  print('');
  print('Options:');
  print('  -h, --help            Show this help message');
  print('  -v, --verbose         Show detailed output');
  print('  --config FILE         Configuration file (default: pubspec.yaml)');
  print('  --url URL             Symbol URL from iconfont.cn');
  print('  --output DIR          Output directory (default: ./lib/iconfont)');
  print('  --prefix PREFIX       Icon prefix to trim (default: icon)');
  print('  --size SIZE           Default icon size (default: 18)');
  print('');
  print('Examples:');
  print(
      '  iconfont_generator                                    # Use pubspec.yaml config');
  print('  iconfont_generator --url "//at.alicdn.com/..." --output lib/icons');
  print(
      '  iconfont_generator --verbose                          # Show detailed output');
  print(
      '  iconfont_generator --help                             # Show this help');
}

void _showConfigExample() {
  print('Please add iconfont configuration to your pubspec.yaml:');
  print('');
  print('iconfont:');
  print(
      '  symbol_url: "//at.alicdn.com/t/c/font_xxx_xxx.js"  # Your iconfont.cn symbol URL');
  print(
      '  save_dir: "./lib/iconfont"                          # Output directory');
  print(
      '  trim_icon_prefix: "icon"                            # Prefix to remove from icon names');
  print(
      '  default_icon_size: 18                               # Default icon size');
  print(
      '  null_safety: true                                   # Enable null safety');
  print('');
  print('Get your symbol URL from iconfont.cn project settings.');
}
