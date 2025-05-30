# 测试用例说明

本项目为Flutter图标字体生成器编写了全面的测试用例，涵盖了项目的所有核心功能模块。

## 测试文件结构

```
test/
├── config_test.dart        # 配置模块测试
├── fetcher_test.dart       # 网络获取模块测试
├── svg_parser_test.dart    # SVG解析模块测试
├── generator_test.dart     # 代码生成模块测试
├── builder_test.dart       # 构建器模块测试
├── widget_test.dart        # Widget组件测试
├── integration_test.dart   # 集成测试
└── run_tests.dart          # 测试运行脚本
```

## 测试覆盖范围

### 1. 配置模块测试 (`config_test.dart`)
- ✅ 从Map创建配置对象
- ✅ 默认值处理
- ✅ 空值和null值处理
- ✅ 类型混合处理
- ✅ 配置对象转Map

### 2. 网络获取模块测试 (`fetcher_test.dart`)
- ✅ 从有效URL获取SVG内容
- ✅ 无效URL错误处理
- ✅ HTTP错误响应处理
- ✅ 无SVG内容错误处理
- ✅ Symbol URL转JS URL
- ✅ 网络超时处理
- ✅ 复杂SVG内容提取

### 3. SVG解析模块测试 (`svg_parser_test.dart`)
- ✅ 简单SVG符号解析
- ✅ 多个符号解析
- ✅ 缺失属性处理
- ✅ 路径属性解析
- ✅ 空SVG处理
- ✅ 格式错误SVG处理
- ✅ 嵌套元素处理
- ✅ 路径顺序保持

### 4. 代码生成模块测试 (`generator_test.dart`)
- ✅ null safety代码生成
- ✅ 非null safety代码生成
- ✅ 数字前缀图标处理
- ✅ 图标前缀修剪
- ✅ 特殊字符处理
- ✅ 目录创建
- ✅ 文件清理
- ✅ 多色图标SVG生成
- ✅ 空符号列表处理
- ✅ 字符串到枚举转换

### 5. 构建器模块测试 (`builder_test.dart`)
- ✅ 构建扩展配置
- ✅ 有效配置构建
- ✅ 缺失配置警告
- ✅ 无效symbol_url警告
- ✅ 格式错误pubspec.yaml处理
- ✅ 日志信息验证
- ✅ 工厂函数测试

### 6. Widget组件测试 (`widget_test.dart`)
- ✅ 枚举图标名称渲染
- ✅ 字符串图标名称渲染
- ✅ 自定义尺寸应用
- ✅ 自定义颜色应用
- ✅ 颜色数组应用
- ✅ 默认尺寸使用
- ✅ 多图标渲染
- ✅ 不同Widget上下文渲染
- ✅ 无效图标名称处理
- ✅ ListView中渲染
- ✅ 属性变化更新
- ✅ 颜色系统测试
- ✅ 名称转换测试
- ✅ 扩展方法测试

### 7. 集成测试 (`integration_test.dart`)
- ✅ 命令行工具集成测试
- ✅ 依赖包安装测试
- ✅ 代码分析测试
- ✅ 二进制编译测试
- ✅ build_runner可用性测试
- ✅ 生成代码有效性测试
- ✅ 无效URL处理测试
- ✅ 项目结构验证
- ✅ 配置文件验证
- ✅ 错误处理集成测试

## 运行测试

### 前置条件

确保已安装Dart SDK：

```bash
# 安装Flutter/Dart SDK
# 请参考官方文档: https://flutter.dev/docs/get-started/install

# 验证安装
dart --version
flutter --version
```

### 安装依赖

```bash
cd /workspaces/flutter_iconfont_generator
dart pub get
```

### 运行测试

#### 运行所有测试
```bash
# 方法1: 使用测试脚本
dart run test/run_tests.dart

# 方法2: 使用dart test命令
dart test

# 方法3: 运行特定测试文件
dart test test/config_test.dart
```

#### 运行覆盖率测试
```bash
# 生成覆盖率报告
dart run test/run_tests.dart --coverage

# 或者使用dart test
dart test --coverage=coverage

# 生成HTML报告 (需要安装lcov)
genhtml -o coverage/html coverage/lcov.info
```

