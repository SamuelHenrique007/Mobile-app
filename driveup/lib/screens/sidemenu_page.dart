import 'package:flutter/material.dart';

class SideMenuPage extends StatelessWidget {
  const SideMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: .5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // Header: avatar + nome/email
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.amber,
                // se tiver sua imagem: backgroundImage: AssetImage('assets/avatar.png'),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Power Guido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        )),
                    SizedBox(height: 2),
                    Text('exemple@email.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Itens principais
          _MenuTile(
            icon: Icons.directions_car_outlined,
            label: 'Meus veículos',
            onTap: () {
              // TODO: navegue para a tela de veículos
            },
          ),
          const Divider(height: 24),
          _MenuTile(
            icon: Icons.local_gas_station_outlined,
            label: 'Combustíveis',
            onTap: () {
              // TODO: cadastros de combustíveis
            },
          ),
          _MenuTile(
            icon: Icons.local_gas_station, // pode repetir para "postos"
            label: 'Postos de Combustíveis',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.location_on_outlined,
            label: 'Locais',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.build_outlined,
            label: 'Tipo de serviço',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            label: 'Tipo de Despesa',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            label: 'Tipo de receita',
            onTap: () {},
          ),

          const Divider(height: 28),

          // Itens desabilitados (acinzentados)
          const _MenuTile(
            icon: Icons.settings_outlined,
            label: 'Configuração',
            enabled: false,
          ),
          const _MenuTile(
            icon: Icons.info_outline,
            label: 'Sobre',
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      color: enabled ? Colors.black87 : Colors.black38,
      fontWeight: FontWeight.w500,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: enabled ? Colors.black87 : Colors.black38),
      title: Text(label, style: textStyle),
      enabled: enabled,
      onTap: enabled ? onTap : null,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
