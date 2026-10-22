import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
class BookService {
  String get uid => FirebaseAuth.instance.currentUser!.uid;
  CollectionReference<Map<String, dynamic>> get books => FirebaseFirestore.instance.collection('users').doc(uid).collection('books');
  Stream<List<Book>> watchBooks() => books.snapshots().map((snapshot) => snapshot.docs.map((d) => Book.fromFirestore(d.id, d.data())).toList());
  Future<void> save(Book book, String status) async => books.doc(book.id).set({...book.toMap(), 'status': status});
  Future<void> move(String id, String status) async => books.doc(id).update({'status': status});
  Future<void> remove(String id) => books.doc(id).delete();
  Stream<Map<String, dynamic>> watchStats() => FirebaseFirestore.instance.collection('users').doc(uid).collection('stats').doc('summary').snapshots().map((d) => d.data() ?? {});
}
