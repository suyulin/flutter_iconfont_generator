#!/bin/bash

echo "🧹 清理测试代码和临时文件..."

# 删除根目录下的测试文件
cd /Users/suyulin/work/github/flutter_iconfont_generator

echo "删除根目录下的测试文件..."
rm -f CLI_IMPLEMENTATION_COMPLETE.md
rm -f IMPLEMENTATION_SUMMARY.md  
rm -f SYNTAX_ERROR_FIXED.md
rm -f test_cli.dart
rm -f test_cli_fix.dart
rm -f test_cli_manual.sh
rm -f validate_fix.dart

# 删除bin目录下的测试文件
echo "删除bin目录下的测试文件..."
cd bin
rm -f demo.dart
rm -f final_validation.dart
rm -f iconfont_generator_new.dart
rm -f iconfont_generator_working.dart
rm -f simple_generator.dart
rm -f test_all.dart
rm -f test_cli_basic.dart
rm -f test_cli_functionality.dart
rm -f test_config.dart
rm -f test_terminal.dart

# 删除example_app目录下的测试文件
echo "删除example_app目录下的测试文件..."
cd ../example_app
rm -f FIX_VERIFICATION_REPORT.md
rm -f debug_build.dart
rm -f debug_fetch.dart
rm -f debug_generator.dart
rm -f simple_fetch.dart
rm -f test_build.sh
rm -f test_fetch.dart
rm -f test_generator.dart
rm -f test_main.dart
rm -f test_runner.dart
rm -f test_setup.dart
rm -f validate_fix.dart
rm -f working_generator.dart

echo "✅ 清理完成！"

# 显示剩余的核心文件
echo ""
echo "📁 清理后的核心文件结构："
cd /Users/suyulin/work/github/flutter_iconfont_generator
echo "根目录："
ls -1 *.md *.yaml *.sh build.yaml LICENSE 2>/dev/null | sort
echo ""
echo "bin目录："
ls -1 bin/
echo ""
echo "lib目录："
ls -1 lib/
echo ""
echo "example_app主要文件："
ls -1 example_app/*.yaml example_app/*.md example_app/build.yaml 2>/dev/null
