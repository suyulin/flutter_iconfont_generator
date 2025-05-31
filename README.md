# Flutter IconFont Generator

[![pub package](https://img.shields.io/pub/v/flutter_iconfont_generator.svg)](https://pub.dev/packages/flutter_iconfont_generator)
[![popularity](https://badges.bar/flutter_iconfont_generator/popularity)](https://pub.dev/packages/flutter_iconfont_generator/score)
[![likes](https://badges.bar/flutter_iconfont_generator/likes)](https://pub.dev/packages/flutter_iconfont_generator/score)
[![pub points](https://badges.bar/flutter_iconfont_generator/pub%20points)](https://pub.dev/packages/flutter_iconfont_generator/score)

> A Dart/Flutter code generator for iconfont.cn icons. Convert iconfont.cn icons to Flutter widgets with SVG rendering, supporting multi-color icons and null safety.

## ✨ Features

- 🚀 **Command Line Tool** - Simple command-line interface, no build_runner needed
- 🎨 **Multi-color Support** - Render multi-color icons with custom color support  
- 📦 **Pure Components** - No font files needed, uses SVG rendering for smaller bundle size
- 🔄 **Automated Generation** - Automatically fetch latest icons from iconfont.cn and generate Dart code
- 🛡️ **Null Safety** - Full Dart null safety support
- ⚡ **Easy Installation** - Global installation via dart pub global activate

## 🚀 Quick Start

### Installation

#### Method 1: Global Installation (Recommended)

Install the command-line tool globally:

```bash
dart pub global activate flutter_iconfont_generator
```

#### Method 2: Add as Dev Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0

dev_dependencies:
  flutter_iconfont_generator: ^2.0.0
```

### Configuration

Add iconfont configuration to your `pubspec.yaml`:

```yaml
# IconFont configuration
iconfont:
  symbol_url: "//at.alicdn.com/t/font_xxx.js"  # Get from iconfont.cn
  save_dir: "./lib/iconfont"                    # Output directory
  trim_icon_prefix: "icon"                      # Remove icon name prefix
  default_icon_size: 18                         # Default icon size
  null_safety: true                             # Enable null safety
```

### Generate Icon Code

#### Method 1: Command Line Tool (Recommended)

After global installation:

```bash
# Generate icons using pubspec.yaml configuration
iconfont_generator

# Generate with custom parameters
iconfont_generator --url "//at.alicdn.com/t/font_xxx.js" --output lib/icons

# Show verbose output
iconfont_generator --verbose

# Show help
iconfont_generator --help
```

#### Method 2: Direct Dart Execution

If not globally installed:

```bash
# Run from your project root
dart run flutter_iconfont_generator:iconfont_generator

# Or if you added it as a dev dependency
dart run flutter_iconfont_generator
```

## 📖 Usage

### Basic Usage

```dart
import 'package:your_app/iconfont/iconfont.dart';

// Basic usage
IconFont(IconNames.home)

// With size
IconFont(IconNames.user, size: 24)

// With color
IconFont(IconNames.settings, size: 32, color: '#ff0000')

// With multiple colors (for multi-color icons)
IconFont(IconNames.logo, size: 48, colors: ['#ff0000', '#00ff00', '#0000ff'])
```

### Command Line Options

```bash
# Basic usage
iconfont_generator

# Custom options
iconfont_generator \
  --url "//at.alicdn.com/t/c/font_4937193_3aohv86wocr.js" \
  --output lib/icons \
  --prefix icon \
  --size 24 \
  --verbose

# Options:
#   -h, --help      Show usage help
#   -v, --verbose   Show verbose output
#   -c, --config    Path to config file (default: pubspec.yaml)
#   -u, --url       IconFont symbol URL (overrides config)
#   -o, --output    Output directory (overrides config)
#   -p, --prefix    Icon prefix to trim (overrides config)
#   -s, --size      Default icon size (overrides config)
```

### Single Color Icons

```dart
// Using custom color
IconFont(
  IconNames.alipay,
  size: 32,
  color: 'ff0000',  // Without # prefix
)
```

### Multi-color Icons

```dart
// Multi-color icons
IconFont(
  IconNames.colorful_icon,
  size: 32,
  colors: ['ff0000', '00ff00', '0000ff'],
)
```

## 🔧 Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `symbol_url` | String | - | Required. JavaScript URL from iconfont.cn |
| `save_dir` | String | `./lib/iconfont` | Output directory for generated files |
| `trim_icon_prefix` | String | `icon` | Prefix to remove from icon names |
| `default_icon_size` | int | `18` | Default size for icons |
| `null_safety` | bool | `true` | Enable null safety in generated code |

## 🔗 Getting Your Symbol URL

1. Go to [iconfont.cn](https://www.iconfont.cn/)
2. Create or open your icon project
3. Go to project settings (项目设置)
4. Find "FontClass/Symbol前缀" section
5. Copy the JavaScript URL (should look like `//at.alicdn.com/t/c/font_xxx_xxx.js`)

![Symbol URL Location](images/symbol-url.png)

## 🚧 Troubleshooting

### Common Issues

**"No iconfont configuration found"**
- Make sure you have the `iconfont:` section in your `pubspec.yaml`

**"Please configure a valid symbol_url"**
- Check that your symbol URL is from iconfont.cn and is accessible
- The URL should start with `//at.alicdn.com/`

**"No icons found in the SVG content"**
- Verify your symbol URL is correct
- Check that your iconfont project has icons
- Try accessing the URL in a browser

**Permission denied**
- Make sure you have write permissions to the output directory

### Debug Mode

Use verbose mode to see detailed information:

```bash
iconfont_generator --verbose
```

## 📱 Example

Check out the [example app](example_app/) for a complete implementation showing all features.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to [iconfont.cn](https://iconfont.cn) for providing excellent icon service
- Inspired by similar tools in the React ecosystem

```dart
// 多色彩图标
IconFont(
  IconNames.colorful_icon,
  size: 32,
  colors: ['#ff0000', '#00ff00', '#0000ff'],
)
```

![Multi Color Icon](https://github.com/fwh1990/flutter-iconfont-cli/blob/master/images/multi-color-icon.png?raw=true)

### 动态使用

```dart
// 使用字符串（动态场景）
IconFont('home', size: 20)

// 使用枚举（推荐）
IconFont(IconNames.home, size: 20)
```

## ⚙️ 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `symbol_url` | String | - | **必填** iconfont.cn 的 Symbol 链接 |
| `save_dir` | String | `"./lib/iconfont"` | 生成文件的保存目录 |
| `trim_icon_prefix` | String | `"icon"` | 要移除的图标名前缀 |
| `default_icon_size` | int | `18` | 默认图标大小 |
| `null_safety` | bool | `true` | 是否生成 null safety 代码 |

## 🔄 更新图标

当 iconfont.cn 中的图标有变更时，重新运行生成命令即可：

```bash
dart run bin/simple_generator.dart
```

## 🛠️ 高级用法

### 使用 build_runner 监听模式

```bash
# 监听文件变化，自动重新生成
dart run build_runner watch

# 强制重新生成（清除缓存）
dart run build_runner build --delete-conflicting-outputs
```

### 调试模式

```bash
# 查看详细错误信息
dart run bin/simple_generator.dart --verbose
```

### 自定义生成器

你可以修改 [`bin/simple_generator.dart`](bin/simple_generator.dart) 来自定义生成的代码模板。

## 📦 项目结构

生成后的项目结构：

```
lib/
├── iconfont/
│   └── iconfont.dart    # 生成的图标组件
└── main.dart

bin/
├── simple_generator.dart    # 简化生成器
├── iconfont_generator.dart  # 完整生成器
└── test_config.dart         # 配置测试工具
```

## 🔧 设计理念

### 为什么使用 SVG 而不是字体？

1. **多色彩支持** - SVG 天然支持多色彩渲染
2. **体积更小** - 只包含使用的图标，无冗余数据
3. **更好的兼容性** - 不依赖系统字体，跨平台一致性更好
4. **代码即图标** - 图标作为 Dart 代码存在，便于版本控制和管理

### 核心优势

- **纯 Dart 实现** - 利用 Dart 生态，无需额外的运行时环境
- **编译时生成** - 图标在编译时确定，运行时性能更好
- **类型安全** - 通过枚举提供类型安全的图标引用
- **按需加载** - 只生成项目中实际使用的图标

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目基于 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

## 🔗 相关链接

- [iconfont.cn](https://iconfont.cn) - 阿里巴巴矢量图标库
- [Flutter SVG](https://pub.dev/packages/flutter_svg) - Flutter SVG 渲染插件
- [build_runner](https://pub.dev/packages/build_runner) - Dart 代码生成工具

## 📢 项目说明

本项目是基于 [flutter-iconfont-cli](https://github.com/iconfont-cli/flutter-iconfont-cli) 的纯 Dart 重构版本。由于原仓库不再维护，故使用新仓库继续维护和发展该项目。

---

如果这个项目对你有帮助，请给个 ⭐️ Star 支持一下！
