import 'package:xml/xml.dart';

/// Represents an SVG symbol from iconfont.cn with all its properties and paths.
///
/// Each symbol corresponds to a single icon in your iconfont project and contains
/// all the information needed to render that icon in Flutter.
///
/// Example SVG symbol:
/// ```xml
/// <symbol id="icon-home" viewBox="0 0 1024 1024">
///   <path d="M512 85.333333L938.666667 512H853.333333V896..." fill="#000000"/>
/// </symbol>
/// ```
///
/// Usage:
/// ```dart
/// final symbol = SvgSymbol(
///   id: 'icon-home',
///   viewBox: '0 0 1024 1024',
///   paths: [
///     SvgPath(
///       d: 'M512 85.333333L938.666667 512...',
///       fill: '#000000',
///       attributes: {'d': '...', 'fill': '#000000'},
///     ),
///   ],
/// );
/// ```
class SvgSymbol {
  /// The unique identifier for this icon symbol.
  ///
  /// This typically comes from the `id` attribute of the SVG `<symbol>` element
  /// and often includes a prefix like "icon-" followed by the icon name.
  ///
  /// Examples: `icon-home`, `icon-user-circle`, `my-prefix-settings`
  final String id;

  /// The viewBox attribute defining the coordinate system for this icon.
  ///
  /// This defines the position and dimension of the SVG viewport. Most iconfont.cn
  /// icons use `0 0 1024 1024` but some may use different dimensions like `0 0 24 24`.
  ///
  /// Format: `"minX minY width height"`
  ///
  /// Examples: `0 0 1024 1024`, `0 0 24 24`, `0 0 100 100`
  final String viewBox;

  /// List of SVG path elements that make up this icon.
  ///
  /// Most simple icons have a single path, but complex icons may have multiple
  /// paths with different colors, strokes, or other attributes. Each path
  /// represents a portion of the icon's visual appearance.
  final List<SvgPath> paths;

  /// Creates a new SvgSymbol with the specified properties.
  ///
  /// Parameters:
  /// - [id]: The unique identifier for this symbol
  /// - [viewBox]: The SVG viewBox coordinate system
  /// - [paths]: List of paths that make up this icon
  SvgSymbol({
    required this.id,
    required this.viewBox,
    required this.paths,
  });
}

/// Represents an SVG path element with its drawing commands and styling.
///
/// Each path defines a portion of an icon using SVG path commands (like moveTo,
/// lineTo, curveTo, etc.) and may include styling attributes like fill color,
/// stroke, opacity, etc.
///
/// Example SVG path:
/// ```xml
/// <path d="M10 10 L90 90" fill="#ff0000" stroke="#000000" stroke-width="2"/>
/// ```
///
/// Usage:
/// ```dart
/// final path = SvgPath(
///   d: 'M10 10 L90 90',
///   fill: '#ff0000',
///   attributes: {
///     'd': 'M10 10 L90 90',
///     'fill': '#ff0000',
///     'stroke': '#000000',
///     'stroke-width': '2',
///   },
/// );
/// ```
class SvgPath {
  /// The path drawing commands in SVG path data format.
  ///
  /// This string contains SVG path commands that define the shape of this
  /// path element. Commands include:
  /// - M/m: moveTo (absolute/relative)
  /// - L/l: lineTo (absolute/relative)
  /// - C/c: curveTo (absolute/relative)
  /// - Z/z: closePath
  /// - And many others
  ///
  /// Example: `M512 85.333333L938.666667 512H853.333333V896H597.333333Z`
  final String d;

  /// The fill color for this path, if specified.
  ///
  /// This can be:
  /// - A hex color like `#ff0000` or `#f00`
  /// - A named color like `red`, `blue`, `currentColor`
  /// - `null` if no fill is specified (uses default)
  ///
  /// When generating Flutter code, this will be replaced with dynamic color
  /// support to allow runtime color customization.
  final String? fill;

  /// All attributes from the original SVG path element.
  ///
  /// This map contains all attributes that were present on the original
  /// `<path>` element, including:
  /// - `d`: The path drawing commands
  /// - `fill`: Fill color (if specified)
  /// - `stroke`: Stroke color (if specified)
  /// - `stroke-width`: Stroke width (if specified)
  /// - `opacity`: Opacity value (if specified)
  /// - And any other SVG attributes
  ///
  /// This allows preservation of all styling information for accurate rendering.
  final Map<String, String> attributes;

