#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔍 Verifying iconfont generation...\n');

  // Check if generated file exists
  final generatedFile = File(
      '/Users/suyulin/work/github/flutter_iconfont_generator/lib/iconfont/iconfont.dart');
  final exampleFile = File(
      '/Users/suyulin/work/github/flutter_iconfont_generator/example_app/lib/iconfont/iconfont.dart');

  if (!generatedFile.existsSync()) {
    print('❌ Generated file not found at: ${generatedFile.path}');
    return;
  }

  if (!exampleFile.existsSync()) {
    print('❌ Example file not found at: ${exampleFile.path}');
    return;
  }

  // Read and analyze the generated content
  final content = await generatedFile.readAsString();
  final lines = content.split('\n');

  // Extract enum values
  final enumStartLine =
      lines.indexWhere((line) => line.contains('enum IconNames {'));
  if (enumStartLine == -1) {
    print('❌ IconNames enum not found');
    return;
  }

  final enumLine = lines[enumStartLine];
  final enumContent = enumLine.split('{')[1].split('}')[0];
  final iconNames = enumContent
      .split(',')
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList();

  print('✅ Generated file found with ${iconNames.length} icons');
  print('✅ Example file found and ready');

  // Show first 10 icon names
  print('\n📋 First 10 generated icons:');
  for (int i = 0; i < 10 && i < iconNames.length; i++) {
    print('   ${i + 1}. ${iconNames[i]}');
  }

  // Check for problematic names (all should be properly named, not _1, _2, etc.)
  final problematicNames =
      iconNames.where((name) => RegExp(r'^_\d+$').hasMatch(name)).toList();
  if (problematicNames.isNotEmpty) {
    print('\n⚠️  Found ${problematicNames.length} problematic icon names:');
    problematicNames.take(5).forEach((name) => print('   - $name'));
  } else {
    print('\n✅ All icon names are properly formatted (no _1, _2, etc.)');
  }

  // Check SVG content in the generated file
  final svgCount = content.split('<svg').length - 1;
  print('✅ Found $svgCount SVG definitions in generated file');

  // Check if example app can be analyzed
  print('\n🔧 Checking example app structure...');
  final pubspecFile = File(
      '/Users/suyulin/work/github/flutter_iconfont_generator/example_app/pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final pubspecContent = await pubspecFile.readAsString();
    if (pubspecContent.contains('flutter_svg:')) {
      print('✅ flutter_svg dependency found in example app');
    } else {
      print('⚠️  flutter_svg dependency missing in example app');
    }
  }

  print('\n🎉 Icon generation verification complete!');
  print('📱 You can now run the example app to see the generated icons.');
  print('💡 Command: cd example_app && flutter run');
}
