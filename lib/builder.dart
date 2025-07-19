import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';
import 'src/config.dart';
import 'src/fetcher.dart';
import 'src/svg_parser.dart';

/// A build_runner Builder for generating Flutter IconFont widgets from iconfont.cn icons.
///
/// This builder automatically fetches SVG icons from iconfont.cn and generates
/// Flutter widgets with proper type safety and null safety support.
///
/// ## Configuration
///
/// Add the following configuration to your `pubspec.yaml`:
///
/// ```yaml
/// iconfont:
///   symbol_url: "//at.alicdn.com/t/font_xxx.js"  # Your iconfont.cn URL
///   save_dir: "./lib/iconfont"                   # Output directory
///   trim_icon_prefix: "icon"                     # Icon prefix to remove
///   default_icon_size: 18                       # Default icon size
///   null_safety: true                           # Enable null safety
/// ```
///
/// ## Build Configuration
///
/// Add this builder to your `build.yaml`:
///
/// ```yaml
/// targets:
///   $default:
///     builders:
///       flutter_iconfont_generator|iconfont_builder:
///         enabled: true
/// ```
///
/// ## Usage
///
/// 1. Create a trigger file (e.g., `lib/iconfont.dart`)
/// 2. Run `flutter packages pub run build_runner build`
/// 3. Import and use the generated icons:
///
/// ```dart
/// import 'package:your_app/iconfont.dart';
///
/// // Simple usage
/// IconFont(IconNames.home)
///
/// // With custom size and color
/// IconFont(IconNames.user, size: 24, color: '#ff0000')
///
/// // With multiple colors for multi-color icons
/// IconFont(IconNames.multiColor, colors: ['#ff0000', '#00ff00', '#0000ff'])
/// ```
///
/// ## Features
///
/// - **Type Safety**: Generated enum ensures compile-time icon name validation
/// - **Null Safety**: Full null safety support when enabled
/// - **Multi-color Icons**: Support for icons with multiple colors
/// - **Customizable**: Configurable icon sizes, prefixes, and output directories
/// - **Hot Reload**: Works seamlessly with Flutter hot reload
/// - **SVG Rendering**: Uses flutter_svg for high-quality vector rendering
///
/// ## Error Handling
///
/// The builder includes comprehensive error handling:
/// - Network failures when fetching icons
/// - Invalid SVG content
/// - Missing configuration
/// - File system errors
///
/// All errors are logged with detailed information to help with debugging.
class IconFontBuilder implements Builder {
  /// Defines the build extensions for this builder.
  ///
  /// This builder processes `.dart` files and generates `.g.dart` files
  /// containing the icon font widget code.
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart'],
      };

  /// Main build method that processes input files and generates icon font code.
  ///
  /// This method:
  /// 1. Validates the input file (must end with 'iconfont.dart')
  /// 2. Reads iconfont configuration from pubspec.yaml
  /// 3. Fetches SVG content from the configured URL
  /// 4. Parses SVG symbols and generates Flutter widget code
  /// 5. Writes the generated code to a .g.dart file
  ///
  /// Parameters:
  /// - [buildStep]: The build step context providing input/output operations
  ///
  /// Throws:
  /// - [Exception]: If there are network errors, parsing errors, or file system errors
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

  /// Generates the complete Flutter widget code from parsed SVG symbols.
  ///
  /// This method creates a complete Dart file containing:
  /// - IconNames enum with all icon identifiers
  /// - IconFont widget class with build method
  /// - Helper methods for color management and enum conversion
  ///
  /// Parameters:
  /// - [symbols]: List of parsed SVG symbols from iconfont.cn
  /// - [config]: Configuration object with generation settings
  ///
  /// Returns:
  /// - Complete Dart source code as a string
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

  /// Converts a string to camelCase format suitable for Dart identifiers.
  ///
  /// This method:
  /// 1. Removes or replaces invalid characters
  /// 2. Handles numbers at the beginning of strings
  /// 3. Converts to proper camelCase format
  /// 4. Ensures the result is a valid Dart identifier
  ///
  /// Examples:
  /// - "icon-home" → "home"
  /// - "user-circle-o" → "userCircleO"
  /// - "2-houses" → "icon2Houses"
  /// - "test_icon" → "testIcon"
  ///
  /// Parameters:
  /// - [input]: The input string to convert
  ///
  /// Returns:
  /// - A valid camelCase Dart identifier
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

  /// Generates an enum case name from an SVG symbol.
  ///
  /// This method:
  /// 1. Extracts the icon ID from the symbol
  /// 2. Removes the configured icon prefix if present
  /// 3. Converts the result to camelCase
  ///
  /// Parameters:
  /// - [symbol]: The SVG symbol to process
  /// - [config]: Configuration containing the prefix to trim
  ///
  /// Returns:
  /// - A camelCase enum identifier for the icon
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

  /// Generates the SVG case string for a symbol in the widget's switch statement.
  ///
  /// This method creates the SVG XML that will be rendered for a specific icon.
  /// It supports:
  /// - Dynamic color replacement using the getColor helper
  /// - Multiple paths within a single icon
  /// - Preservation of other SVG attributes (stroke, opacity, etc.)
  /// - Proper viewBox handling
  ///
  /// Parameters:
  /// - [symbol]: The SVG symbol to convert to a case statement
  /// - [config]: Configuration settings for the generation
  ///
  /// Returns:
  /// - SVG XML string with dynamic color placeholders
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
        buffer
            .write(' fill="\${getColor($i, color, colors, \'${path.fill}\')}"');
      } else {
        buffer.write(' fill="\${getColor($i, color, colors, \'#333333\')}"');
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

  /// Returns the Dart code template for the generated IconFont widget.
  ///
  /// The template includes:
  /// - IconNames enum declaration
  /// - IconFont StatelessWidget class
  /// - Color management helper methods
  /// - Enum conversion utilities
  /// - Proper null safety syntax when enabled
  ///
  /// The template uses placeholders that are replaced with actual values:
  /// - #names# → Comma-separated enum values
  /// - #size# → Default icon size
  /// - #cases# → Switch cases for icon rendering
  /// - #convertCases# → String to enum conversion cases
  ///
  /// Parameters:
  /// - [config]: Configuration object containing null safety and other settings
  ///
  /// Returns:
  /// - Complete Dart code template with placeholders
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

/// Builder factory function for build_runner integration.
///
/// This function is called by the build_runner framework to create
/// an instance of the IconFontBuilder.
///
/// Usage in build.yaml:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       flutter_iconfont_generator|iconfont_builder:
///         enabled: true
///         builder_factories: ["iconFontBuilder"]
/// ```
///
/// Parameters:
/// - [options]: Build options passed from the build_runner configuration
///
/// Returns:
/// - A new instance of IconFontBuilder
Builder iconFontBuilder(BuilderOptions options) => IconFontBuilder();
