
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/google_books_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController();

  List<Book> results = [];
  bool loading = false;
  bool searched = false;
  String? error;

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> search() async {
    if (query.text.trim().isEmpty || loading) return;

    setState(() {
      loading = true;
      error = null;
      results = [];
      searched = false;
    });

    try {
      final books = await GoogleBooksService()
          .search(query.text.trim());

      if (!mounted) return;

      setState(() {
        results = books;
        searched = true;
      });
    } catch (e) {
      if (!mounted) return;

      final code = e.toString();
      String message;

      if (code.contains('API_KEY_MISSING')) {
        message = 'Chave da Google Books API não configurada.';
      } else if (code.contains('API_QUOTA_EXCEEDED')) {
        message = 'Limite de pesquisas atingido. '
            'Verifique sua cota no Google Cloud.';
      } else if (code.contains('API_FORBIDDEN')) {
        message = 'Acesso negado pela API. '
            'Verifique sua chave no Google Cloud.';
      } else if (code.contains('TIMEOUT')) {
        message = 'A pesquisa demorou demais. Tente novamente.';
      } else if (code.contains('NETWORK_ERROR')) {
        message = 'Falha de conexão. Verifique sua internet.';
      } else if (code.contains('INVALID_BOOK_DATA')) {
        message = 'Erro ao interpretar os dados dos livros.';
      } else {
        message = 'Erro ao buscar livros. '
            'Verifique a configuração da API.';
      }

      setState(() => error = message);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> saveBook(Book book, String status) async {
    try {
      await BookService().save(book, status);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Livro adicionado à estante!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar livro.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar livros'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                labelText: 'Título ou autor',
                hintText: 'Ex: Harry Potter',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: loading ? null : search,
                ),
              ),
            ),
          ),

          if (loading)
            const LinearProgressIndicator(),

          if (error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: loading ? null : search,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),

          if (!loading &&
              error == null &&
              searched &&
              results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Nenhum livro encontrado.'),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final book = results[i];

                return ListTile(
                  leading: book.cover.isEmpty
                      ? const Icon(Icons.book)
                      : Image.network(
                          book.cover,
                          width: 48,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            imageError,
                            stackTrace,
                          ) => const Icon(Icons.book),
                        ),
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author} • ${book.pages} páginas',
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Adicionar à estante',
                    icon: const Icon(Icons.add),
                    onSelected: (status) =>
                        saveBook(book, status),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'quero_ler',
                        child: Text('Quero Ler'),
                      ),
                      PopupMenuItem(
                        value: 'lendo',
                        child: Text('Lendo'),
                      ),
                      PopupMenuItem(
                        value: 'lido',
                        child: Text('Lidos'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