  /// Creates a new SvgPath with the specified properties.
  ///
  /// Parameters:
  /// - [d]: The SVG path drawing commands
  /// - [fill]: Optional fill color for this path
  /// - [attributes]: Map of all attributes from the original SVG element
  SvgPath({
    required this.d,
    this.fill,
    required this.attributes,
  });
}

/// Parser for extracting SVG symbols and paths from iconfont.cn SVG content.
///
/// This class handles the parsing of SVG content fetched from iconfont.cn and
/// converts it into structured [SvgSymbol] and [SvgPath] objects that can be
/// used for code generation.
///
/// ## Supported SVG Structure
///
/// The parser expects SVG content in the format used by iconfont.cn:
/// ```xml
/// <?xml version="1.0" encoding="UTF-8"?>
/// <svg xmlns="http://www.w3.org/2000/svg">
///   <symbol id="icon-home" viewBox="0 0 1024 1024">
///     <path d="..." fill="#000000"/>
///     <path d="..." fill="#ff0000"/>
///   </symbol>
///   <symbol id="icon-user" viewBox="0 0 1024 1024">
///     <path d="..."/>
///   </symbol>
/// </svg>
/// ```
///
/// ## Features
///
/// - Parses multiple symbols from a single SVG document
/// - Extracts all path elements within each symbol
/// - Preserves all SVG attributes for accurate rendering
/// - Handles missing attributes with sensible defaults
/// - Supports complex multi-path icons
///
/// ## Usage
///
/// ```dart
/// const svgContent = '''<?xml version="1.0" encoding="UTF-8"?>
/// <svg xmlns="http://www.w3.org/2000/svg">
///   <symbol id="icon-home" viewBox="0 0 1024 1024">
///     <path d="M512 85.333333L938.666667 512..." fill="#000000"/>
///   </symbol>
/// </svg>''';
///
/// final symbols = SvgParser.parseSymbols(svgContent);
/// print('Found ${symbols.length} icons');
/// 
/// for (final symbol in symbols) {
///   print('Icon: ${symbol.id}');
///   print('Paths: ${symbol.paths.length}');
/// }
/// ```
class SvgParser {
  /// Parses SVG content and extracts all symbol definitions.
  ///
  /// This method takes raw SVG content (typically fetched from iconfont.cn)
  /// and parses it to extract all `<symbol>` elements and their contained
  /// `<path>` elements.
  ///
  /// ## Processing Steps
  ///
  /// 1. Parse the SVG XML document
  /// 2. Find all `<symbol>` elements
  /// 3. For each symbol:
  ///    - Extract the `id` attribute (defaults to empty string)
  ///    - Extract the `viewBox` attribute (defaults to "0 0 1024 1024")
  ///    - Find all `<path>` elements within the symbol
  ///    - Extract path data and attributes
  /// 4. Return a list of [SvgSymbol] objects
  ///
  /// ## Error Handling
  ///
  /// - Throws [XmlException] if the SVG content is malformed
  /// - Missing attributes are handled with sensible defaults
  /// - Empty symbols (no paths) are included in the result
  ///
  /// Parameters:
  /// - [svgContent]: Raw SVG content as a string
  ///
  /// Returns:
  /// - List of [SvgSymbol] objects representing all icons found
  ///
  /// Throws:
  /// - [XmlException]: If the SVG content cannot be parsed
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final symbols = SvgParser.parseSymbols(svgContent);
  ///   print('Successfully parsed ${symbols.length} icons');
  /// } catch (e) {
  ///   print('Failed to parse SVG: $e');
  /// }
  /// ```
  static List<SvgSymbol> parseSymbols(String svgContent) {
    final document = XmlDocument.parse(svgContent);
    final symbols = document.findAllElements('symbol');

    return symbols.map((symbol) {
      final id = symbol.getAttribute('id') ?? '';
      final viewBox = symbol.getAttribute('viewBox') ?? '0 0 1024 1024';

      final paths = symbol.findAllElements('path').map((path) {
        final d = path.getAttribute('d') ?? '';
        final fill = path.getAttribute('fill');

        final attributes = <String, String>{};
        for (final attr in path.attributes) {
          attributes[attr.name.local] = attr.value;
        }

        return SvgPath(
          d: d,
          fill: fill,
          attributes: attributes,
        );
      }).toList();

      return SvgSymbol(
        id: id,
        viewBox: viewBox,
        paths: paths,
      );
    }).toList();
  }
}
