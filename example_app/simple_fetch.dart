import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  try {
    final url = 'https://at.alicdn.com/t/c/font_4937193_3aohv86wocr.js';
    print('Fetching: $url');

    final response = await http.get(Uri.parse(url));
    print('Status code: ${response.statusCode}');
    print('Response length: ${response.body.length}');
    print(
        'First 200 chars: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
  } catch (e) {
    print('Error: $e');
  }
}
