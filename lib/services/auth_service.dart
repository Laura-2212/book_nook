import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final _auth = FirebaseAuth.instance;
  Future<void> login(String email, String password) async => _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  Future<void> register(String email, String password) async => _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  Future<void> logout() => _auth.signOut();
}
