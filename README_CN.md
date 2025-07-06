# Flutter IconFont Generator

[![pub package](https://img.shields.io/pub/v/flutter_iconfont_generator.svg)](https://pub.dev/packages/flutter_iconfont_generator)
[![popularity](https://badges.bar/flutter_iconfont_generator/popularity)](https://pub.dev/packages/flutter_iconfont_generator/score)
[![likes](https://badges.bar/flutter_iconfont_generator/likes)](https://pub.dev/packages/flutter_iconfont_generator/score)
[![pub points](https://badges.bar/flutter_iconfont_generator/pub%20points)](https://pub.dev/packages/flutter_iconfont_generator/score)

中文文档 | [English](./README.md)

> 一个用于 iconfont.cn 图标的 Dart/Flutter 代码生成器。将 iconfont.cn 图标转换为 Flutter 组件，支持 SVG 渲染、多色彩图标和空安全。

## ✨ 功能特性

- 🚀 **命令行工具** - 简单的命令行接口，无需 build_runner
- 🎨 **多色彩支持** - 支持多色彩图标渲染和自定义颜色
- 📦 **纯组件** - 无需字体文件，使用 SVG 渲染减少包体积
- 🔄 **自动生成** - 自动从 iconfont.cn 获取最新图标并生成 Dart 代码
- 🛡️ **空安全** - 完整的 Dart 空安全支持
- ⚡ **简易安装** - 通过 dart pub global activate 全局安装

## 🚀 快速开始

### 安装

#### 方法一：全局安装（推荐）

全局安装命令行工具：

```bash
dart pub global activate flutter_iconfont_generator
```

#### 方法二：添加为开发依赖

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0

dev_dependencies:
  flutter_iconfont_generator: ^2.0.0
```

### 配置

在你的 `pubspec.yaml` 中添加 iconfont 配置：

```yaml
# IconFont 配置
iconfont:
  symbol_url: "//at.alicdn.com/t/font_xxx.js"  # 从 iconfont.cn 获取
  save_dir: "./lib/iconfont"                    # 输出目录
  trim_icon_prefix: "icon"                      # 移除图标名前缀
  default_icon_size: 18                         # 默认图标大小
  null_safety: true                             # 启用空安全
```

### 生成图标代码

#### 方法一：命令行工具（推荐）

全局安装后：

```bash
# 使用 pubspec.yaml 配置生成图标
iconfont_generator

# 使用自定义参数生成
iconfont_generator --url "//at.alicdn.com/t/font_xxx.js" --output lib/icons

# 显示详细输出
iconfont_generator --verbose

# 显示帮助
iconfont_generator --help
```

#### 方法二：直接执行 Dart

如果未全局安装：

```bash
# 从项目根目录运行
dart run flutter_iconfont_generator:iconfont_generator

# 或者如果添加为开发依赖
dart run flutter_iconfont_generator
```

## 📖 使用方法

### 基本使用

```dart
import 'package:your_app/iconfont/iconfont.dart';

// 基本使用
IconFont(IconNames.home)

// 带大小
IconFont(IconNames.user, size: 24)

// 带颜色
IconFont(IconNames.settings, size: 32, color: '#ff0000')

// 多色彩图标
IconFont(IconNames.logo, size: 48, colors: ['#ff0000', '#00ff00', '#0000ff'])
```

### 命令行选项

```bash
# 基本使用
iconfont_generator

# 自定义选项
iconfont_generator \
  --url "//at.alicdn.com/t/c/font_4937193_3aohv86wocr.js" \
  --output lib/icons \
  --prefix icon \
  --size 24 \
  --verbose

# 选项说明：
#   -h, --help      显示使用帮助
#   -v, --verbose   显示详细输出
#   -c, --config    配置文件路径（默认：pubspec.yaml）
#   -u, --url       IconFont 符号 URL（覆盖配置）
#   -o, --output    输出目录（覆盖配置）
#   -p, --prefix    要移除的图标前缀（覆盖配置）
#   -s, --size      默认图标大小（覆盖配置）
```

### 单色图标

```dart
// 使用自定义颜色
IconFont(
  IconNames.alipay,
  size: 32,
  color: 'ff0000',  // 不带 # 前缀
)
```

### 多色彩图标

```dart
// 多色彩图标
IconFont(
  IconNames.colorful_icon,
  size: 32,
  colors: ['ff0000', '00ff00', '0000ff'],
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

## 🔗 获取 Symbol URL

1. 访问 [iconfont.cn](https://www.iconfont.cn/)
2. 创建或打开你的图标项目
3. 进入项目设置（项目设置）
4. 找到 "FontClass/Symbol前缀" 部分
5. 复制 JavaScript URL（应该类似 `//at.alicdn.com/t/c/font_xxx_xxx.js`）

![Symbol URL Location](images/symbol-url.png)

## 🚧 故障排除

### 常见问题

**"未找到 iconfont 配置"**
- 确保你在 `pubspec.yaml` 中有 `iconfont:` 部分

**"请配置有效的 symbol_url"**
- 检查你的 symbol URL 是否来自 iconfont.cn 且可访问
- URL 应该以 `//at.alicdn.com/` 开头

**"在 SVG 内容中未找到图标"**
- 验证你的 symbol URL 是否正确
- 检查你的 iconfont 项目是否有图标
- 尝试在浏览器中访问该 URL

**权限被拒绝**
- 确保你对输出目录有写权限

### 调试模式

使用详细模式查看详细信息：

```bash
iconfont_generator --verbose
```

## 🔄 更新图标

当 iconfont.cn 中的图标有变更时，重新运行生成命令即可：

```bash
iconfont_generator
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
iconfont_generator --verbose
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

## 📱 示例

查看 [示例应用](example_app/) 获取展示所有功能的完整实现。

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
