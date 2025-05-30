import 'dart:io';

/// Debug script to test camelCase conversion
void main() {
  // Test the _toCamelCase function with actual icon IDs
  final testIds = [
    "xiaoxi", // after removing "icon-"
    "bianyuanwangguan", // after removing "icon-"
    "xitongguanli1", // after removing "icon-"
    "wulianwang", // after removing "icon-"
    "wangluozujian", // after removing "icon-"
    "xiayi", // after removing "icon-"
    "chakanAPI", // after removing "icon-"
    "chanpin", // after removing "icon-"
    "jinyong", // after removing "icon-"
    "bianji" // after removing "icon-"
  ];

  print('🔍 Testing camelCase conversion:');
  print('');

  for (final id in testIds) {
    final result = _toCamelCase(id);
    print('Input: "$id" -> Output: "$result"');
  }
}

String _toCamelCase(String input) {
  if (input.isEmpty) return input;

  // Clean the input: replace non-alphanumeric characters with underscores
  String cleaned = input
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .toLowerCase();

  // Remove leading/trailing underscores
  cleaned = cleaned.replaceAll(RegExp(r'^_+|_+$'), '');

  // If empty after cleaning, use a default
  if (cleaned.isEmpty) {
    cleaned = 'icon';
  }

  // If starts with number, add underscore
  if (RegExp(r'^\d').hasMatch(cleaned)) {
    cleaned = 'icon_$cleaned';
  }

  // Convert to camelCase
  List<String> parts = cleaned.split('_');
  if (parts.isEmpty) return 'icon';

  String result = parts[0];
  for (int i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      result += parts[i][0].toUpperCase() + parts[i].substring(1);
    }
  }

  return result;
}
