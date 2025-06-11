# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-06-11

### Changed
- 📚 Updated documentation with better examples and usage instructions
- 🔧 Enhanced error handling and validation
- 🎨 Improved code formatting and linting compliance

### Fixed
- 🐛 Minor bug fixes and stability improvements
- 📋 Fixed example app configuration and dependencies

## [1.0.0] - 2025-05-31

### Added
- 🚀 Command line tool for generating Flutter icon widgets from iconfont.cn
- 🎨 Multi-color icon support with custom color rendering
- 📦 SVG-based rendering for smaller bundle size (no font files needed)
- 🔄 Automated icon fetching and Dart code generation
- 🛡️ Full null safety support
- ⚡ Global installation support via `dart pub global activate`

### Features
- Convert iconfont.cn symbol URLs to Flutter widgets
- Configurable icon prefix trimming
- Customizable save directory and default icon size
- Support for both single-color and multi-color icons
- Pure Dart components with flutter_svg dependency
- Easy configuration through pubspec.yaml

### Dependencies
- flutter_svg: ^2.0.0
- http: ^1.0.0  
- xml: ^6.3.0
- path: ^1.8.3
- yaml: ^3.1.2

### Requirements
- Dart SDK: >=2.17.0 <4.0.0
- Flutter: >=3.0.0
