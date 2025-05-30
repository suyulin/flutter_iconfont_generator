#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

/// 简化的 IconFont 生成器
Future<void> main(List<String> arguments) async {
  try {
    print('🚀 Flutter IconFont Generator (Simple Version)');

    // 读取配置
    final pubspecContent = await File('pubspec.yaml').readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;
    final config = pubspec['iconfont'] as Map?;

    if (config == null) {
      print('❌ No iconfont configuration found');
      exit(1);
    }

    final symbolUrl = config['symbol_url'] as String;
    final saveDir = config['save_dir'] as String? ?? './lib/iconfont';
    final defaultSize = config['default_icon_size'] as int? ?? 18;
    final nullSafety = config['null_safety'] as bool? ?? true;

    if (symbolUrl.contains('请参考') || symbolUrl.isEmpty) {
      print('❌ Please set a valid symbol_url in pubspec.yaml');
      exit(1);
    }

    print('📡 Fetching from: $symbolUrl');

    // 获取 JS 内容
    String jsUrl = symbolUrl;
    if (jsUrl.contains('symbol')) {
      jsUrl = jsUrl.replaceAll('symbol', 'js');
    }
    if (!jsUrl.startsWith('http')) {
      jsUrl = 'https:$jsUrl';
    }

    final response = await http.get(Uri.parse(jsUrl));
    if (response.statusCode != 200) {
      print('❌ Failed to fetch: ${response.statusCode}');
      exit(1);
    }

    // 简单的图标提取
    final content = response.body;
    final symbolMatches =
        RegExp(r'<symbol[^>]*id="([^"]*)"[^>]*>(.*?)</symbol>', dotAll: true)
            .allMatches(content);

    if (symbolMatches.isEmpty) {
      print('❌ No symbols found');
      exit(1);
    }

    print('✅ Found ${symbolMatches.length} icons');

    // 生成代码
    final enumNames = <String>[];
    final cases = StringBuffer();
    final convertCases = StringBuffer();

    for (final match in symbolMatches) {
      final id = match.group(1)!;
      final svgContent = match.group(2)!;

      // 处理图标名
      String enumName = id.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      if (RegExp(r'^\d').hasMatch(enumName)) {
        enumName = '_$enumName';
      }

      enumNames.add(enumName);

      // 生成 switch case
      cases.writeln('      case IconNames.$enumName:');
      cases.writeln('        svgXml = \'\'\'');
      cases.writeln(
          '          <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">');
      cases.writeln('            $svgContent');
      cases.writeln('          </svg>\'\'\';');
      cases.writeln('        break;');

      // 生成字符串转换
      convertCases.writeln('      case \'$enumName\':');
      convertCases.writeln('        return IconNames.$enumName;');
    }

    // 生成文件内容
    final template =
        nullSafety ? _getNullSafetyTemplate() : _getRegularTemplate();
    final generated = template
        .replaceAll('#names#', enumNames.join(', '))
        .replaceAll('#size#', defaultSize.toString())
        .replaceAll('#cases#', cases.toString().trim())
        .replaceAll('#convertCases#', convertCases.toString().trim());

    // 创建输出目录
    final outputDir = Directory(saveDir);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    // 写入文件
    final outputFile = File('$saveDir/iconfont.dart');
    await outputFile.writeAsString(generated);

    print('🎉 Successfully generated ${enumNames.length} icons');
    print('📁 Output: ${outputFile.path}');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    if (arguments.contains('--verbose')) {
      print(stackTrace);
    }
    exit(1);
  }
}

String _getNullSafetyTemplate() {
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
}

String _getRegularTemplate() {
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
