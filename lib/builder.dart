import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';
import 'src/config.dart';
import 'src/fetcher.dart';
import 'src/svg_parser.dart';

/// Builder for generating iconfont code
class IconFontBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      // Only process the trigger file
      final inputId = buildStep.inputId;
      if (!inputId.path.endsWith('iconfont.dart')) {
        return;
      }

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

      // Generate code content
      final generatedCode = _generateIconFontCode(symbols, config);

      // Write to output using BuildStep
      final outputId = inputId.changeExtension('.g.dart');
      await buildStep.writeAsString(outputId, generatedCode);

      log.info('Successfully generated iconfont code to ${outputId.path}');
    } catch (e, stackTrace) {
      log.severe('Error generating iconfont: $e', e, stackTrace);
      rethrow;
    }
  }

  String _generateIconFontCode(List<SvgSymbol> symbols, IconFontConfig config) {
    final names = <String>[];
    final cases = StringBuffer();
    final convertCases = StringBuffer();

    for (final symbol in symbols) {
      final enumName = _generateEnumCase(symbol, config);
      names.add(enumName);

      // Generate switch case for build method
      cases.writeln('      case IconNames.$enumName:');
      cases.writeln('        svgXml = \'\'\'');
      cases.write(_generateSvgCase(symbol, config));
      cases.writeln('\'\'\';');
      cases.writeln('        break;');

      // Generate string to enum conversion case
      convertCases.writeln('      case \'$enumName\':');
      convertCases.writeln('        return IconNames.$enumName;');
    }

    // Generate the Flutter code
    final template = _getTemplate(config);
    return template
        .replaceAll('#names#', names.join(', '))
        .replaceAll('#size#', config.defaultIconSize.toString())
        .replaceAll('#cases#', cases.toString().trimRight())
        .replaceAll('#convertCases#', convertCases.toString().trimRight());
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return input;

    // Clean the input: replace non-alphanumeric characters with underscores
    String cleaned = input
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase();

    // Remove leading/trailing underscores
    cleaned = cleaned.replaceAll(RegExp(r'^_+|_+$'), '');

    // If empty after cleaning, use a default
    if (cleaned.isEmpty) {
      cleaned = 'icon';
    }

    // If starts with number, add underscore
    if (RegExp(r'^\d').hasMatch(cleaned)) {
      cleaned = 'icon_$cleaned';
    }

    // Convert to camelCase
    List<String> parts = cleaned.split('_');
    if (parts.isEmpty) return 'icon';

    String result = parts[0];
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result += parts[i][0].toUpperCase() + parts[i].substring(1);
      }
    }

    return result;
  }

  String _generateEnumCase(SvgSymbol symbol, IconFontConfig config) {
    String iconId = symbol.id;

    // Remove prefix if specified
    if (config.trimIconPrefix.isNotEmpty) {
      final prefixPattern = '${config.trimIconPrefix}-';
      if (iconId.startsWith(prefixPattern)) {
        iconId = iconId.substring(prefixPattern.length);
      } else if (iconId.startsWith(config.trimIconPrefix)) {
        iconId = iconId.substring(config.trimIconPrefix.length);
      }
    }

    return _toCamelCase(iconId);
  }

  String _generateSvgCase(SvgSymbol symbol, IconFontConfig config) {
    final buffer = StringBuffer();
    buffer.writeln(
        '          <svg viewBox="${symbol.viewBox}" xmlns="http://www.w3.org/2000/svg">');

    for (int i = 0; i < symbol.paths.length; i++) {
      final path = symbol.paths[i];
      buffer.write('            <path');
      buffer.write(' d="${path.d}"');

      if (path.fill != null) {
        // Replace fill with dynamic color
        buffer.write(
            ' fill="\' + getColor($i, color, colors, \'${path.fill}\') + \'"');
      } else {
        buffer.write(
            ' fill="\' + getColor($i, color, colors, \'#333333\') + \'"');
      }

      // Add other attributes
      for (final entry in path.attributes.entries) {
        if (entry.key != 'd' && entry.key != 'fill') {
          buffer.write(' ${entry.key}="${entry.value}"');
        }
      }

      buffer.writeln(' />');
    }

    buffer.write('          </svg>');
    return buffer.toString();
  }

  String _getTemplate(IconFontConfig config) {
    if (config.nullSafety) {
      return '''
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconNames {
  #names#
}

extension IconNamesExtension on IconNames {
  String get name => toString().split('.').last;
}

/// IconFont widget for iconfont.cn icons
class IconFont extends StatelessWidget {
  const IconFont(
    this.iconName, {
    super.key,
    this.size = #size#,
    this.color,
    this.colors,
  });

  final dynamic iconName;
  final double size;
  final String? color;
  final List<String>? colors;

  IconNames get _iconName => _getIconNames(iconName);

  static IconNames _getIconNames(dynamic iconName) {
    if (iconName is IconNames) return iconName;
    
    switch (iconName.toString()) {
#convertCases#
    }
    return IconNames.values.first;
  }

  static String getColor(int index, String? color, List<String>? colors, String defaultColor) {
    if (color?.isNotEmpty == true) return color!;
    if (colors != null && colors.length > index) return colors[index];
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final String svgXml;
    
    switch (_iconName) {
#cases#
      default:
        svgXml = '';
    }

    return SvgPicture.string(
      svgXml,
      width: size,
      height: size,
    );
  }
}
''';
    } else {
      return '''
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconNames {
  #names#
}

extension IconNamesExtension on IconNames {
  String get name => toString().split('.').last;
}

/// IconFont widget for iconfont.cn icons
class IconFont extends StatelessWidget {
  final dynamic iconName;
  final double size;
  final String color;
  final List<String> colors;

  IconFont(
    this.iconName, {
    Key key,
    this.size = #size#,
    this.color,
    this.colors,
  }) : super(key: key);

  IconNames get _iconName => _getIconNames(iconName);

  static IconNames _getIconNames(dynamic iconName) {
    if (iconName is IconNames) return iconName;
    
    switch (iconName.toString()) {
#convertCases#
    }
    return IconNames.values.first;
  }

  static String getColor(int index, String color, List<String> colors, String defaultColor) {
    if (color != null && color.isNotEmpty) return color;
    if (colors != null && colors.length > index) return colors[index];
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    String svgXml;
    
    switch (_iconName) {
#cases#
      default:
        svgXml = '';
    }

    return SvgPicture.string(
      svgXml,
      width: size,
      height: size,
    );
  }
}
''';
    }
  }
}

/// Builder factory function
Builder iconFontBuilder(BuilderOptions options) => IconFontBuilder();
