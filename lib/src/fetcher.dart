import 'package:http/http.dart' as http;

/// Fetches SVG content from iconfont.cn and processes it for parsing.
///
/// This class handles the network communication with iconfont.cn to download
/// icon data and converts it from the JavaScript format to pure SVG format
/// that can be parsed by [SvgParser].
///
/// ## URL Processing
///
/// The fetcher automatically handles different URL formats:
/// - Protocol-relative URLs: `//at.alicdn.com/t/font_xxx.js` → `https://at.alicdn.com/t/font_xxx.js`
/// - Symbol URLs: `https://at.alicdn.com/t/font_xxx.symbol` → `https://at.alicdn.com/t/font_xxx.js`
/// - Already valid HTTP/HTTPS URLs are used as-is
///
/// ## Content Processing
///
/// Iconfont.cn serves icons as JavaScript files containing SVG data. This class:
/// 1. Downloads the JavaScript content
/// 2. Extracts the SVG content using regex patterns
/// 3. Wraps it in proper SVG tags with namespace declarations
/// 4. Returns clean SVG content ready for parsing
///
/// ## Usage
///
/// ```dart
/// try {
///   final svgContent = await IconFontFetcher.fetchSvgContent(
///     '//at.alicdn.com/t/font_123456_abcdef.js'
///   );
///   print('Fetched SVG content: ${svgContent.length} characters');
/// } catch (e) {
///   print('Failed to fetch icons: $e');
/// }
/// ```
///
/// ## Error Handling
///
/// The fetcher includes comprehensive error handling for:
/// - Network connectivity issues
/// - HTTP error status codes
/// - Invalid or missing SVG content in responses
/// - Malformed JavaScript responses
///
/// All errors are wrapped in descriptive [Exception] objects with context.
class IconFontFetcher {
  /// Fetches and processes SVG content from an iconfont.cn URL.
  ///
  /// This method handles the complete workflow of downloading icon data from
  /// iconfont.cn and converting it to a format suitable for SVG parsing.
  ///
  /// ## URL Processing
  ///
  /// The method automatically processes different URL formats:
  /// 
  /// | Input Format | Output Format |
  /// |-------------|---------------|
  /// | `//at.alicdn.com/t/font_xxx.js` | `https://at.alicdn.com/t/font_xxx.js` |
  /// | `//at.alicdn.com/t/font_xxx.symbol` | `https://at.alicdn.com/t/font_xxx.js` |
  /// | `http://at.alicdn.com/t/font_xxx.js` | Used as-is |
  /// | `https://at.alicdn.com/t/font_xxx.js` | Used as-is |
  ///
  /// ## Content Extraction
  ///
  /// The JavaScript response typically contains SVG content embedded like:
  /// ```javascript
  /// !function(){ 
  ///   var svg = '<svg><symbol id="icon-home">...</symbol></svg>';
  ///   // ... DOM manipulation code
  /// }();
  /// ```
  ///
  /// The method extracts the SVG content and wraps it in proper SVG tags:
  /// ```xml
  /// <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  ///   <symbol id="icon-home">...</symbol>
  /// </svg>
  /// ```
  ///
  /// ## Network Configuration
  ///
  /// - Uses standard HTTP GET requests
  /// - No special headers or authentication required
  /// - Follows redirects automatically
  /// - Times out according to http package defaults
  ///
  /// Parameters:
  /// - [symbolUrl]: The iconfont.cn URL to fetch icons from
  ///
  /// Returns:
  /// - Clean SVG content as a string, ready for parsing
  ///
  /// Throws:
  /// - [Exception]: If network request fails, returns non-200 status, or no SVG content found
  ///
  /// Example:
  /// ```dart
  /// // Fetch from protocol-relative URL
  /// final svgContent = await IconFontFetcher.fetchSvgContent(
  ///   '//at.alicdn.com/t/font_123456_abcdef.js'
  /// );
  ///
  /// // Fetch from full HTTPS URL
  /// final svgContent2 = await IconFontFetcher.fetchSvgContent(
  ///   'https://at.alicdn.com/t/font_789012_ghijkl.js'
  /// );
  ///
  /// // Handle errors
  /// try {
  ///   final content = await IconFontFetcher.fetchSvgContent(url);
  ///   // Process content...
  /// } catch (e) {
  ///   print('Error fetching icons: $e');
  ///   // Handle error...
  /// }
  /// ```
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
