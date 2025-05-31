import 'package:flutter/material.dart';
import 'lib/iconfont/iconfont.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icon Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Icon Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconFont(IconNames.xiaoxi, size: 48, color: '#ff0000'),
              const SizedBox(height: 20),
              const Text('If you see a red icon above, it works!'),
            ],
          ),
        ),
      ),
    );
  }
}
