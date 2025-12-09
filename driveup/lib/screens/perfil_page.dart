import 'package:flutter/material.dart';
import 'package:driveup/screens/sidemenu_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController(text: 'Power Guido');
  final _emailCtrl = TextEditingController(text: '');
  final _cardNumberCtrl = TextEditingController();
  final _expYearCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expYearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SideMenuPage()),
              );
          },
        ),
        centerTitle: true,
        title: const Text(
          'INÍCIO',
          style: TextStyle(color: Colors.black87, letterSpacing: 1),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const SizedBox(height: 8),

            // Avatar com botão de editar
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: const AssetImage('assets/avatar.png'),
                    // se não tiver asset, comente a linha acima e use apenas a cor
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        onPressed: _changePhoto,
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Editar foto',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // rótulo USUÁRIO
            const Center(
              child: Text(
                'USUÁRIO',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Nome com ícone de edição
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
                    borderRadius: BorderRadius.circular(12),
                    onTap: _editNameDialog,
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.edit, size: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Campos (cinza claro)
            _GreyField(
              controller: _emailCtrl,
              hint: 'Email@Exemple.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _GreyField(
                    controller: _cardNumberCtrl,
                    hint: 'Numero da CNH',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GreyField(
                    controller: _expYearCtrl,
                    hint: 'Ano de Vencimento',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botões
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellow,
                  foregroundColor: Colors.black87,
                  shape: const StadiumBorder(),
                  elevation: 1.5,
                ),
                onPressed: _logout,
                child: const Text(
                  'SAIR',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 1.5,
                ),
                onPressed: _deleteAccount,
                child: const Text(
                  'APAGAR CONTA',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .4),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== handlers =====
  void _changePhoto() {
    // TODO: abrir picker de imagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterar foto do perfil')),
    );
  }

  Future<void> _editNameDialog() async {
    final tmpCtrl = TextEditingController(text: _nameCtrl.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nome de usuário'),
        content: TextField(
          controller: tmpCtrl,
          decoration: const InputDecoration(hintText: 'Seu nome'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _nameCtrl.text = tmpCtrl.text.trim());
    }
  }

  void _logout() {
    // TODO: implemente seu fluxo de logout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Você saiu da conta.')),
    );
  }

  void _deleteAccount() {
    // TODO: implemente a exclusão de conta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitação de apagar conta enviada.')),
    );
  }
}

/// Campo cinza com ícone (igual ao mock)
class _GreyField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _GreyField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
    }
}
