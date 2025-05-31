#!/bin/bash
echo "Starting build_runner test..."
cd /Users/suyulin/work/github/flutter_iconfont_generator/example_app
echo "Current directory: $(pwd)"
echo "Checking pubspec.yaml exists:"
ls -la pubspec.yaml
echo "Running flutter pub get..."
flutter pub get
echo "Checking build.yaml exists:"
ls -la build.yaml
echo "Running build_runner..."
dart run build_runner build --verbose
echo "Checking generated files:"
ls -la lib/
echo "Done!"
