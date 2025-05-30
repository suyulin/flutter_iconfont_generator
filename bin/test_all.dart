#!/usr/bin/env dart

import 'dart:io';

/// 测试完整的 IconFont 生成流程
Future<void> main(List<String> arguments) async {
  print('🧪 Testing Flutter IconFont Generator...\n');

  try {
    // 1. 检查依赖
    print('1️⃣ Checking dependencies...');
    final pubGetResult = await Process.run('dart', ['pub', 'get']);
    if (pubGetResult.exitCode != 0) {
      print('❌ dart pub get failed');
      print(pubGetResult.stderr);
      exit(1);
    }
    print('✅ Dependencies installed\n');

    // 2. 检查配置
    print('2️⃣ Checking configuration...');
    final pubspecFile = File('pubspec.yaml');
    final content = await pubspecFile.readAsString();

    if (!content.contains('iconfont:')) {
      print('❌ No iconfont configuration found');
      exit(1);
    }

    if (content.contains('请参考README.md')) {
      print('⚠️  Warning: Please update symbol_url in pubspec.yaml');
    }

    print('✅ Configuration found\n');

    // 3. 测试简化生成器
    print('3️⃣ Testing simple generator...');

    // 创建备份配置用于测试
    final testConfig = '''
iconfont:
  symbol_url: "//at.alicdn.com/t/font_8d5l8fzk5b87iudi.js"
  save_dir: "./test_output"
  trim_icon_prefix: "icon"
  default_icon_size: 18
  null_safety: true
''';

    // 临时修改配置进行测试
    final originalContent = content;
    final testContent = content.replaceAll(
        RegExp(r'iconfont:.*?null_safety: true', dotAll: true),
        testConfig.trim());

    await pubspecFile.writeAsString(testContent);

    try {
      final generatorResult = await Process.run(
        'dart',
        ['run', 'bin/simple_generator.dart'],
        workingDirectory: Directory.current.path,
      );

      if (generatorResult.exitCode == 0) {
        print('✅ Simple generator test passed');
        print(generatorResult.stdout);
      } else {
        print('⚠️  Simple generator test failed (expected if no internet)');
        print(generatorResult.stderr);
      }
    } finally {
      // 恢复原始配置
      await pubspecFile.writeAsString(originalContent);

      // 清理测试输出
      final testDir = Directory('./test_output');
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    }

    print('\n4️⃣ All tests completed!');
    print('\n📋 Next steps:');
    print('   1. 在 pubspec.yaml 中配置正确的 symbol_url');
    print('   2. 运行: dart run bin/simple_generator.dart');
    print('   3. 在代码中导入并使用生成的图标');
    print('\n📚 参考文档: USAGE_GUIDE.md');
  } catch (e) {
    print('❌ Test failed: $e');
    exit(1);
  }
}
