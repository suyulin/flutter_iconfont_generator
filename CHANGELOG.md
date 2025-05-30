## 2.0.0

### 🎉 Major Release - Complete Rewrite

#### ✨ New Features
- **Pure Dart Implementation**: No Node.js dependency, uses build_runner for code generation
- **Multi-color Icon Support**: Render multi-color icons with custom color support
- **SVG-based Rendering**: No font files needed, smaller bundle size
- **Null Safety**: Full Dart null safety support
- **Multiple Generation Methods**: Support for command-line tools and build_runner
- **Automated Icon Fetching**: Automatically fetch latest icons from iconfont.cn

#### 🔧 Improvements
- **Fixed camelCase Conversion**: Proper icon name conversion from kebab-case to camelCase
- **Fixed Prefix Trimming**: Correct removal of "icon-" prefix without breaking icon names
- **Enhanced SVG Parsing**: Better XML/SVG content parsing and embedding
- **Improved Error Handling**: Better error messages and validation
- **Complete Example App**: Full Flutter example showcasing all features

#### 🛠️ Technical Changes
- Rewrote `_toCamelCase` function for proper name conversion
- Fixed prefix trimming logic in `_generateEnumCase`
- Updated to use 96-icon font set (font_4321927_izjniu4v5to.js)
- Added comprehensive test suite with validation scripts
- Improved project structure and documentation

#### 📚 Documentation
- Complete usage guide with examples
- API documentation for all public methods
- Step-by-step setup instructions
- Multiple example use cases

#### 🧪 Testing
- Added comprehensive test suite
- Static code analysis validation
- Icon generation verification scripts
- Example app integration tests

### Breaking Changes
- Minimum Dart SDK version: 2.17.0
- Changed configuration format in pubspec.yaml
- Updated API for IconFont widget usage

### Migration Guide
1. Update your pubspec.yaml dependencies
2. Run `dart pub get`
3. Update iconfont configuration in pubspec.yaml
4. Regenerate icons using `dart run bin/simple_generator.dart`
5. Update import paths in your code

---

## 1.x.x (Previous versions)

Earlier versions of this package with different implementation approaches.
