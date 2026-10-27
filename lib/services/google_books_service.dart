
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class GoogleBooksService {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_BOOKS_API_KEY',
  );

  Future<List<Book>> search(String query) async {
    final text = query.trim();
    if (text.isEmpty) return [];

    if (apiKey.isEmpty) {
      throw Exception('API_KEY_MISSING');
    }

    final uri = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      {
        'q': text,
        'maxResults': '20',
        'key': apiKey,
      },
    );

    http.Response response;

    try {
      response = await http.get(uri).timeout(
        const Duration(seconds: 20),
      );
    } on TimeoutException {
      throw Exception('TIMEOUT');
    } catch (_) {
      throw Exception('NETWORK_ERROR');
    }

    switch (response.statusCode) {
      case 200:
        break;
      case 400:
        throw Exception('INVALID_REQUEST');
      case 403:
        throw Exception('API_FORBIDDEN');
      case 429:
        throw Exception('API_QUOTA_EXCEEDED');
      default:
        throw Exception('HTTP_${response.statusCode}');
    }

    try {
      final data = jsonDecode(response.body)
          as Map<String, dynamic>;

      final items = data['items'] as List? ?? [];

      final books = <Book>[];

      for (final item in items) {
        try {
          final book = Book.fromGoogle(
            Map<String, dynamic>.from(item as Map),
          );

          if (book.id.isNotEmpty) {
            books.add(book);
          }
        } catch (_) {
          // Ignora livros com dados incompletos.
        }
      }

      return books;
    } catch (_) {
      throw Exception('INVALID_BOOK_DATA');
    }
  }
}
