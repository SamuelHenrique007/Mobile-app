import 'package:flutter/material.dart';
import 'package:driveup/screens/sidemenu_page.dart';
import 'package:driveup/screens/perfil_page.dart';
import 'package:driveup/services/reminder_service.dart';
import 'package:driveup/screens/reminder_form_page.dart';

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
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SideMenuPage()));
          },
        ),
        centerTitle: true,
        title: const Text(
          'ALERTAS',
          style: TextStyle(color: Colors.black87, letterSpacing: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilPage()),
                );
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: ReminderService.instance.activeRemindersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro ao carregar lembretes:\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final reminders = snapshot.data ?? [];

          if (reminders.isEmpty) {
            // estado vazio simples (se quiser, pode reutilizar seu _EmptyState da outra tela)
            final muted = Colors.black.withOpacity(.35);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 70,
                          color: muted,
                        ),
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

          // agrupar por mês/ano
          final grouped = <String, List<Reminder>>{};
          for (final r in reminders) {
            final key = _monthYearLabel(r.dateTime);
            grouped.putIfAbsent(key, () => []).add(r);
          }

          final sections = grouped.entries.toList()
            ..sort(
              (a, b) =>
                  _parseMonthYear(b.key).compareTo(_parseMonthYear(a.key)),
            );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final section in sections) ...[
                _MonthSection(
                  title: section.key,
                  items: section.value
                      .map(
                        (r) => NotificationItem(
                          icon: r.done
                              ? Icons.check_circle_outline
                              : Icons.notifications_active_outlined,
                          title: r.title,
                          message: _buildMessageFromReminder(r),
                          onToggleDone: () async {
                            await ReminderService.instance.toggleDone(r);
                          },
                          onDelete: () async {
                            final ok =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Excluir lembrete'),
                                    content: Text(
                                      'Excluir o lembrete "${r.title}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Excluir',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (ok) {
                              await ReminderService.instance.deleteReminder(
                                r.id,
                              );
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 90),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReminderFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  static String _monthYearLabel(DateTime dt) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final m = months[dt.month - 1];
    return '$m - ${dt.year}';
  }

  static DateTime _parseMonthYear(String label) {
    // "Junho - 2025"
    final parts = label.split('-');
    if (parts.length != 2) return DateTime(2000);
    final year = int.tryParse(parts[1].trim()) ?? 2000;
    final name = parts[0].trim().toLowerCase();

    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    final monthIndex = months.indexOf(name);
    final month = monthIndex == -1 ? 1 : monthIndex + 1;
    return DateTime(year, month);
  }

  static String _buildMessageFromReminder(Reminder r) {
    final d = r.dateTime;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    var base = 'Agendado para $dateStr às $timeStr.';
    if (r.vehicleName != null && r.vehicleName!.trim().isNotEmpty) {
      base += ' Veículo: ${r.vehicleName}.';
    }
    return base;
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
  final VoidCallback? onToggleDone;
  final VoidCallback? onDelete;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onToggleDone,
    this.onDelete,
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
            if (onToggleDone != null || onDelete != null) ...[
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onToggleDone != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      onPressed: onToggleDone,
                      tooltip: 'Marcar / desmarcar',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.redAccent,
                      onPressed: onDelete,
                      tooltip: 'Excluir',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
