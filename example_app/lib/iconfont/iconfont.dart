import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconNames {
  instance, baselineHomePx
}

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
      case 'instance':
        return IconNames.instance;
      case 'baselineHomePx':
        return IconNames.baselineHomePx;
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
      case IconNames.instance:
        svgXml = '''
          <svg viewBox="0 0 1099 1024" xmlns="http://www.w3.org/2000/svg">
            <path d="M823.296 543.744 823.296 741.376 223.744 741.376 223.744 543.744 432.64 543.744 432.64 625.152 612.352 625.152 612.352 543.744 823.296 543.744 823.808 509.44 578.56 509.44 578.56 590.848 466.944 590.848 466.944 509.44 223.744 509.44 369.152 246.784 609.792 246.784 612.352 212.48 346.624 212.48 189.44 500.736 189.44 775.168 857.6 775.168 857.6 509.44 709.632 212.48 612.352 212.48 609.792 246.784 688.128 246.784 823.808 509.44Z" fill="${getColor(0, color, colors, '#333333')}" />
            <path d="M388.608 315.392l276.992 0 0 34.304-276.992 0 0-34.304Z" fill="${getColor(1, color, colors, '#333333')}" />
            <path d="M360.96 398.336l332.288 0 0 34.304-332.288 0 0-34.304Z" fill="${getColor(2, color, colors, '#333333')}" />
          </svg>''';
        break;
      case IconNames.baselineHomePx:
        svgXml = '''
          <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
            <path d="M426.666667 853.333333v-256h170.666666v256h213.333334v-341.333333h128L512 128 85.333333 512h128v341.333333z" fill="${getColor(0, color, colors, '#333333')}" />
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
