import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController(), password = TextEditingController();
  bool loading = false;
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (password.text.length < 6) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A senha precisa ter pelo menos 6 caracteres'))); return; }
    setState(() => loading = true);
    try { await AuthService().register(email.text, password.text); if (mounted) Navigator.pop(context); }
    on FirebaseAuthException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Erro no cadastro'))); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro de conexão'))); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Criar conta')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail')),
    TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha (mínimo 6 caracteres)')),
    const SizedBox(height: 20), FilledButton(onPressed: loading ? null : submit, child: Text(loading ? 'Cadastrando...' : 'Cadastrar')),
  ])))));
}
