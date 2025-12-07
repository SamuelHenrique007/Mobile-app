import 'package:flutter/material.dart';
import 'package:driveup/screens/sidemenu_page.dart';

// Se o DonutChart estiver em outro arquivo, importe.
// import 'donut_chart.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

enum ReportType { geral, abastecimento, despesa, receita }

class _RelatoriosPageState extends State<RelatoriosPage> {
  ReportType current = ReportType.geral;

  // ====== NOVO: controle de mês para o centro do gráfico ======
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
  int _monthIndex = 5; // 0=JAN ... 5=JUNHO (exemplo inicial)

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
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFC107);
    final cs = Theme.of(context).colorScheme;

    final data = _dataFor(current);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
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
          'INÍCIO', // mude para "RELATÓRIOS" se preferir
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          const SizedBox(height: 8),
          const _SectionTitle('TIPO DE RELATÓRIO'),
          _ReportChips(
            value: current,
            onChanged: (v) => setState(() => current = v),
          ),
          _StatsCard(
            children: [
              _stat('Total', 'R\$', data.totalStr),
              _stat('Por Dia', 'R\$', data.porDiaStr),
              _stat('Por KM', 'R\$', data.porKmStr),
            ],
          ),
          const _SectionTitle('DISTÂNCIA'),
          _StatsCard(
            children: [
              _stat('Total', 'KM', data.kmTotalStr),
              _stat('Média Diária', 'KM', data.kmMediaStr),
            ],
          ),
          const _SectionTitle('RESUMO'),
          Card(
            elevation: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Círculo', style: TextStyle(fontSize: 12)),
                            Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ====== ALTERADO: gráfico com mês e setas no centro ======
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        DonutChart(
                          segments: data.segments,
                          thickness: 26,
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

                  // ==========================================================
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _QuickAction(
                        color: Color(0xFFFFD600),
                        icon: Icons.local_gas_station_outlined,
                        label: 'Abastecimento',
                      ),
                      _QuickAction(
                        color: Color(0xFFFF5252),
                        icon: Icons.receipt_long_outlined,
                        label: 'Despesas',
                      ),
                      _QuickAction(
                        color: Color(0xFF40C4FF),
                        icon: Icons.build_outlined,
                        label: 'Serviço',
                      ),
                      _QuickAction(
                        color: Color(0xFF69F0AE),
                        icon: Icons.attach_money,
                        label: 'Receita',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 92),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias, // borda lisa
        backgroundColor: const Color(0xFFFFC107),
        elevation: 3,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black87, size: 28),
      ),
    );
  }

  // ----- helpers de UI -----

  Widget _stat(String title, String prefix, String value) {
    return _StatTile(title: title, prefix: prefix, value: value);
  }

  _ReportData _dataFor(ReportType t) {
    // dados mock para cada aba (ajuste com seus valores reais)
    switch (t) {
      case ReportType.geral:
        return _ReportData.general();
      case ReportType.abastecimento:
        return _ReportData.abastecimento();
      case ReportType.despesa:
        return _ReportData.despesa();
      case ReportType.receita:
        return _ReportData.receita();
    }
  }
}

// ---------- COMPONENTES ----------

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

class _ReportChips extends StatelessWidget {
  final ReportType value;
  final ValueChanged<ReportType> onChanged;
  const _ReportChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);
    final items = const [
      (ReportType.geral, 'Geral'),
      (ReportType.abastecimento, 'Abastecimento'),
      (ReportType.despesa, 'Despesa'),
      (ReportType.receita, 'Receita'),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (type, label) = items[i];
          final selected = value == type;
          return ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black87 : Colors.black87,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            selected: selected,
            selectedColor: yellow,
            backgroundColor: Colors.black.withOpacity(.06),
            side: BorderSide.none,
            onSelected: (_) => onChanged(type),
            showCheckmark: false,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final List<Widget> children;
  const _StatsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: children
              .map((w) => Expanded(child: Center(child: w)))
              .toList(),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String prefix;
  final String value;
  const _StatTile({
    required this.title,
    required this.prefix,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(.65)),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                text: '$prefix ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  const _QuickAction({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 86,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5),
          ),
        ),
      ],
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

