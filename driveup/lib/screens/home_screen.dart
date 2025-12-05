import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:driveup/services/vehicle_service.dart'; // 👈 backend de veículos

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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

      // 👇 só o conteúdo, sem FAB nem bottom bar
      body: StreamBuilder<List<Vehicle>>(
        stream: VehicleService.instance.vehiclesStream(),
        builder: (context, snapshot) {
          final children = <Widget>[
            const SizedBox(height: 8),
            const _SectionTitle('RESUMO'),
            const SummaryCard(),
            const SizedBox(height: 4),
            const _SectionTitle('VEÍCULOS'),
          ];

          if (snapshot.connectionState == ConnectionState.waiting) {
            children.add(
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (snapshot.hasError) {
            children.add(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar veículos:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          } else {
            final veiculos = snapshot.data ?? [];

            if (veiculos.isEmpty) {
              children.add(
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Você ainda não cadastrou nenhum veículo.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            } else {
              for (final v in veiculos) {
                children.add(
                  VehicleCard(
                    icon: v.type == 'Moto'
                        ? Icons.motorcycle_outlined
                        : Icons.directions_car_outlined,
                    title: v.name,
                    model: v.model,
                    year: v.year,
                    color: v.color,
                    brand: v.brand,
                  ),
                );
              }
            }
          }

          children.add(const SizedBox(height: 32));

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: children,
          );
        },
      ),
    );
  }
}

/// ====== SECTION TITLE ======
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// ====== CARD DE RESUMO (gráfico) ======
class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
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
  int _monthIndex = 5;

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
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DonutChart(segments: segments, thickness: 28, gap: 4),
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

/// ====== CARD DE VEÍCULO (HOME) ======
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

/// ====== BOTTOM BAR ======
class _BottomBar extends StatelessWidget {
  const _BottomBar();

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
                selected: true,
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
                onTap: () {},
              ),
              _BottomItem(
                icon: Icons.directions_car_filled_outlined,
                label: 'Veículos',
                onTap: () {
                  Navigator.pushNamed(context, '/veiculos');
                },
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
        mouseCursor: SystemMouseCursors.click,
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== DONUT CHART ======
class DonutSegment {
  final double value;
  final Color color;
  DonutSegment({required this.value, required this.color});
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double thickness;
  final double gap;
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

    var start = -math.pi / 2;
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

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - thickness / 2, innerPaint);
  }

  double _gapAngle(double r) => gap / r;

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.segments != segments ||
      oldDelegate.thickness != thickness ||
      oldDelegate.gap != gap;
}
