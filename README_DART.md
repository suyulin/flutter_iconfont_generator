# Flutter IconFont CLI - Dart 版本

基于 Dart 重构的 iconfont.cn 图标转换工具，使用 build_runner 进行代码生成。

## 主要特性

- ✅ 纯 Dart 实现，无需 Node.js
- ✅ 通过 `pubspec.yaml` 配置参数
- ✅ 使用 `build_runner` 进行代码生成
- ✅ 支持 null safety
- ✅ 支持多色图标
- ✅ 命令行工具和构建器两种使用方式

## 配置说明

在 `pubspec.yaml` 中添加配置：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0
  http: ^0.13.0
  xml: ^6.0.0
  path: ^1.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.3.0
  source_gen: ^1.2.0
  analyzer: ^5.0.0
  build: ^2.3.0
  yaml: ^3.1.0

# IconFont 配置
iconfont:
  symbol_url: "//at.alicdn.com/t/c/font_4937193_gokuo0doel.js"  # 从 iconfont.cn 获取
  save_dir: "./lib/iconfont"                                # 输出目录
  trim_icon_prefix: "icon"                                  # 移除图标名前缀
  default_icon_size: 18                                     # 默认图标大小
  null_safety: true                                         # 是否使用 null safety
```

## 使用方法

### 方法一：使用 build_runner（推荐）

1. 添加配置到 `pubspec.yaml`
2. 运行代码生成：

```bash
# 一次性生成
dart run build_runner build

# 监听模式（文件变化时自动重新生成）
dart run build_runner watch

# 强制重新生成
dart run build_runner build --delete-conflicting-outputs
```

### 方法二：使用命令行工具

```bash
# 直接运行生成器
dart run bin/iconfont_generator.dart

# 或者安装后使用
dart pub global activate --source path .
iconfont_generator
```

## 生成的代码使用

```dart
import 'package:your_app/iconfont/iconfont.dart';

// 基本使用
IconFont(IconNames.home)

// 指定大小和颜色
IconFont(
  IconNames.user,
  size: 24,
  color: '#ff0000',
)

// 多色图标
IconFont(
  IconNames.colorful_icon,
  size: 32,
  colors: ['#ff0000', '#00ff00', '#0000ff'],
)

// 使用字符串（动态）
IconFont('home', size: 20)
```

## 从 TypeScript 版本迁移

1. 删除 `node_modules` 和 `package.json`
2. 更新 `pubspec.yaml` 配置
3. 运行 `dart pub get`
4. 使用 `dart run build_runner build` 生成图标

## 配置参数说明

| 参数 | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `symbol_url` | String | - | iconfont.cn 提供的 Symbol 链接 |
| `save_dir` | String | "./lib/iconfont" | 生成文件的保存目录 |
| `trim_icon_prefix` | String | "icon" | 要移除的图标名前缀 |
| `default_icon_size` | int | 18 | 默认图标大小 |
| `null_safety` | bool | true | 是否生成 null safety 代码 |

## 故障排除

### 常见问题

1. **找不到配置**: 确保 `pubspec.yaml` 中有 `iconfont` 配置节
2. **网络错误**: 检查 `symbol_url` 是否正确
3. **生成失败**: 运行 `dart run build_runner clean` 后重试

### 调试模式

```bash
# 查看详细错误信息
dart run bin/iconfont_generator.dart --verbose
```

## 开发说明

项目结构：
```
lib/
├── src/
│   ├── config.dart      # 配置模型
│   ├── fetcher.dart     # 网络请求
│   ├── svg_parser.dart  # SVG 解析
│   └── generator.dart   # 代码生成
├── builder.dart         # build_runner 构建器
└── iconfont.dart       # 入口文件

bin/
└── iconfont_generator.dart  # 命令行工具
```