#### 运行特定测试组
```bash
# 运行单元测试
dart test test/config_test.dart test/svg_parser_test.dart test/fetcher_test.dart test/generator_test.dart

# 运行Widget测试
dart test test/widget_test.dart

# 运行集成测试
dart test test/integration_test.dart test/builder_test.dart
```

### 测试输出示例

```
🧪 Running Flutter IconFont Generator Tests...

🔍 Running test/config_test.dart...
✅ test/config_test.dart PASSED

🔍 Running test/svg_parser_test.dart...
✅ test/svg_parser_test.dart PASSED

🔍 Running test/fetcher_test.dart...
✅ test/fetcher_test.dart PASSED

🔍 Running test/generator_test.dart...
✅ test/generator_test.dart PASSED

🔍 Running test/builder_test.dart...
✅ test/builder_test.dart PASSED

🔍 Running test/widget_test.dart...
✅ test/widget_test.dart PASSED

🔍 Running test/integration_test.dart...
✅ test/integration_test.dart PASSED

📋 Test Results Summary:
==================================================
test/config_test.dart              ✅ PASSED
test/svg_parser_test.dart          ✅ PASSED
test/fetcher_test.dart              ✅ PASSED
test/generator_test.dart            ✅ PASSED
test/builder_test.dart              ✅ PASSED
test/widget_test.dart               ✅ PASSED
test/integration_test.dart          ✅ PASSED
==================================================
🎉 All tests PASSED!
```

## 测试技术栈

- **测试框架**: `flutter_test` - Flutter官方测试框架
- **Mock框架**: `http/testing.dart` - HTTP请求模拟
- **构建测试**: `build_test` - 代码生成构建测试
- **Widget测试**: `flutter_test` - Flutter Widget测试
- **集成测试**: `process` - 进程执行测试

## 测试最佳实践

### 1. 单元测试原则
- 每个测试只验证一个功能点
- 测试应该是独立的，不依赖其他测试
- 使用描述性的测试名称
- 遵循 AAA 模式 (Arrange, Act, Assert)

### 2. Mock使用
```dart
// 示例：Mock HTTP请求
final mockClient = MockClient((request) async {
  return http.Response('mock response', 200);
});
```

### 3. 异步测试
```dart
test('async operation', () async {
  final result = await someAsyncFunction();
  expect(result, isNotNull);
});
```

### 4. Widget测试
```dart
testWidgets('widget test', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### 5. 文件系统测试
```dart
setUp(() async {
  tempDir = await Directory.systemTemp.createTemp('test_');
});

tearDown(() async {
  if (await tempDir.exists()) {
    await tempDir.delete(recursive: true);
  }
});
```

## 持续集成

### GitHub Actions 配置示例

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.0'
    - run: dart pub get
    - run: dart analyze
    - run: dart test
    - run: dart test --coverage=coverage
    - uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

## 故障排除

### 常见问题

1. **依赖安装失败**
   ```bash
   dart pub get --verbose
   ```

2. **网络测试失败**
   - 检查网络连接
   - 某些测试需要真实的网络环境

3. **文件权限错误**
   ```bash
   chmod +x test/run_tests.dart
   ```

4. **覆盖率工具缺失**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install lcov
   
   # macOS
   brew install lcov
   ```

### 调试测试

```bash
# 详细输出
dart test --reporter=expanded

# 运行单个测试
dart test test/config_test.dart --name="should create from map"

# 调试模式
dart test --pause-after-load
```

## 贡献指南

### 添加新测试

1. 创建测试文件在 `test/` 目录
2. 导入必要的测试包
3. 编写测试用例
4. 更新 `run_tests.dart` 脚本
5. 运行测试确保通过

### 测试命名规范

- 文件名: `feature_test.dart`
- 测试组: `group('FeatureName', () { ... })`
- 测试用例: `test('should do something when condition', () { ... })`

### 代码覆盖率要求

- 单元测试覆盖率应达到 90% 以上
- 关键路径和错误处理必须有测试覆盖
- 新功能必须包含对应的测试用例

---

这套完整的测试用例确保了Flutter图标字体生成器的稳定性和可靠性，涵盖了从配置解析到Widget渲染的完整流程。通过这些测试，开发者可以安全地进行重构和功能扩展，同时保证代码质量。
