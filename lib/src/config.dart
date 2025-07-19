/// Configuration model for iconfont generation.
///
/// This class defines all the settings needed to generate Flutter icon widgets
/// from iconfont.cn icons. It handles configuration parsing from pubspec.yaml
/// and provides sensible defaults for all optional settings.
///
/// ## Usage
///
/// ### From pubspec.yaml configuration
/// ```dart
/// final config = IconFontConfig.fromMap({
///   'symbol_url': '//at.alicdn.com/t/font_123.js',
///   'save_dir': './lib/icons',
///   'trim_icon_prefix': 'icon',
///   'default_icon_size': 24,
///   'null_safety': true,
/// });
/// ```
///
/// ### Direct instantiation
/// ```dart
/// final config = IconFontConfig(
///   symbolUrl: 'https://at.alicdn.com/t/font_123.js',
///   saveDir: './lib/my_icons',
///   trimIconPrefix: 'my-icon',
///   defaultIconSize: 20,
///   nullSafety: true,
/// );
/// ```
///
/// ### Converting to/from Map
/// ```dart
/// final map = config.toMap();
/// final newConfig = IconFontConfig.fromMap(map);
/// ```
class IconFontConfig {
  /// The URL to fetch iconfont symbols from.
  ///
  /// This should be your iconfont.cn project's symbol URL, which typically
  /// looks like `//at.alicdn.com/t/font_xxx.js` or can include the full
  /// protocol like `https://at.alicdn.com/t/font_xxx.js`.
  ///
  /// The fetcher will automatically:
  /// - Add HTTPS protocol if missing
  /// - Convert .symbol URLs to .js URLs
  /// - Handle relative protocol URLs (starting with //)
  ///
  /// Example: `//at.alicdn.com/t/font_123456_abcdef.js`
  final String symbolUrl;

  /// The directory where generated icon files will be saved.
  ///
  /// This path is relative to your project root. The directory will be
  /// created automatically if it doesn't exist. All existing .dart files
  /// in this directory will be cleaned before generation.
  ///
  /// Default: `./lib/iconfont`
  ///
  /// Examples:
  /// - `./lib/icons`
  /// - `./lib/generated/iconfont`
  /// - `./packages/ui/lib/icons`
  final String saveDir;

  /// The prefix to trim from icon names when generating enum values.
  ///
  /// Most iconfont.cn icons have a common prefix (like "icon-") that you
  /// may want to remove for cleaner enum names. For example, if your
  /// icons are named "icon-home", "icon-user", setting this to "icon"
  /// will generate enum values `home`, `user` instead of `iconHome`, `iconUser`.
  ///
  /// Default: `icon`
  ///
  /// Examples:
  /// - `icon` → "icon-home" becomes "home"
  /// - `my-icon` → "my-icon-settings" becomes "settings"
  /// - `` (empty) → no trimming applied
  final String trimIconPrefix;

  /// The default size for generated icon widgets.
  ///
  /// This value will be used as the default `size` parameter in the
  /// generated IconFont widget constructor. Users can still override
  /// this by passing a different size when using the widget.
  ///
  /// Default: `18`
  ///
  /// Example usage:
  /// ```dart
  /// // Uses default size (18)
  /// IconFont(IconNames.home)
  /// 
  /// // Override with custom size
  /// IconFont(IconNames.home, size: 24)
  /// ```
  final int defaultIconSize;

  /// Whether to generate null-safe code.
  ///
  /// When `true`, the generated code will use null safety syntax including:
  /// - `String?` for optional color parameters
  /// - `super.key` for widget keys
  /// - Null-aware operators where appropriate
  ///
  /// When `false`, generates legacy Dart code compatible with older versions.
  ///
  /// Default: `true`
  ///
  /// It's recommended to keep this `true` for modern Flutter projects.
  final bool nullSafety;

  /// Creates a new IconFontConfig with the specified settings.
  ///
  /// All parameters are required when using this constructor. For optional
  /// parameters with defaults, use [IconFontConfig.fromMap] instead.
  ///
  /// Parameters:
  /// - [symbolUrl]: The iconfont.cn symbol URL to fetch icons from
  /// - [saveDir]: Directory to save generated files
  /// - [trimIconPrefix]: Prefix to remove from icon names
  /// - [defaultIconSize]: Default size for icon widgets
  /// - [nullSafety]: Whether to generate null-safe code
  const IconFontConfig({
    required this.symbolUrl,
    required this.saveDir,
    required this.trimIconPrefix,
    required this.defaultIconSize,
    required this.nullSafety,
  });

  /// Creates an IconFontConfig from a configuration map.
  ///
  /// This factory constructor is typically used to parse configuration
  /// from pubspec.yaml or other configuration sources. It provides
  /// sensible defaults for all missing values.
  ///
  /// ## Default values:
  /// - `symbol_url`: `` (empty string - must be provided)
  /// - `save_dir`: `./lib/iconfont`
  /// - `trim_icon_prefix`: `icon`
  /// - `default_icon_size`: `18`
  /// - `null_safety`: `true`
  ///
  /// Parameters:
  /// - [map]: Configuration map with string keys and dynamic values
  ///
  /// Returns:
  /// - A new IconFontConfig instance with provided or default values
  ///
  /// Example:
  /// ```dart
  /// final config = IconFontConfig.fromMap({
  ///   'symbol_url': '//at.alicdn.com/t/font_123.js',
  ///   'default_icon_size': 24,
  ///   // Other values will use defaults
  /// });
  /// ```
  factory IconFontConfig.fromMap(Map<String, dynamic> map) {
    return IconFontConfig(
      symbolUrl: map['symbol_url'] ?? '',
      saveDir: map['save_dir'] ?? './lib/iconfont',
      trimIconPrefix: map['trim_icon_prefix'] ?? 'icon',
      defaultIconSize: map['default_icon_size'] ?? 18,
      nullSafety: map['null_safety'] ?? true,
    );
  }

  /// Converts this configuration to a map representation.
  ///
  /// This is useful for serialization, debugging, or when you need to
  /// pass the configuration to other parts of your system that expect
  /// a map format.
  ///
  /// Returns:
  /// - A map with string keys matching the pubspec.yaml configuration format
  ///
  /// Example:
  /// ```dart
  /// final map = config.toMap();
  /// print(map['symbol_url']); // https://at.alicdn.com/t/font_123.js
  /// ```
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
