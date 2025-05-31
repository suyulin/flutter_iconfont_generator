#!/usr/bin/env dart

import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  try {
    print('Testing URL fetch...');
    final url = 'https://at.alicdn.com/t/c/font_4937193_3aohv86wocr.js';
    print('Fetching: $url');

    final response = await http.get(Uri.parse(url));
    print('Status: ${response.statusCode}');
    print('Body length: ${response.body.length}');

    if (response.body.length > 0) {
      print('First 200 chars:');
      print(response.body.substring(
          0, response.body.length < 200 ? response.body.length : 200));
    }
  } catch (e) {
    print('Error: $e');
  }
}
