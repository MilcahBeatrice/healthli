import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openfda_drug_model.dart';

class OpenFdaService {
  static Future<List<OpenFdaDrug>> searchDrugs(String query) async {
    final url = Uri.parse(
      'https://api.fda.gov/drug/ndc.json?search=generic_name:"$query"&limit=10',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] == null) throw Exception('No results found');
      return (data['results'] as List)
          .map((e) => OpenFdaDrug.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch drug info');
    }
  }
}
