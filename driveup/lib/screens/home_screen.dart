
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
        // ❌ Removido o cardTheme para evitar erro no Flutter 3.35
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
        title: const Text('INICIO',
            style: TextStyle(
              color: Colors.black87,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            )),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          SizedBox(height: 8),
          _SectionTitle('RESUMO'),
          SummaryCard(),
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
        backgroundColor: yellow,
        elevation: 3,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black87, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomBar(),
    );
  }
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

/// ====== RESUMO ======

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Cores dos segmentos (azul, amarelo, verde, vermelho) como na imagem
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
                  DonutChart(
                    segments: segments,
                    thickness: 28,
                    gap: 4,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('<', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 32),
                          const Text(
                          'JUNHO',
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: .8,
                              fontWeight: FontWeight.w600),
                      ),
                          SizedBox(width: 32),
                          Text('>', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
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
  const SummaryAction(
      {super.key, required this.color, required this.icon, required this.label});

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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
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

/// Pequena extensão para escrever "Campo: valor"
extension on Column {
  Column apply() => this;
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
                onTap: () {
                  // TODO: navegar para Início
                },
              ),
              _BottomItem(
                icon: Icons.receipt_long_outlined,
                label: 'Registros',
                onTap: () {
                  // TODO: navegar para Registros
                },
              ),
              const SizedBox(width: 56), // espaço do FAB
              _BottomItem(
                icon: Icons.notifications_none,
                label: 'Alertas',
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black87 : Colors.black54;

    return Material( // garante ink ripple no BottomAppBar (que já é Material)
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click, // cursor de mão no web/desktop
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
