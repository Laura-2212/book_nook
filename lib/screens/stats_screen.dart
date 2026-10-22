import 'package:flutter/material.dart';
import '../services/book_service.dart';
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Minhas Estatísticas')), body: StreamBuilder<Map<String, dynamic>>(
    stream: BookService().watchStats(), builder: (context, snapshot) {
      if (snapshot.hasError) return const Center(child: Text('Erro ao carregar estatísticas'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final stats = snapshot.data!;
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.auto_stories, size: 70), const SizedBox(height: 16),
        Text('${stats['livrosLidos'] ?? 0} livros lidos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12), Text('${stats['paginasLidas'] ?? 0} páginas lidas', style: Theme.of(context).textTheme.titleLarge),
      ]));
    },
  ));
}
