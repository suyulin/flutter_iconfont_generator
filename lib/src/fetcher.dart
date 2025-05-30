import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches SVG content from iconfont.cn
class IconFontFetcher {
  static Future<String> fetchSvgContent(String symbolUrl) async {
    try {
      // Convert symbol URL to JS URL if needed
      String jsUrl = symbolUrl;
      if (!jsUrl.startsWith('http')) {
        jsUrl = 'https:$jsUrl';
      }

      // If it's a symbol URL, convert to JS URL
      if (jsUrl.contains('symbol')) {
        jsUrl = jsUrl.replaceAll('symbol', 'js');
      }

      final response = await http.get(Uri.parse(jsUrl));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch iconfont data: ${response.statusCode}');
      }

      final content = response.body;

      // Extract SVG content from JS
      final svgMatch =
          RegExp(r'<svg[^>]*>(.*?)</svg>', dotAll: true).firstMatch(content);
      if (svgMatch == null) {
        throw Exception('No SVG content found in response');
      }

      return '<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">${svgMatch.group(1)}</svg>';
    } catch (e) {
      throw Exception('Error fetching iconfont data: $e');
    }
  }
}
