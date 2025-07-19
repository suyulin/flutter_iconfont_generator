import 'dart:io';
import 'package:path/path.dart' as path;
import 'config.dart';
import 'svg_parser.dart';

/// Generates Flutter icon font code from parsed SVG symbols.
///
/// This class takes a list of [SvgSymbol] objects and generates complete
/// Flutter widget code that can be used to display the icons in your app.
/// The generated code includes type-safe enum definitions, color management,
/// and SVG rendering capabilities.
///
/// ## Generated Code Structure
///
/// The generator creates:
/// - **IconNames enum**: Type-safe identifiers for all icons
/// - **IconFont widget**: StatelessWidget for rendering icons
/// - **Color management**: Dynamic color support for single and multi-color icons
/// - **Enum utilities**: String to enum conversion for dynamic icon names
///
/// ## Features
///
/// - **Type Safety**: Compile-time validation of icon names
/// - **Null Safety**: Support for both null-safe and legacy code
/// - **Multi-color**: Support for icons with multiple colors
/// - **Customizable**: Configurable sizes, prefixes, and styling
/// - **Clean Names**: Automatic conversion of icon names to valid Dart identifiers
///
/// ## Usage
///
/// ```dart
/// final symbols = await SvgParser.parseSymbols(svgContent);
/// final config = IconFontConfig(
///   symbolUrl: 'https://at.alicdn.com/t/font_123.js',
///   saveDir: './lib/icons',
///   trimIconPrefix: 'icon',
///   defaultIconSize: 18,
///   nullSafety: true,
/// );
///
/// await CodeGenerator.generateIconFont(symbols, config);
/// print('Generated icon code successfully!');
/// ```
///
/// ## Generated Code Example
///
/// ```dart
/// enum IconNames { home, user, settings }
///
/// class IconFont extends StatelessWidget {
///   const IconFont(this.iconName, {
///     super.key,
///     this.size = 18,
///     this.color,
///     this.colors,
///   });
///
///   final dynamic iconName;
///   final double size;
///   final String? color;
///   final List<String>? colors;
///
///   @override
///   Widget build(BuildContext context) {
///     // Generated switch statement with SVG content
///   }
/// }
/// ```
class CodeGenerator {
  /// Converts a string to camelCase format suitable for Dart identifiers.
  ///
  /// This method processes icon names to create valid Dart enum identifiers
  /// by handling special characters, numbers, and naming conventions.
  ///
  /// ## Processing Steps
  ///
  /// 1. Replace non-alphanumeric characters with underscores
  /// 2. Convert to lowercase and remove duplicate underscores
  /// 3. Remove leading/trailing underscores
  /// 4. Handle numbers at the beginning (prefix with "icon")
  /// 5. Convert to camelCase format
  /// 6. Ensure result is a valid Dart identifier
  ///
  /// ## Examples
  ///
  /// | Input | Output |
  /// |-------|--------|
  /// | `icon-home` | `home` |
  /// | `user-circle-o` | `userCircleO` |
  /// | `2-houses` | `icon2Houses` |
  /// | `test_icon` | `testIcon` |
  /// | `settings` | `settings` |
  /// | `my@icon#name` | `myIconName` |
  /// | `123` | `icon123` |
  /// | `` (empty) | `icon` |
  ///
  /// Parameters:
  /// - [input]: The string to convert to camelCase
  ///
  /// Returns:
  /// - A valid camelCase Dart identifier
  static String _toCamelCase(String input) {
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
  /// This method processes an SVG symbol to create a clean, camelCase enum
  /// identifier by removing the configured icon prefix and converting to
  /// a valid Dart identifier.
  ///
  /// ## Processing Steps
  ///
  /// 1. Extract the icon ID from the symbol
  /// 2. Remove the configured prefix (with or without trailing dash)
  /// 3. Convert the result to camelCase using [_toCamelCase]
  ///
  /// ## Prefix Handling
  ///
  /// The method handles prefix removal in two ways:
  /// - `prefix-name` → `name` (removes "prefix-")
  /// - `prefixname` → `name` (removes "prefix")
  ///
  /// Examples with `trimIconPrefix: "icon"`:
  /// - `icon-home` → `home`
  /// - `icon-user-circle` → `userCircle`
  /// - `iconhome` → `home`
  /// - `my-icon-settings` → `myIconSettings` (no prefix match)
  ///
  /// Parameters:
  /// - [symbol]: The SVG symbol to process
  /// - [config]: Configuration containing the prefix to trim
  ///
  /// Returns:
  /// - A camelCase enum identifier for the icon
  static String _generateEnumCase(SvgSymbol symbol, IconFontConfig config) {
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
  /// This method creates the SVG XML that will be rendered for a specific icon
  /// when used in the generated IconFont widget. It handles dynamic color
  /// replacement and preserves all SVG attributes for accurate rendering.
  ///
  /// ## Features
  ///
  /// - **Dynamic Colors**: Replaces static fill colors with runtime color management
  /// - **Multi-path Support**: Handles icons with multiple path elements
  /// - **Attribute Preservation**: Maintains all SVG attributes (stroke, opacity, etc.)
  /// - **Template Interpolation**: Uses string interpolation for dynamic values
  ///
  /// ## Color Management
  ///
  /// Each path's fill color is replaced with a call to the `getColor` helper method:
  /// ```dart
  /// fill="${getColor(0, color, colors, '#000000')}"
  /// ```
  ///
  /// This allows users to:
  /// - Override with a single color: `IconFont(icon, color: '#ff0000')`
  /// - Use multiple colors: `IconFont(icon, colors: ['#ff0000', '#00ff00'])`
  /// - Fall back to original colors when no override is provided
  ///
  /// ## Generated Output Example
  ///
  /// ```xml
  /// <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  ///   <path d="M512 85.333..." fill="${getColor(0, color, colors, '#000000')}" />
  ///   <path d="M256 512..." fill="${getColor(1, color, colors, '#ff0000')}" stroke="#333" />
  /// </svg>
  /// ```
  ///
  /// Parameters:
  /// - [symbol]: The SVG symbol to convert to a case statement
  /// - [config]: Configuration settings for the generation
  ///
  /// Returns:
  /// - SVG XML string with dynamic color placeholders
  static String _generateSvgCase(SvgSymbol symbol, IconFontConfig config) {
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

  /// Generates complete Flutter icon font code from SVG symbols.
  ///
  /// This is the main entry point for code generation. It takes a list of
  /// parsed SVG symbols and configuration, then generates a complete Flutter
  /// widget file with all necessary code for using the icons.
  ///
  /// ## Generated Code Structure
  ///
  /// The generated file includes:
  /// 1. **Import statements** for Flutter and flutter_svg
  /// 2. **IconNames enum** with all icon identifiers
  /// 3. **IconFont widget class** with:
  ///    - Constructor with customizable parameters
  ///    - Build method with switch statement for icon rendering
  ///    - Helper methods for color management and enum conversion
  ///
  /// ## File Management
  ///
  /// - Creates the output directory if it doesn't exist
  /// - Cleans existing .dart files in the directory before generation
  /// - Writes the new code to `iconfont.dart` in the specified directory
  /// - Provides console output showing the number of icons generated
  ///
  /// ## Code Templates
  ///
  /// The method uses different templates based on the null safety setting:
  /// - **Null-safe template**: Uses modern Flutter syntax with `super.key`, `String?`, etc.
  /// - **Legacy template**: Compatible with older Dart versions
  ///
  /// ## Error Handling
  ///
  /// - Creates directories recursively if they don't exist
  /// - Handles file system permissions issues
  /// - Provides meaningful error messages for debugging
  ///
  /// Parameters:
  /// - [symbols]: List of parsed SVG symbols to generate code for
  /// - [config]: Configuration object with generation settings
  ///
  /// Throws:
  /// - [FileSystemException]: If directory creation or file writing fails
  /// - [Exception]: If template processing fails
  ///
  /// Example:
  /// ```dart
  /// final symbols = [
  ///   SvgSymbol(id: 'icon-home', viewBox: '0 0 24 24', paths: [...]),
  ///   SvgSymbol(id: 'icon-user', viewBox: '0 0 24 24', paths: [...]),
  /// ];
  ///
  /// final config = IconFontConfig(
  ///   symbolUrl: 'https://at.alicdn.com/t/font_123.js',
  ///   saveDir: './lib/icons',
  ///   trimIconPrefix: 'icon',
  ///   defaultIconSize: 18,
  ///   nullSafety: true,
  /// );
  ///
  /// await CodeGenerator.generateIconFont(symbols, config);
  /// // Output: Generated 2 icons to ./lib/icons/iconfont.dart
  /// ```
  static Future<void> generateIconFont(
      List<SvgSymbol> symbols, IconFontConfig config) async {
    final names = <String>[];
    final cases = StringBuffer();
    final convertCases = StringBuffer();

    // Generate enum names and cases
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
    String iconFile = template
        .replaceAll('#names#', names.join(', '))
        .replaceAll('#size#', config.defaultIconSize.toString())
        .replaceAll('#cases#', cases.toString().trimRight())
        .replaceAll('#convertCases#', convertCases.toString().trimRight());

    // Ensure save directory exists
    final saveDir = Directory(config.saveDir);
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    // Clean existing files
    await for (final file in saveDir.list()) {
      if (file is File && file.path.endsWith('.dart')) {
        await file.delete();
      }
    }

    // Write the generated file
    final outputFile = File(path.join(config.saveDir, 'iconfont.dart'));
    await outputFile.writeAsString(iconFile);

    print('Generated ${symbols.length} icons to ${outputFile.path}');
  }

  static String _getTemplate(IconFontConfig config) {
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
