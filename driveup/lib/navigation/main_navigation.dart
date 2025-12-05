import 'package:flutter/material.dart';

// importa suas telas principais
import 'package:driveup/screens/home_screen.dart';
import 'package:driveup/screens/veiculos_page.dart';
import 'package:driveup/screens/relatorios_page.dart';
import 'package:driveup/screens/notificacoes_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  // Telas controladas pela bottom bar
  final screens = const [
    HomePage(), // 0 - Início
    RelatoriosPage(), // 1 - Registros (ou Relatórios)
    SizedBox(), // 2 - espaço do botão +
    NotificacoesPage(), // 3 - Alertas
    VeiculosPage(), // 4 - Veículos
  ];

  void _onMenuTap(int i) {
    if (i == 2) return; // posição do botão + (não faz nada aqui)
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      extendBody: true,

      // corpo troca entre as telas
      body: screens[_index],

      // FAB central (botão +)
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black87),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.6),
            builder: (_) => const _AddOptionsModal(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom bar global
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 76,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Início',
                selected: _index == 0,
                onTap: () => _onMenuTap(0),
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Registros',
                selected: _index == 1,
                onTap: () => _onMenuTap(1),
              ),
              const SizedBox(width: 56), // espaço do FAB
              _NavItem(
                icon: Icons.notifications_none,
                label: 'Alertas',
                selected: _index == 3,
                onTap: () => _onMenuTap(3),
              ),
              _NavItem(
                icon: Icons.directions_car_filled_outlined,
                label: 'Veículos',
                selected: _index == 4,
                onTap: () => _onMenuTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFFC107) : Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ====== MODAL DO BOTÃO + (igual ao conceito da sua UI) ======

class _AddOptionsModal extends StatelessWidget {
  const _AddOptionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ADICIONAR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AddOptionTile(
                      icon: Icons.local_gas_station,
                      label: 'Abastecimento',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: navegar para tela de Abastecimento
                      },
                    ),
                    const Divider(height: 1),
                    _AddOptionTile(
                      icon: Icons.receipt_long,
                      label: 'Despesa',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    _AddOptionTile(
                      icon: Icons.attach_money,
                      label: 'Receita',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    _AddOptionTile(
                      icon: Icons.build,
                      label: 'Serviço',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    _AddOptionTile(
                      icon: Icons.alt_route,
                      label: 'Percurso',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    _AddOptionTile(
                      icon: Icons.notifications_active_outlined,
                      label: 'Lembrete',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
