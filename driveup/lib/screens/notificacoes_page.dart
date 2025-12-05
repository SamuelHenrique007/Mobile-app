import 'package:flutter/material.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: const [
          _MonthSection(
            title: 'Junho - 2025',
            items: [
              NotificationItem(
                icon: Icons.directions_car_outlined,
                title: 'Vencimento de IPVA',
                message:
                    'O IPVA do seu veículo Jetta Branco vence em 3 meses. Aproveite para se programar e evitar imprevistos.',
              ),
              NotificationItem(
                icon: Icons.motorcycle_outlined,
                title: 'Abasteça seu veículo',
                message:
                    'Lembre-se de abastecer seu veículo para evitar contratempos! Não deixe para última hora.',
              ),
            ],
          ),
          _MonthSection(
            title: 'Maio - 2025',
            items: [
              NotificationItem(
                icon: Icons.notifications_active_outlined,
                title: 'Lembrete - Trocar amortecedor',
                message:
                    'Só passando pra te lembrar de algo importante. Não deixe para depois!',
              ),
              NotificationItem(
                icon: Icons.motorcycle_outlined,
                title: 'Abasteça seu veículo',
                message:
                    'Lembre-se de abastecer seu veículo para evitar contratempos! Não deixe para última hora.',
              ),
              NotificationItem(
                icon: Icons.local_police_outlined,
                title: 'Multa de Velocidade',
                message:
                    'O IPVA do seu veículo Jetta Branco vence em 3 meses. Aproveite para se programar e evitar imprevistos.',
              ),
              NotificationItem(
                icon: Icons.motorcycle_outlined,
                title: 'Abasteça seu veículo',
                message:
                    'Lembre-se de abastecer seu veículo para evitar contratempos! Não deixe para última hora.',
              ),
            ],
          ),
          SizedBox(height: 90),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}

// ---------- COMPONENTES ----------

class _MonthSection extends StatelessWidget {
  final String title;
  final List<NotificationItem> items;
  const _MonthSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          ...items.map((e) => e),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
