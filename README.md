# Flutter IconFont Generator

> 将 iconfont.cn 的图标转换成 Flutter Widget 的纯 Dart 代码生成工具。

![Icons Demo](https://github.com/fwh1990/flutter-iconfont-cli/blob/master/images/icons.png?raw=true)

## ✨ 特性

- 🚀 **纯 Dart 实现** - 无需 Node.js，使用 build_runner 进行代码生成
- 🎨 **多色彩支持** - 支持渲染多色彩图标，支持自定义颜色
- 📦 **纯组件** - 不依赖字体文件，使用 SVG 渲染，体积更小
- 🔄 **自动化生成** - 自动从 iconfont.cn 获取最新图标并生成 Dart 代码
- 🛡️ **Null Safety** - 完全支持 Dart null safety
- ⚡ **多种使用方式** - 支持命令行工具和 build_runner 两种生成方式

## 🚀 快速开始

### 1. 配置依赖

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0  # SVG 渲染支持
  http: ^0.13.0        # 网络请求
  xml: ^6.0.0          # XML 解析
  path: ^1.8.0         # 路径处理

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.3.0  # 代码生成
  yaml: ^3.1.0          # YAML 解析

# IconFont 配置
iconfont:
  symbol_url: "//at.alicdn.com/t/font_xxx.js"  # 从 iconfont.cn 获取
  save_dir: "./lib/iconfont"                    # 输出目录
  trim_icon_prefix: "icon"                      # 移除图标名前缀
  default_icon_size: 18                         # 默认图标大小
  null_safety: true                             # 启用 null safety
```

### 2. 获取 iconfont.cn 链接

1. 登录 [iconfont.cn](https://iconfont.cn)
2. 创建项目或选择现有项目
3. 点击 "Font class" 或 "Symbol" 选项卡
4. 复制生成的 JavaScript 链接

![Symbol URL](https://github.com/fwh1990/flutter-iconfont-cli/blob/master/images/symbol-url.png?raw=true)

### 3. 生成图标代码

```bash
# 安装依赖
dart pub get

# 方法一：使用简化生成器（推荐）
dart run bin/simple_generator.dart

# 方法二：使用 build_runner
dart run build_runner build

# 方法三：使用完整生成器
dart run bin/iconfont_generator.dart
```

## 📖 使用方法

### 基本用法

```dart
import 'package:your_app/iconfont/iconfont.dart';

// 基本使用
IconFont(IconNames.home)

// 指定大小
IconFont(IconNames.user, size: 24)
```

### 单色图标

```dart
// 使用自定义颜色
IconFont(
  IconNames.alipay,
  size: 32,
  color: '#ff0000',
)
```

![One Color Icon](https://github.com/fwh1990/flutter-iconfont-cli/blob/master/images/one-color-icon.png?raw=true)

### 多色图标

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
