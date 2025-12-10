import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driveup/screens/login_screen.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController(); // CNH
  final _expYearCtrl = TextEditingController(); // Ano de vencimento

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      _showSnack('Nenhum usuário autenticado.');
      return;
    }

    try {
      _nameCtrl.text = user.displayName ?? 'Usuário';
      _emailCtrl.text = user.email ?? '';

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameCtrl.text = data['name'] ?? _nameCtrl.text;
        _emailCtrl.text = data['email'] ?? _emailCtrl.text;
        _cardNumberCtrl.text = data['cnhNumber'] ?? '';
        _expYearCtrl.text = data['cnhExpiryYear'] ?? '';
      }
    } catch (e) {
      _showSnack('Erro ao carregar perfil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = _auth.currentUser;
    if (user == null) {
      _showSnack('Nenhum usuário autenticado.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      if (name.isNotEmpty && name != user.displayName) {
        await user.updateDisplayName(name);
      }

      if (email.isNotEmpty && email != user.email) {
        await user.updateEmail(email);
      }

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'cnhNumber': _cardNumberCtrl.text.trim(),
        'cnhExpiryYear': _expYearCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnack('Perfil atualizado com sucesso!');
    } catch (e) {
      _showSnack('Erro ao salvar perfil: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      // 👉 Redireciona PARA LOGIN limpando navegação
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showSnack('Erro ao sair: $e');
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;

    final user = _auth.currentUser;
    if (user == null) {
      _showSnack('Nenhum usuário autenticado.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar conta'),
        content: const Text(
          'Essa ação é permanente e apagará seus dados.\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showSnack('Erro ao apagar conta: $e\nTalvez seja necessário relogar.');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _changePhoto() {
    _showSnack('Alterar foto do perfil (em desenvolvimento)');
  }

  void _showSnack(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(txt),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _editNameDialog() async {
    final temp = TextEditingController(text: _nameCtrl.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: temp,
          decoration: const InputDecoration(hintText: 'Seu nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _nameCtrl.text = temp.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'PERFIL',
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  const SizedBox(height: 12),

                  // Avatar
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 62,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(
                            Icons.person,
                            size: 62,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: _changePhoto,
                              icon: const Icon(Icons.edit, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'USUÁRIO',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Nome exibido + ícone editar
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _nameCtrl.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: _editNameDialog,
                          child: const Icon(Icons.edit, size: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campos
                  _GreyField(
                    controller: _emailCtrl,
                    hint: 'Email',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Informe o e-mail';
                      if (!v.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _GreyField(
                          controller: _cardNumberCtrl,
                          hint: 'Número da CNH',
                          icon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GreyField(
                          controller: _expYearCtrl,
                          hint: 'Ano vencimento',
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botão SALVAR ALTERAÇÕES
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black87,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'SALVAR ALTERAÇÕES',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SAIR
                  SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: Colors.black54),
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: _logout,
                      child: const Text(
                        'SAIR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // APAGAR CONTA
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _isDeleting ? null : _deleteAccount,
                      child: _isDeleting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'APAGAR CONTA',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _GreyField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GreyField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
