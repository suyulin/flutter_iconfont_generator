import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconNames { baselineHomePx }

extension IconNamesExtension on IconNames {
  String get name => toString().split('.').last;
}

/// IconFont widget for iconfont.cn icons
class IconFont extends StatelessWidget {
  const IconFont(
    this.iconName, {
    super.key,
    this.size = 18,
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
      case 'baselineHomePx':
        return IconNames.baselineHomePx;
    }
    return IconNames.values.first;
  }

  static String getColor(
      int index, String? color, List<String>? colors, String defaultColor) {
    if (color?.isNotEmpty == true) return color!;
    if (colors != null && colors.length > index) return colors[index];
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final String svgXml;

    switch (_iconName) {
      case IconNames.baselineHomePx:
        svgXml = '''
          <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
            <path d="M426.666667 853.333333v-256h170.666666v256h213.333334v-341.333333h128L512 128 85.333333 512h128v341.333333z" fill="' + getColor(0, color, colors, '#333333') + '" />
          </svg>''';
        break;
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
