/// Configuration model for iconfont generation
class IconFontConfig {
  final String symbolUrl;
  final String saveDir;
  final String trimIconPrefix;
  final int defaultIconSize;
  final bool nullSafety;

  const IconFontConfig({
    required this.symbolUrl,
    required this.saveDir,
    required this.trimIconPrefix,
    required this.defaultIconSize,
    required this.nullSafety,
  });

  factory IconFontConfig.fromMap(Map<String, dynamic> map) {
    return IconFontConfig(
      symbolUrl: map['symbol_url'] ?? '',
      saveDir: map['save_dir'] ?? './lib/iconfont',
      trimIconPrefix: map['trim_icon_prefix'] ?? 'icon',
      defaultIconSize: map['default_icon_size'] ?? 18,
      nullSafety: map['null_safety'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol_url': symbolUrl,
      'save_dir': saveDir,
      'trim_icon_prefix': trimIconPrefix,
      'default_icon_size': defaultIconSize,
      'null_safety': nullSafety,
    };
  }
}
