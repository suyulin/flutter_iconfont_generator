import 'dart:io';
import 'lib/iconfont/iconfont.dart';

void main() {
  print('🎨 验证生成的图标');
  print('');

  print('图标总数: ${IconNames.values.length}');
  print('');

  print('前10个图标:');
  for (int i = 0; i < 10 && i < IconNames.values.length; i++) {
    final iconName = IconNames.values[i];
    print('  ${i + 1}. ${iconName.name}');
  }

  print('');
  print('最后10个图标:');
  final start = IconNames.values.length > 10 ? IconNames.values.length - 10 : 0;
  for (int i = start; i < IconNames.values.length; i++) {
    final iconName = IconNames.values[i];
    print('  ${i + 1}. ${iconName.name}');
  }

  print('');
  print('🎉 图标生成成功！');
  print('📂 生成的文件位置: lib/iconfont/iconfont.dart');
  print('📝 使用方法: IconFont(IconNames.图标名, size: 24)');
}
