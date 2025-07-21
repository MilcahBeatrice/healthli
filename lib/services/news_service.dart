import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class NewsService {
  static const String _baseUrl = 'https://newsdata.io/api/1/news';

  // NewsData.io API key
  static const String _apiKey = 'pub_0e0cddd760b345249db1d086c0f75bd5';

  static Future<List<Map<String, dynamic>>> fetchLatestHealthNews() async {
    final url = Uri.parse(
      '$_baseUrl?apikey=$_apiKey&category=health&language=en',
    );
    log(url.toString());
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch news: ${response.statusCode}');
    }
  }
}
