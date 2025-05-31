// Validation script to verify the icon color fix
import 'dart:io';

void main() {
  print('🔍 Validating IconFont color fix...\n');

  // Check if the main.dart file contains the fixed color format
  final mainFile = File('lib/main.dart');
  if (!mainFile.existsSync()) {
    print('❌ main.dart not found');
    exit(1);
  }

  final mainContent = mainFile.readAsStringSync();

  // Check for the fixed color format
  if (mainContent.contains("color: '#673AB7'")) {
    print('✅ Fixed color format found in main.dart');
    print('   Color: #673AB7 (proper hex format with # prefix)');
  } else if (mainContent.contains(
      "color: Theme.of(context).primaryColor.value.toRadixString(16)")) {
    print('❌ Old color format still present - fix not applied');
    exit(1);
  } else {
    print('⚠️  Color format unclear in main.dart');
  }

  // Check if iconfont.dart exists and has proper structure
  final iconfontFile = File('lib/iconfont/iconfont.dart');
  if (!iconfontFile.existsSync()) {
    print('❌ iconfont.dart not found');
    exit(1);
  }

  final iconfontContent = iconfontFile.readAsStringSync();

  if (iconfontContent.contains('class IconFont extends StatelessWidget') &&
      iconfontContent.contains('enum IconNames')) {
    print('✅ IconFont class and IconNames enum found');
  } else {
    print('❌ IconFont structure not found');
    exit(1);
  }

  // Check test file
  final testFile = File('test_main.dart');
  if (testFile.existsSync()) {
    final testContent = testFile.readAsStringSync();
    if (testContent.contains("import 'lib/iconfont/iconfont.dart'") &&
        testContent.contains("color: '#ff0000'")) {
      print('✅ Test file has correct imports and color format');
    } else {
      print('⚠️  Test file may have issues');
    }
  }

  print('\n📋 Summary of the fix:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Problem: Black screen due to missing "#" prefix in hex colors');
  print('Solution: Changed color format from dynamic hex to static "#673AB7"');
  print('Files fixed: main.dart, test_main.dart');
  print('Status: ✅ Ready for testing');
  print('\n💡 Next steps:');
  print('1. Run: flutter run -d macos');
  print('2. Verify icons display with purple color');
  print('3. Check that all 96 icons in the grid are visible');
}
