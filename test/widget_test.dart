import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Mock IconFont widget for testing
enum IconNames {
  home,
  user,
  settings,
}

extension IconNamesExtension on IconNames {
  String get name => toString().split('.').last;
}

class IconFont extends StatelessWidget {
  const IconFont(
    this.iconName, {
    super.key,
    this.size = 18,
    this.color,
    this.colors,
  });

  final dynamic iconName;
  final double size;
  final String? color;
  final List<String>? colors;

  IconNames get _iconName => _getIconNames(iconName);

  static IconNames _getIconNames(dynamic iconName) {
    if (iconName is IconNames) return iconName;
    
    switch (iconName.toString()) {
      case 'home':
        return IconNames.home;
      case 'user':
        return IconNames.user;
      case 'settings':
        return IconNames.settings;
    }
    return IconNames.values.first;
  }

  static String getColor(int index, String? color, List<String>? colors, String defaultColor) {
    if (color?.isNotEmpty == true) return color!;
    if (colors != null && colors.length > index) return colors[index];
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final String svgXml;
    
    switch (_iconName) {
      case IconNames.home:
        svgXml = '''
          <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
            <path d="M512 128L896 384v512H640V640H384v256H128V384z" fill="${getColor(0, color, colors, '#333333')}" />
          </svg>
        ''';
        break;
      case IconNames.user:
        svgXml = '''
          <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
            <path d="M512 512c141.385 0 256-114.615 256-256S653.385 0 512 0 256 114.615 256 256s114.615 256 256 256z" fill="${getColor(0, color, colors, '#666666')}" />
          </svg>
        ''';
        break;
      case IconNames.settings:
        svgXml = '''
          <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
            <path d="M512 640c-70.692 0-128-57.308-128-128s57.308-128 128-128 128 57.308 128 128-57.308 128-128 128z" fill="${getColor(0, color, colors, '#999999')}" />
            <path d="M950.857 563.428c0-4.571-2.286-9.143-4.571-12L857.714 512l88.571-39.428c2.286-2.857 4.571-7.429 4.571-12v-96c0-8-6.857-14.857-14.857-14.857h-108.571c-2.286-6.857-4.571-13.714-8-20l61.714-61.714c5.714-5.714 5.714-14.857 0-20l-67.428-67.428c-5.714-5.714-14.857-5.714-20 0L731 242.286c-6.286-3.429-13.143-5.714-20-8V126.857c0-8-6.857-14.857-14.857-14.857h-96c-4.571 0-9.143 2.286-12 4.571L549.714 205.143 510.286 116.571c-2.857-2.286-7.429-4.571-12-4.571h-96c-8 0-14.857 6.857-14.857 14.857v108.571c-6.857 2.286-13.714 4.571-20 8L295.714 181.714c-5.714-5.714-14.857-5.714-20 0L208.286 249.143c-5.714 5.714-5.714 14.857 0 20l61.714 61.714c-3.429 6.286-5.714 13.143-8 20H154.571c-8 0-14.857 6.857-14.857 14.857v96c0 4.571 2.286 9.143 4.571 12L232.857 512l-88.571 39.428c-2.286 2.857-4.571 7.429-4.571 12v96c0 8 6.857 14.857 14.857 14.857h108.571c2.286 6.857 4.571 13.714 8 20l-61.714 61.714c-5.714 5.714-5.714 14.857 0 20l67.428 67.428c5.714 5.714 14.857 5.714 20 0l61.714-61.714c6.286 3.429 13.143 5.714 20 8v108.571c0 8 6.857 14.857 14.857 14.857h96c4.571 0 9.143-2.286 12-4.571L474.286 818.857 513.714 907.429c2.857 2.286 7.429 4.571 12 4.571h96c8 0 14.857-6.857 14.857-14.857V788.571c6.857-2.286 13.714-4.571 20-8l61.714 61.714c5.714 5.714 14.857 5.714 20 0l67.428-67.428c5.714-5.714 5.714-14.857 0-20l-61.714-61.714c3.429-6.286 5.714-13.143 8-20h108.571c8 0 14.857-6.857 14.857-14.857v-96z" fill="${getColor(1, color, colors, '#cccccc')}" />
          </svg>
        ''';
        break;
      default:
        svgXml = '';
    }

    return SvgPicture.string(
      svgXml,
      width: size,
      height: size,
    );
  }
}

