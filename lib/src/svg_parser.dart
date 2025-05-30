import 'package:xml/xml.dart';

/// Represents an SVG symbol from iconfont
class SvgSymbol {
  final String id;
  final String viewBox;
  final List<SvgPath> paths;

  SvgSymbol({
    required this.id,
    required this.viewBox,
    required this.paths,
  });
}

/// Represents an SVG path element
class SvgPath {
  final String d;
  final String? fill;
  final Map<String, String> attributes;

  SvgPath({
    required this.d,
    this.fill,
    required this.attributes,
  });
}

/// Parser for iconfont SVG data
class SvgParser {
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