// ---------- DADOS MOCK POR ABA ----------

class _ReportData {
  final String totalStr;
  final String porDiaStr;
  final String porKmStr;
  final String kmTotalStr;
  final String kmMediaStr;
  final List<DonutSegment> segments;

  _ReportData({
    required this.totalStr,
    required this.porDiaStr,
    required this.porKmStr,
    required this.kmTotalStr,
    required this.kmMediaStr,
    required this.segments,
  });

  factory _ReportData.general() => _ReportData(
    totalStr: '350,00',
    porDiaStr: '45,00',
    porKmStr: '12,09',
    kmTotalStr: '150',
    kmMediaStr: '23',
    segments: [
      DonutSegment(value: .18, color: Colors.blue.shade600),
      DonutSegment(value: .38, color: const Color(0xFFFFC107)),
      DonutSegment(value: .16, color: Colors.green.shade500),
      DonutSegment(value: .28, color: Colors.red.shade600),
    ],
  );

  factory _ReportData.abastecimento() => _ReportData(
    totalStr: '220,00',
    porDiaStr: '28,00',
    porKmStr: '7,10',
    kmTotalStr: '110',
    kmMediaStr: '18',
    segments: [
      DonutSegment(value: .30, color: Colors.blue.shade600),
      DonutSegment(value: .40, color: const Color(0xFFFFC107)),
      DonutSegment(value: .10, color: Colors.green.shade500),
      DonutSegment(value: .20, color: Colors.red.shade600),
    ],
  );

  factory _ReportData.despesa() => _ReportData(
    totalStr: '510,00',
    porDiaStr: '65,00',
    porKmStr: '16,40',
    kmTotalStr: '180',
    kmMediaStr: '27',
    segments: [
      DonutSegment(value: .14, color: Colors.blue.shade600),
      DonutSegment(value: .26, color: const Color(0xFFFFC107)),
      DonutSegment(value: .12, color: Colors.green.shade500),
      DonutSegment(value: .48, color: Colors.red.shade600),
    ],
  );

  factory _ReportData.receita() => _ReportData(
    totalStr: '870,00',
    porDiaStr: '115,00',
    porKmStr: '22,00',
    kmTotalStr: '240',
    kmMediaStr: '34',
    segments: [
      DonutSegment(value: .10, color: Colors.blue.shade600),
      DonutSegment(value: .22, color: const Color(0xFFFFC107)),
      DonutSegment(value: .28, color: Colors.green.shade500),
      DonutSegment(value: .40, color: Colors.red.shade600),
    ],
  );
}

/// Simple model for a donut segment.
class DonutSegment {
  final double value; // fraction of the whole (sum should typically be ~1.0)
  final Color color;

  const DonutSegment({required this.value, required this.color});
}

/// A lightweight DonutChart implementation using CustomPainter.
/// It supports thickness and a small gap between segments.
class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double thickness;
  final double gap; // degrees of gap between segments

  const DonutChart({required this.segments, this.thickness = 16, this.gap = 2});

  @override
  Widget build(BuildContext context) {
    // Parent provides a fixed height (220); make the chart square using that height.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : (constraints.maxWidth.isFinite && constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : 200);
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _DonutPainter(
                segments: segments,
                thickness: thickness,
                gap: gap,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double thickness;
  final double gap; // degrees

  _DonutPainter({
    required this.segments,
    required this.thickness,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final Offset center = Offset(cx, cy);
    final double radius = (size.shortestSide - thickness) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final double tau = 2 * 3.141592653589793;
    final double gapRad = gap * 3.141592653589793 / 180.0;

    double startAngle = -3.141592653589793 / 2; // start at top

    for (final seg in segments) {
      double sweep = seg.value * tau;
      // subtract a small gap so segments don't touch
      final double effectiveSweep = (sweep - gapRad).clamp(0.0, tau);
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.butt;
      if (effectiveSweep > 0) {
        canvas.drawArc(rect, startAngle, effectiveSweep, false, paint);
      }
      startAngle += sweep;
    }

    // “furo” interno para centro limpo
    final paintFill = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - thickness / 2, paintFill);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.segments != segments ||
        old.thickness != thickness ||
        old.gap != gap;
  }
}