void main() {
  group('IconFont Widget', () {
    testWidgets('should render with enum icon name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont(IconNames.home),
          ),
        ),
      );

      expect(find.byType(IconFont), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should render with string icon name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont('user'),
          ),
        ),
      );

      expect(find.byType(IconFont), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should apply custom size', (WidgetTester tester) async {
      const customSize = 32.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont(IconNames.home, size: customSize),
          ),
        ),
      );

      final iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont.size, equals(customSize));
    });

    testWidgets('should apply custom color', (WidgetTester tester) async {
      const customColor = '#ff0000';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont(IconNames.home, color: customColor),
          ),
        ),
      );

      final iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont.color, equals(customColor));
    });

    testWidgets('should apply custom colors array', (WidgetTester tester) async {
      const customColors = ['#ff0000', '#00ff00', '#0000ff'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont(IconNames.settings, colors: customColors),
          ),
        ),
      );

      final iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont.colors, equals(customColors));
    });

    testWidgets('should use default size when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont(IconNames.home),
          ),
        ),
      );

      final iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont.size, equals(18.0)); // Default size
    });

    testWidgets('should handle multiple icons in same widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IconFont(IconNames.home, size: 24),
                IconFont(IconNames.user, size: 32),
                IconFont(IconNames.settings, size: 16),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(IconFont), findsNWidgets(3));
      expect(find.byType(SvgPicture), findsNWidgets(3));
    });

    testWidgets('should render in different widget contexts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: IconFont(IconNames.home),
            ),
            body: Center(
              child: IconFont(IconNames.user, size: 48),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: IconFont(IconNames.settings),
            ),
          ),
        ),
      );

      expect(find.byType(IconFont), findsNWidgets(3));
    });

    testWidgets('should handle invalid icon name gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFont('invalid_icon_name'),
          ),
        ),
      );

      expect(find.byType(IconFont), findsOneWidget);
      // Should fall back to first enum value
      final iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont._iconName, equals(IconNames.home));
    });

    testWidgets('should render properly in ListView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: IconNames.values.map((iconName) =>
                ListTile(
                  leading: IconFont(iconName, size: 24),
                  title: Text(iconName.name),
                ),
              ).toList(),
            ),
          ),
        ),
      );

      expect(find.byType(IconFont), findsNWidgets(IconNames.values.length));
      expect(find.byType(ListTile), findsNWidgets(IconNames.values.length));
    });

    testWidgets('should update when icon properties change', (WidgetTester tester) async {
      IconNames currentIcon = IconNames.home;
      double currentSize = 24.0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  IconFont(currentIcon, size: currentSize),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIcon = IconNames.user;
                        currentSize = 32.0;
                      });
                    },
                    child: Text('Change Icon'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initial state
      IconFont iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont._iconName, equals(IconNames.home));
      expect(iconFont.size, equals(24.0));

      // Tap button to change state
      await tester.tap(find.text('Change Icon'));
      await tester.pumpAndSettle();

      // Updated state
      iconFont = tester.widget<IconFont>(find.byType(IconFont));
      expect(iconFont._iconName, equals(IconNames.user));
      expect(iconFont.size, equals(32.0));
    });
  });

  group('IconFont Color System', () {
    test('getColor should return custom color when provided', () {
      final result = IconFont.getColor(0, '#ff0000', null, '#333333');
      expect(result, equals('#ff0000'));
    });

    test('getColor should return color from array when no custom color', () {
      final colors = ['#ff0000', '#00ff00', '#0000ff'];
      final result = IconFont.getColor(1, null, colors, '#333333');
      expect(result, equals('#00ff00'));
    });

    test('getColor should return default color when no custom options', () {
      final result = IconFont.getColor(0, null, null, '#333333');
      expect(result, equals('#333333'));
    });

    test('getColor should return default when index exceeds colors array', () {
      final colors = ['#ff0000', '#00ff00'];
      final result = IconFont.getColor(5, null, colors, '#333333');
      expect(result, equals('#333333'));
    });

    test('getColor should prioritize custom color over colors array', () {
      final colors = ['#ff0000', '#00ff00', '#0000ff'];
      final result = IconFont.getColor(1, '#ffffff', colors, '#333333');
      expect(result, equals('#ffffff'));
    });

    test('getColor should handle empty color string', () {
      final result = IconFont.getColor(0, '', ['#ff0000'], '#333333');
      expect(result, equals('#ff0000'));
    });

    test('getColor should handle empty colors array', () {
      final result = IconFont.getColor(0, null, [], '#333333');
      expect(result, equals('#333333'));
    });
  });

  group('IconFont Name Conversion', () {
    test('_getIconNames should return enum when passed enum', () {
      final result = IconFont._getIconNames(IconNames.user);
      expect(result, equals(IconNames.user));
    });

    test('_getIconNames should convert string to enum', () {
      final result = IconFont._getIconNames('home');
      expect(result, equals(IconNames.home));
    });

    test('_getIconNames should handle unknown string', () {
      final result = IconFont._getIconNames('unknown');
      expect(result, equals(IconNames.home)); // Should return first enum value
    });

    test('_getIconNames should handle null input', () {
      final result = IconFont._getIconNames(null);
      expect(result, equals(IconNames.home)); // Should return first enum value
    });

    test('_getIconNames should handle numeric input', () {
      final result = IconFont._getIconNames(123);
      expect(result, equals(IconNames.home)); // Should return first enum value
    });
  });

  group('IconNames Extension', () {
    test('name extension should return correct enum name', () {
      expect(IconNames.home.name, equals('home'));
      expect(IconNames.user.name, equals('user'));
      expect(IconNames.settings.name, equals('settings'));
    });

    test('name extension should work with all enum values', () {
      for (final iconName in IconNames.values) {
        expect(iconName.name, isA<String>());
        expect(iconName.name.isNotEmpty, isTrue);
      }
    });
  });
}
