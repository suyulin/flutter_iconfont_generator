# Flutter IconFont CLI - Dart 版本使用指南

## 快速开始

### 1. 配置 pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0
  http: ^0.13.0
  xml: ^6.0.0
  path: ^1.8.0

dev_dependencies:
  build_runner: ^2.3.0
  yaml: ^3.1.0

# IconFont 配置
iconfont:
  symbol_url: "//at.alicdn.com/t/font_xxx.js"  # 从 iconfont.cn 复制
  save_dir: "./lib/iconfont"
  trim_icon_prefix: "icon"
  default_icon_size: 18
  null_safety: true
```

### 2. 获取 iconfont.cn 链接

1. 登录 [iconfont.cn](https://iconfont.cn)
2. 创建或选择图标项目
3. 点击"Font class" 或 "Symbol"
4. 复制生成的 JS 链接 (如: `//at.alicdn.com/t/font_xxx.js`)
5. 将链接配置到 `pubspec.yaml` 的 `symbol_url`

### 3. 生成图标代码

```bash
# 安装依赖
dart pub get

# 方法一: 使用简化生成器（推荐）
dart run bin/simple_generator.dart

# 方法二: 使用 build_runner
dart run build_runner build

# 方法三: 使用完整生成器
dart run bin/iconfont_generator.dart
```

### 4. 使用生成的图标

```dart
import 'package:your_app/iconfont/iconfont.dart';

// 基本使用
IconFont(IconNames.home)

// 设置大小和颜色
IconFont(
  IconNames.user,
  size: 24,
  color: '#ff0000',
)

// 多色图标
IconFont(
  IconNames.colorful,
  size: 32,
  colors: ['#ff0000', '#00ff00', '#0000ff'],
)

// 动态使用（字符串）
IconFont('home', size: 20)
```

## 配置选项

| 选项 | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `symbol_url` | String | - | iconfont.cn 的 Symbol 或 JS 链接 |
| `save_dir` | String | "./lib/iconfont" | 生成文件保存目录 |
| `trim_icon_prefix` | String | "icon" | 要移除的图标前缀 |
| `default_icon_size` | int | 18 | 默认图标大小 |
| `null_safety` | bool | true | 是否生成 null safety 代码 |

## 常见问题

### Q: 如何更新图标？
A: 重新运行生成命令即可，会自动覆盖旧文件。

### Q: 支持多色图标吗？
A: 支持，使用 `colors` 参数传入颜色数组。

### Q: 可以动态使用图标吗？
A: 可以，传入字符串形式的图标名称。

### Q: 生成失败怎么办？
A: 检查网络连接和 `symbol_url` 是否正确。

## 从 TypeScript 版本迁移

1. 删除 `node_modules`、`package.json`、`package-lock.json`
2. 按上述步骤配置 `pubspec.yaml`
3. 运行 `dart pub get`
4. 使用 Dart 版本的生成命令

## 高级用法

### 自定义模板

你可以修改 `bin/simple_generator.dart` 中的模板函数来自定义生成的代码。

### 批量处理

```bash
# 监听文件变化自动生成
dart run build_runner watch

# 强制重新生成
dart run build_runner build --delete-conflicting-outputs
```

### 调试模式

```bash
dart run bin/simple_generator.dart --verbose
```

## 项目结构

生成后的项目结构：
```
lib/
├── iconfont/
│   └── iconfont.dart    # 生成的图标文件
└── main.dart
```

## 示例项目

参考 `example/main.dart` 查看完整的使用示例。

## 问题反馈

如果遇到问题，请检查：

1. ✅ `pubspec.yaml` 配置是否正确
2. ✅ `symbol_url` 是否有效
3. ✅ 网络连接是否正常
4. ✅ 依赖是否已安装 (`dart pub get`)

更多问题请查看项目 README 或提交 Issue。
