class Book {
  final String id, title, author, cover, status;
  final int pages;
  const Book({required this.id, required this.title, required this.author, required this.cover, required this.pages, this.status = 'quero_ler'});
  factory Book.fromGoogle(Map<String, dynamic> json) {
    final info = (json['volumeInfo'] as Map<String, dynamic>?) ?? {};
    final images = (info['imageLinks'] as Map<String, dynamic>?) ?? {};
    return Book(
      id: json['id']?.toString() ?? '', title: info['title']?.toString() ?? 'Sem título',
      author: ((info['authors'] as List?) ?? ['Autor desconhecido']).join(', '),
      cover: (images['thumbnail'] ?? '').toString().replaceFirst('http://', 'https://'),
      pages: (info['pageCount'] as num?)?.toInt() ?? 0,
    );
  }
  factory Book.fromFirestore(String id, Map<String, dynamic> data) => Book(
    id: id, title: data['title'] ?? '', author: data['author'] ?? '', cover: data['cover'] ?? '',
    pages: (data['pages'] as num?)?.toInt() ?? 0, status: data['status'] ?? 'quero_ler',
  );
  Map<String, dynamic> toMap() => {'title': title, 'author': author, 'cover': cover, 'pages': pages, 'status': status};
}
