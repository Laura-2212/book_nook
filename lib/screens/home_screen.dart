import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import 'search_screen.dart';
import 'stats_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const statuses = {'quero_ler': 'Quero Ler', 'lendo': 'Lendo', 'lido': 'Lidos'};
  @override Widget build(BuildContext context) => DefaultTabController(length: 3, child: Scaffold(
    appBar: AppBar(title: const Text('Book Nook'), actions: [
      IconButton(tooltip: 'Estatísticas', icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()))),
      IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: () => AuthService().logout()),
    ], bottom: const TabBar(tabs: [Tab(text: 'Quero Ler'), Tab(text: 'Lendo'), Tab(text: 'Lidos')])),
    body: StreamBuilder<List<Book>>(stream: BookService().watchBooks(), builder: (context, snapshot) {
      if (snapshot.hasError) return const Center(child: Text('Erro ao carregar livros'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      return TabBarView(children: statuses.keys.map((status) {
        final books = snapshot.data!.where((b) => b.status == status).toList();
        if (books.isEmpty) return const Center(child: Text('Nenhum livro nesta estante'));
        return ListView.builder(itemCount: books.length, itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            leading: book.cover.isEmpty ? const Icon(Icons.book, size: 48) : Image.network(book.cover, width: 48, errorBuilder: (_, __, ___) => const Icon(Icons.book)),
            title: Text(book.title), subtitle: Text('${book.author} • ${book.pages} páginas'),
            trailing: PopupMenuButton<String>(tooltip: 'Alterar estante', onSelected: (value) async {
              try { if (value == 'remove') { await BookService().remove(book.id); } else { await BookService().move(book.id, value); } }
              catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível atualizar o livro'))); }
            }, itemBuilder: (_) => [...statuses.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value))), const PopupMenuItem(value: 'remove', child: Text('Remover'))]),
          );
        });
      }).toList());
    }),
    floatingActionButton: FloatingActionButton.extended(icon: const Icon(Icons.search), label: const Text('Buscar livros'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
  ));
}
