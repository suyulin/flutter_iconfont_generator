#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  try {
    print('🚀 Starting Flutter IconFont Generator');

    // 读取配置
    final pubspecContent = await File('pubspec.yaml').readAsString();
    final pubspec = loadYaml(pubspecContent) as Map;
    final config = pubspec['iconfont'] as Map?;

    if (config == null) {
      print('❌ No iconfont configuration found');
      return;
    }

    final symbolUrl = config['symbol_url'] as String;
    final saveDir = config['save_dir'] as String? ?? './lib/iconfont';

    print('📡 Fetching from: $symbolUrl');

    // 处理 URL
    String jsUrl = symbolUrl;
    if (!jsUrl.startsWith('http')) {
      jsUrl = 'https:$jsUrl';
    }

    print('🌐 Full URL: $jsUrl');

    // 获取内容
    final response = await http.get(Uri.parse(jsUrl));
    print('📊 Response status: ${response.statusCode}');
    print('📏 Response length: ${response.body.length}');

    if (response.statusCode != 200) {
      print('❌ Failed to fetch: ${response.statusCode}');
      return;
    }

    // 解析符号
    final content = response.body;
    final symbolMatches =
        RegExp(r'<symbol[^>]*id="([^"]*)"[^>]*>(.*?)</symbol>', dotAll: true)
            .allMatches(content);

    print('🔍 Found ${symbolMatches.length} symbols');

    if (symbolMatches.isEmpty) {
      print('❌ No symbols found in response');
      print(
          'Response preview: ${content.substring(0, content.length > 200 ? 200 : content.length)}');
      return;
    }

    // 生成枚举名和代码
    final enumNames = <String>[];
    final cases = StringBuffer();

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
      cases.writeln(
          '        svgXml = \'\'\'<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">$svgContent</svg>\'\'\';');
      cases.writeln('        break;');
    }

    // 生成 Dart 文件
    final dartCode = '''
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconNames {
  ${enumNames.join(', ')}
}

extension IconNamesExtension on IconNames {
  String get name => toString().split('.').last;
}

class IconFont extends StatelessWidget {
  const IconFont(
    this.iconName, {
    super.key,
    this.size = 18,
    this.color,
    this.colors,
  });

  final IconNames iconName;
  final double size;
  final Color? color;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    String svgXml;
    
    switch (iconName) {
${cases.toString().trimRight()}
      default:
        svgXml = '<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"></svg>';
    }

    return SvgPicture.string(
      svgXml,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
''';

    // 创建目录并写入文件
    final outputDir = Directory(saveDir);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final outputFile = File('$saveDir/iconfont.dart');
    await outputFile.writeAsString(dartCode);

    print('✅ Generated ${enumNames.length} icons');
    print('📁 Output: ${outputFile.path}');
    print('🎉 Generation completed successfully!');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
