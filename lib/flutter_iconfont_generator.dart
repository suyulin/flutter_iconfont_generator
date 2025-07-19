/// Flutter IconFont Generator
///
/// A Dart/Flutter code generator for iconfont.cn icons.
/// Converts iconfont.cn icons to Flutter widgets with SVG rendering,
/// supporting multi-color icons and null safety.
///
/// ## Features
///
/// - **Automatic Code Generation**: Fetches icons from iconfont.cn and generates Flutter widgets
/// - **Type Safety**: Generated enum ensures compile-time icon name validation
/// - **Null Safety**: Full null safety support for modern Flutter apps
/// - **Multi-color Icons**: Support for icons with multiple colors and gradients
/// - **SVG Rendering**: High-quality vector rendering using flutter_svg
/// - **Hot Reload**: Seamless integration with Flutter development workflow
/// - **Build Runner**: Integration with build_runner for automatic code generation
///
/// ## Quick Start
///
/// 1. Add dependencies to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   flutter_svg: ^2.0.0
/// 
/// dev_dependencies:
///   flutter_iconfont_generator: ^1.0.0
///   build_runner: ^2.4.0
/// ```
///
/// 2. Configure your iconfont in `pubspec.yaml`:
/// ```yaml
/// iconfont:
///   symbol_url: "//at.alicdn.com/t/font_xxx.js"  # Your iconfont.cn URL
///   save_dir: "./lib/iconfont"
///   trim_icon_prefix: "icon"
///   default_icon_size: 18
///   null_safety: true
/// ```
///
/// 3. Create a trigger file `lib/iconfont.dart` (can be empty)
///
/// 4. Run code generation:
/// ```bash
/// flutter packages pub run build_runner build
/// ```
///
/// 5. Use the generated icons:
/// ```dart
/// import 'package:your_app/iconfont/iconfont.dart';
///
/// // Basic usage
/// IconFont(IconNames.home)
///
/// // With custom size and color
/// IconFont(IconNames.user, size: 24, color: '#ff0000')
///
/// // Multi-color icon
/// IconFont(IconNames.logo, colors: ['#ff0000', '#00ff00', '#0000ff'])
/// ```
///
/// ## Configuration Options
///
/// | Option | Type | Default | Description |
/// |--------|------|---------|-------------|
/// | `symbol_url` | String | Required | Your iconfont.cn symbol URL |
/// | `save_dir` | String | `./lib/iconfont` | Output directory for generated files |
/// | `trim_icon_prefix` | String | `icon` | Icon prefix to remove from names |
/// | `default_icon_size` | int | `18` | Default size for icons |
/// | `null_safety` | bool | `true` | Enable null safety in generated code |
///
/// ## Advanced Usage
///
/// ### Custom Icon Sizes
/// ```dart
/// IconFont(IconNames.settings, size: 32.0)
/// ```
///
/// ### Dynamic Colors
/// ```dart
/// // Single color override
/// IconFont(IconNames.heart, color: '#ff0000')
///
/// // Multiple colors for complex icons
/// IconFont(IconNames.gradient, colors: ['#ff0000', '#00ff00'])
/// ```
///
/// ### String-based Icon Names
/// ```dart
/// // When icon names come from API or configuration
/// IconFont('home')  // Automatically converts to IconNames.home
/// ```
///
/// ## Troubleshooting
///
/// ### Common Issues
///
/// 1. **No icons generated**: Check your symbol_url is correct and accessible
/// 2. **Build errors**: Ensure flutter_svg is added as a dependency
/// 3. **Icon not found**: Verify the icon exists in your iconfont.cn project
/// 4. **Color issues**: Check if your icon supports multi-color rendering
///
/// ### Build Configuration
///
/// For advanced build configuration, create a `build.yaml` file:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       flutter_iconfont_generator|iconfont_builder:
///         enabled: true
///         options:
///           # Custom builder options here
/// ```
///
/// ## API Reference
///
/// The library exports the following main classes:
/// - [IconFontConfig]: Configuration model for iconfont generation
/// - [SvgSymbol]: Represents an SVG symbol from iconfont
/// - [SvgPath]: Represents an SVG path element
/// - [SvgParser]: Parser for iconfont SVG data
/// - [IconFontFetcher]: Fetches SVG content from iconfont.cn
/// - [CodeGenerator]: Generates Flutter icon font code
///
/// For build_runner integration:
/// - [IconFontBuilder]: Builder for generating iconfont code
/// - [iconFontBuilder]: Builder factory function
library flutter_iconfont_generator;

// Core functionality exports
export 'src/config.dart';
export 'src/fetcher.dart';
export 'src/generator.dart';
export 'src/svg_parser.dart';

// Builder export for build_runner integration
export 'builder.dart';

// Example of generated icon usage
// After running the generator, you can use icons like:
//
// import 'package:your_app/iconfont/iconfont.dart';
//
// IconFont(IconNames.home)
// IconFont(IconNames.user, size: 24)
// IconFont(IconNames.settings, size: 32, color: '#ff0000')
