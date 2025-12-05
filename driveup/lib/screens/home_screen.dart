import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veículos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'INÍCIO',
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          SizedBox(height: 8),
          _SectionTitle('RESUMO'),
          SummaryCard(), // <- agora é Stateful e mostra < MÊS >
          SizedBox(height: 4),
          _SectionTitle('VEÍCULOS'),
          VehicleCard(
            icon: Icons.directions_car_outlined,
            title: 'Jetta - Branco',
            model: 'Jetta',
            year: '2018',
            color: 'Branco',
            brand: 'Volkswagen',
          ),
          VehicleCard(
            icon: Icons.motorcycle_outlined,
            title: 'Titan 160 - Vermelho',
            model: 'Titan',
            year: '2022',
            color: 'Vermelho',
            brand: 'Honda',
          ),
          SizedBox(height: 92),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        backgroundColor: const Color(0xFFFFC107),
        elevation: 3,
        onPressed: () => _abrirModalAdicionar(context),
        child: const Icon(Icons.add, color: Colors.black87, size: 28),
      ),
    );
  }
}

void _abrirModalAdicionar(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    isScrollControlled: false,
    builder: (_) => const _AddOptionsModal(),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          letterSpacing: .5,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  // meses em PT-BR (maiúsculos para combinar com o mock)
  final List<String> _months = const [
    'JANEIRO',
    'FEVEREIRO',
    'MARÇO',
    'ABRIL',
    'MAIO',
    'JUNHO',
    'JULHO',
    'AGOSTO',
    'SETEMBRO',
    'OUTUBRO',
    'NOVEMBRO',
    'DEZEMBRO',
  ];
  int _monthIndex = 5; // 0=JAN ... 5=JUNHO

  void _prevMonth() {
    setState(() {
      _monthIndex = (_monthIndex - 1) % 12;
      if (_monthIndex < 0) _monthIndex += 12;
    });
  }

  void _nextMonth() {
    setState(() {
      _monthIndex = (_monthIndex + 1) % 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final segments = [
      DonutSegment(value: 0.16, color: Colors.blue.shade600),
      DonutSegment(value: 0.28, color: const Color(0xFFFFC107)),
      DonutSegment(value: 0.14, color: Colors.green.shade500),
      DonutSegment(value: 0.42, color: Colors.red.shade600),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
        child: Column(
          children: [
            // Gráfico + rótulo central
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DonutChart(segments: segments, thickness: 28, gap: 4),
                  // Centro do gráfico: < MÊS >
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _prevMonth,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            '<',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _months[_monthIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _nextMonth,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            '>',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Ações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SummaryAction(
                  color: Color(0xFFFFD600),
                  icon: Icons.local_gas_station_outlined,
                  label: 'Abastecimento',
                ),
                SummaryAction(
                  color: Color(0xFFFF5252),
                  icon: Icons.receipt_long_outlined,
                  label: 'Despesas',
                ),
                SummaryAction(
                  color: Color(0xFF40C4FF),
                  icon: Icons.build_outlined,
                  label: 'Serviço',
                ),
                SummaryAction(
                  color: Color(0xFF69F0AE),
                  icon: Icons.attach_money,
                  label: 'Receita',
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class SummaryAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  const SummaryAction({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 86,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

/// ====== MODAL ADICIONAR ======

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
                        // TODO: navegar para tela de Despesa
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
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
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

/// ====== VEÍCULOS ======

class VehicleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String model;
  final String year;
  final String color;
  final String brand;

  const VehicleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.model,
    required this.year,
    required this.color,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = Colors.black.withOpacity(.65);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 24,
                    runSpacing: 4,
                    children: [
                      _MiniInfo('Modelo', model, subtle),
                      _MiniInfo('Ano', year, subtle),
                      _MiniInfo('Cor', color, subtle),
                      _MiniInfo('Marca', brand, subtle),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: Colors.black54,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Editar',
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniInfo(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: TextStyle(fontSize: 12.5, color: color),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFFC107) : Colors.black54;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
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
      ),
    );
  }
}

/// ====== DONUT CHART (CustomPaint) ======

class DonutSegment {
  final double value; // 0..1 (proporção)
  final Color color;
  DonutSegment({required this.value, required this.color});
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double thickness;
  final double gap; // espaço entre arcos
  const DonutChart({
    super.key,
    required this.segments,
    this.thickness = 24,
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(segments, thickness, gap),
      size: Size.infinite,
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double thickness;
  final double gap;
  _DonutPainter(this.segments, this.thickness, this.gap);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - 8;

    var start = -math.pi / 2; // começa no topo
    for (final s in segments) {
      final sweep = s.value * 2 * math.pi - _gapAngle(radius);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.butt
        ..color = s.color;
      final arcRect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(arcRect, start, sweep.clamp(0, 2 * math.pi), false, paint);
      start += s.value * 2 * math.pi;
    }

    // “furo” interno
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - thickness / 2, innerPaint);
  }

  double _gapAngle(double r) {
    // converte o gap em ângulo aproximado
    return gap / r;
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.segments != segments ||
      oldDelegate.thickness != thickness ||
      oldDelegate.gap != gap;
}
