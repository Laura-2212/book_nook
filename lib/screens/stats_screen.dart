
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Faça login para ver suas estatísticas.')),
      );
    }

    final books = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('books')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Estatísticas')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: books,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar livros do Firestore.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          int livrosLidos = 0;
          int paginasLidas = 0;
          int lendo = 0;
          int queroLer = 0;

          for (final doc in snapshot.data!.docs) {
            final book = doc.data();
            final status = book['status']?.toString() ?? '';
            final pages = book['pages'] ?? book['pageCount'] ?? 0;

            final paginas = pages is num
                ? pages.toInt()
                : int.tryParse(pages.toString()) ?? 0;

            if (status == 'lido') {
              livrosLidos++;
              paginasLidas += paginas;
            } else if (status == 'lendo') {
              lendo++;
            } else if (status == 'quero_ler') {
              queroLer++;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.auto_stories,
                size: 75,
                color: Colors.brown,
              ),
              const SizedBox(height: 15),
              Text(
                'Minha jornada literária',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 25),
              _card(Icons.check_circle, 'Livros lidos', livrosLidos),
              _card(Icons.menu_book, 'Páginas lidas', paginasLidas),
              _card(Icons.bookmark, 'Lendo', lendo),
              _card(Icons.favorite, 'Quero ler', queroLer),
            ],
          );
        },
      ),
    );
  }

  Widget _card(IconData icon, String title, int value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown, size: 32),
        title: Text(title),
        trailing: Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
