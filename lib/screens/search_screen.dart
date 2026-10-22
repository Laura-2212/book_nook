import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/google_books_service.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController();
  List<Book> results = []; bool loading = false; String? error;
  @override void dispose() { query.dispose(); super.dispose(); }
  Future<void> search() async {
    if (query.text.trim().isEmpty) return;
    setState(() { loading = true; error = null; });
    try { final books = await GoogleBooksService().search(query.text.trim()); if (mounted) setState(() => results = books); }
    catch (_) { if (mounted) setState(() => error = 'Falha ao buscar. Verifique sua conexão.'); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Buscar livros')), body: Column(children: [
    Padding(padding: const EdgeInsets.all(12), child: TextField(controller: query, onSubmitted: (_) => search(), decoration: InputDecoration(labelText: 'Título ou autor', suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: search)))),
    if (loading) const LinearProgressIndicator(), if (error != null) Padding(padding: const EdgeInsets.all(12), child: Text(error!)),
    Expanded(child: ListView.builder(itemCount: results.length, itemBuilder: (context, i) {
      final book = results[i];
      return ListTile(leading: book.cover.isEmpty ? const Icon(Icons.book) : Image.network(book.cover, width: 48, errorBuilder: (_, __, ___) => const Icon(Icons.book)),
        title: Text(book.title), subtitle: Text('${book.author} • ${book.pages} páginas'),
        trailing: PopupMenuButton<String>(tooltip: 'Adicionar à estante', icon: const Icon(Icons.add), onSelected: (status) async {
          try { await BookService().save(book, status); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livro salvo!'))); }
          catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar livro'))); }
        }, itemBuilder: (_) => const [PopupMenuItem(value: 'quero_ler', child: Text('Quero Ler')), PopupMenuItem(value: 'lendo', child: Text('Lendo')), PopupMenuItem(value: 'lido', child: Text('Lidos'))]));
    })),
  ]));
}
