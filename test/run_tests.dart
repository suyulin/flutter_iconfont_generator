#!/usr/bin/env dart

import 'dart:io';

/// 运行所有测试的脚本
Future<void> main(List<String> arguments) async {
  print('🧪 Running Flutter IconFont Generator Tests...\n');

  bool allPassed = true;
  final results = <String, bool>{};

  // 测试套件列表
  final testSuites = [
    'test/config_test.dart',
    'test/svg_parser_test.dart',
    'test/fetcher_test.dart',
    'test/generator_test.dart',
    'test/builder_test.dart',
    'test/widget_test.dart',
    'test/integration_test.dart',
  ];

  // 运行每个测试套件
  for (final testSuite in testSuites) {
    print('🔍 Running $testSuite...');
    
    final result = await Process.run(
      'dart',
      ['test', testSuite],
      runInShell: true,
    );

    final passed = result.exitCode == 0;
    results[testSuite] = passed;
    allPassed = allPassed && passed;

    if (passed) {
      print('✅ $testSuite PASSED\n');
    } else {
      print('❌ $testSuite FAILED');
      print('Error output:');
      print(result.stderr);
      print('Standard output:');
      print(result.stdout);
      print('');
    }
  }

  // 运行覆盖率测试（如果安装了）
  if (arguments.contains('--coverage')) {
    print('📊 Running coverage analysis...');
    final coverageResult = await Process.run(
      'dart',
      ['test', '--coverage=coverage'],
      runInShell: true,
    );

    if (coverageResult.exitCode == 0) {
      print('✅ Coverage analysis completed');
      
      // 尝试生成HTML报告
      final htmlResult = await Process.run(
        'genhtml',
        ['-o', 'coverage/html', 'coverage/lcov.info'],
        runInShell: true,
      );

      if (htmlResult.exitCode == 0) {
        print('📄 HTML coverage report generated at coverage/html/index.html');
      }
    } else {
      print('❌ Coverage analysis failed');
    }
  }

  // 显示总结
  print('\n📋 Test Results Summary:');
  print('=' * 50);
  
  for (final entry in results.entries) {
    final status = entry.value ? '✅ PASSED' : '❌ FAILED';
    print('${entry.key.padRight(35)} $status');
  }
  
  print('=' * 50);
  
  if (allPassed) {
    print('🎉 All tests PASSED!');
    exit(0);
  } else {
    final failedCount = results.values.where((v) => !v).length;
    print('❌ $failedCount test suite(s) FAILED');
    exit(1);
  }
}
