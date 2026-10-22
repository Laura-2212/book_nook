import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
class GoogleBooksService {
  Future<List<Book>> search(String query) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': query, 'maxResults': '20'});
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Não foi possível buscar livros.');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ((json['items'] as List?) ?? []).map((item) => Book.fromGoogle(item as Map<String, dynamic>)).where((b) => b.id.isNotEmpty).toList();
  }
}
