import 'package:flutter/material.dart';
import 'iconfont/iconfont.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IconFont Demo',
      home: IconFontDemo(),
    );
  }
}

class IconFontDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IconFont Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基本使用:', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Row(
              children: [
                IconFont(IconNames.values.first, size: 24),
                SizedBox(width: 16),
                IconFont(IconNames.values.first, size: 32, color: '#ff0000'),
                SizedBox(width: 16),
                IconFont(IconNames.values.first, size: 40, color: '#00ff00'),
              ],
            ),
            SizedBox(height: 32),
            Text('所有图标:', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: IconNames.values.length,
                itemBuilder: (context, index) {
                  final iconName = IconNames.values[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconFont(iconName, size: 32),
                      SizedBox(height: 8),
                      Text(
                        iconName.name,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
