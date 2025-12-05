import 'package:flutter/material.dart';

class MensagemNotificacaoPage extends StatelessWidget {
  const MensagemNotificacaoPage({super.key});

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        children: [
          Card(
            elevation: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vencimento de IPVA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(.8),
                        height: 1.5,
                      ),
                      children: const [
                        TextSpan(
                          text:
                              'Gostaríamos de lembrá-lo(a) que o vencimento do IPVA do seu veículo ',
                        ),
                        TextSpan(
                          text: 'Jetta Branco ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'ocorrerá em 3 meses, no dia [data de vencimento]. Para evitar surpresas e garantir que você esteja preparado, recomendamos que comece a se programar para o pagamento antecipado.\n\n',
                        ),
                        TextSpan(
                          text:
                              'Abaixo, seguem algumas informações importantes sobre o IPVA:\n\n',
                        ),
                      ],
                    ),
                  ),
                  const _BulletList(
                    items: [
                      'Veículo: Jetta Branco',
                      'Ano de Fabricação: [ano do veículo]',
                      'Data de Vencimento: [data de vencimento]',
                      'Valor Estimado: [valor do IPVA]',
                      'Forma de Pagamento: [como e onde pagar]',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dicas para se programar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const _NumberedList(
                    items: [
                      'Consulte o valor exato do IPVA no portal oficial do Detran ou da Secretaria da Fazenda do seu estado.',
                      'Verifique se há descontos para pagamento à vista ou opções de parcelamento.',
                      'Fique atento aos prazos, pois o não pagamento dentro do prazo pode resultar em multas e juros.',
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Aproveite o tempo restante para planejar-se adequadamente e evitar qualquer imprevisto no momento do pagamento.',
                    style: TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 90),
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

/// ----- Bullets com • -----
class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 13.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// ----- Lista numerada -----
class _NumberedList extends StatelessWidget {
  final List<String> items;
  const _NumberedList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}. ',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  items[i],
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ),
            ],
          ),
        );
      }),
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
