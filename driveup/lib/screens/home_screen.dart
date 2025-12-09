import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:driveup/services/vehicle_service.dart';
import 'package:driveup/services/summary_service.dart';
import 'package:driveup/screens/sidemenu_page.dart';
import 'package:driveup/screens/vehicle_history_page.dart';

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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SideMenuPage()),
            );
          },
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

      // 👇 só o conteúdo, sem FAB/bottom bar (quem cuida é o MainNavigation)
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleHistoryPage(vehicle: v),
                        ),
                      );
                    },
                  ),
                );
              }
            }
          }

          // espaço extra por causa da bottom bar global + FAB
          children.add(const SizedBox(height: 120));

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

  int _monthIndex = DateTime.now().month - 1; // mês atual (0–11)
  int get _year => DateTime.now().year;

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
    final month = _monthIndex + 1; // 1–12

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
        child: StreamBuilder<MonthlySummary>(
          // 🔴 Se no seu service o método se chama monthSummary, troque aqui:
          // stream: SummaryService.instance.monthSummary(year: _year, month: month),
          stream: SummaryService.instance.summaryForMonth(
            year: _year,
            month: month,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final summary = snapshot.data ??
                MonthlySummary(
                  fuelTotal: 0,
                  expenseTotal: 0,
                );

            final fuel = summary.fuelTotal;
            final expense = summary.expenseTotal;

            List<DonutSegment> segments;

            if (fuel <= 0 && expense <= 0) {
              // nada no mês → donut "neutro"
              segments = [
                DonutSegment(
                  value: 0.5,
                  color: const Color(0xFFFFC107), // abastecimento
                ),
                DonutSegment(
                  value: 0.5,
                  color: Colors.red.shade600,
                ),
              ];
            } else {
              final total = (fuel + expense).clamp(0.0001, double.infinity);
              final fuelFrac = (fuel / total).clamp(0.0, 1.0);
              final expenseFrac = (expense / total).clamp(0.0, 1.0);

              segments = [
                DonutSegment(
                  value: fuelFrac,
                  color: const Color(0xFFFFC107), // abastecimento
                ),
                DonutSegment(
                  value: expenseFrac,
                  color: Colors.red.shade600, // despesas
                ),
              ];
            }

            return Column(
              children: [
                SizedBox(
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      DonutChart(
                        segments: segments,
                        thickness: 28,
                        gap: 4,
                      ),
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
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          },
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
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.model,
    required this.year,
    required this.color,
    required this.brand,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = Colors.black.withOpacity(.65);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
