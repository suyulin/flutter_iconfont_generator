#!/usr/bin/env dart

import 'dart:io';
import 'package:yaml/yaml.dart';

// 简化的测试，不使用复杂的生成器
Future<void> main(List<String> arguments) async {
  try {
    print('🚀 Flutter IconFont Generator Test');

    // 读取配置
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('❌ pubspec.yaml not found');
      exit(1);
    }

    final content = await pubspecFile.readAsString();
    final pubspec = loadYaml(content) as Map;
    final iconfontConfig = pubspec['iconfont'] as Map?;

    if (iconfontConfig == null) {
      print('❌ No iconfont config found');
      exit(1);
    }

    print('✅ Configuration loaded:');
    print('   Symbol URL: ${iconfontConfig['symbol_url']}');
    print('   Save Dir: ${iconfontConfig['save_dir']}');
    print('   Prefix: ${iconfontConfig['trim_icon_prefix']}');
    print('   Size: ${iconfontConfig['default_icon_size']}');
    print('   Null Safety: ${iconfontConfig['null_safety']}');

    print('\n🎉 Test completed successfully!');
    print('📝 Next steps:');
    print('   1. 更新 symbol_url 为真实的 iconfont 链接');
    print('   2. 运行: dart run bin/iconfont_generator.dart');
    print('   3. 或使用: dart run build_runner build');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
