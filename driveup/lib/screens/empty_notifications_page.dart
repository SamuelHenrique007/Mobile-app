import 'package:flutter/material.dart';

class EmptyNotificationsPage extends StatelessWidget {
  const EmptyNotificationsPage({super.key});

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
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'INICIO',
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
      body: const _EmptyState(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomBarAlertsSelected(),
    );
  }
}

/// ----- Estado vazio centralizado -----
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final muted = Colors.black.withOpacity(.35);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sininho com um "x" pequeno por cima (Stack)
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_none_outlined, size: 70, color: muted),
                Positioned(
                  right: 22,
                  top: 24,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sem Notificações',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Não existem notificações neste\nmomento. Volte mais tarde.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black.withOpacity(.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// ----- Bottom bar com “Alertas” selecionado -----
class _BottomBarAlertsSelected extends StatelessWidget {
  const _BottomBarAlertsSelected();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 76,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                icon: Icons.home_outlined,
                label: 'Início',
                onTap: () {},
              ),
              _BottomItem(
                icon: Icons.receipt_long_outlined,
                label: 'Registros',
                onTap: () {},
              ),
              const SizedBox(width: 56),
              _BottomItem(
                icon: Icons.notifications_none,
                label: 'Alertas',
                selected: true, // amarelo
                onTap: () {},
              ),
              _BottomItem(
                icon: Icons.directions_car_filled_outlined,
                label: 'Veículos',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFFC107) : Colors.black54;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
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
      ),
    );
  }
}
