/// Flutter IconFont Generator
///
/// A Dart/Flutter code generator for iconfont.cn icons.
/// Converts iconfont.cn icons to Flutter widgets with SVG rendering,
/// supporting multi-color icons and null safety.
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
