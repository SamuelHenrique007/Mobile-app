import 'package:flutter/material.dart';
import 'package:driveup/screens/sidemenu_page.dart';
import 'package:driveup/services/summary_service.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

enum ReportType { geral, abastecimento, despesa }

class _RelatoriosPageState extends State<RelatoriosPage> {
  ReportType current = ReportType.geral;

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
  int _monthIndex = DateTime.now().month - 1;
  int _year = DateTime.now().year;

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
    const yellow = Color(0xFFFFC107);

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
          'RELATÓRIOS',
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
      body: StreamBuilder<MonthlySummary>(
        stream: SummaryService.instance.summaryForMonth(
          year: _year,
          month: _monthIndex + 1,
        ),
        builder: (context, snapshot) {
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData;

          final summary = snapshot.data ??
              MonthlySummary(
                fuelTotal: 0,
                expenseTotal: 0,
              );

          // 🔹 Sempre usar o GERAL para o gráfico
          final fuel = summary.fuelTotal;
          final expense = summary.expenseTotal;

          List<DonutSegment> donutSegments;
          if (fuel <= 0 && expense <= 0) {
            donutSegments = const [
              DonutSegment(value: 0.5, color: Color(0xFFFFC107)),
              DonutSegment(value: 0.5, color: Colors.red),
            ];
          } else {
            final total = (fuel + expense).clamp(0.0001, double.infinity);
            final fuelFrac = (fuel / total).clamp(0.0, 1.0);
            final expenseFrac = (expense / total).clamp(0.0, 1.0);
            donutSegments = [
              DonutSegment(
                value: fuelFrac,
                color: const Color(0xFFFFC107),
              ),
              DonutSegment(
                value: expenseFrac,
                color: Colors.red.shade600,
              ),
            ];
          }

          // 🔹 Números mudam conforme o filtro (Geral / Abastecimento / Despesa)
          final data = _buildReportData(summary, current);

          return ListView(
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
                      SizedBox(
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ⭐ AQUI o gráfico SEMPRE usa o geral (donutSegments)
                            DonutChart(
                              segments: donutSegments,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 92),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        backgroundColor: const Color(0xFFFFC107),
        elevation: 3,
        onPressed: () {
          // TODO: abrir tela para novo registro
        },
        child: const Icon(Icons.add, color: Colors.black87, size: 28),
      ),
    );
  }

  Widget _stat(String title, String prefix, String value) {
    return _StatTile(title: title, prefix: prefix, value: value);
  }

  _ReportData _buildReportData(MonthlySummary summary, ReportType t) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_year, _monthIndex + 1).toDouble();

    final fuel = summary.fuelTotal;
    final expense = summary.expenseTotal;

    double totalMoney;

    // 🔹 Só os valores mudam conforme o filtro
    switch (t) {
      case ReportType.geral:
        totalMoney = fuel + expense;
        break;
      case ReportType.abastecimento:
        totalMoney = fuel;
        break;
      case ReportType.despesa:
        totalMoney = expense;
        break;
    }

    final porDia = daysInMonth > 0 ? totalMoney / daysInMonth : 0.0;

    // por enquanto, km são mocks / 0
    final kmTotal = 0.0;
    final kmMedia = 0.0;

    return _ReportData(
      totalStr: _fmtMoney(totalMoney),
      porDiaStr: _fmtMoney(porDia),
      porKmStr: _fmtMoney(0),
      kmTotalStr: _fmtInt(kmTotal),
      kmMediaStr: _fmtInt(kmMedia),
    );
  }

  String _fmtMoney(double v) =>
      v.toStringAsFixed(2).replaceAll('.', ',');

  String _fmtInt(double v) => v.toStringAsFixed(0);
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
                color: Colors.black87,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            selected: selected,
            selectedColor: yellow,
            backgroundColor: Colors.black.withOpacity(.06),
            side: BorderSide.none,
            onSelected: (_) => onChanged(type),
            showCheckmark: false,
            visualDensity:
                const VisualDensity(horizontal: -2, vertical: -2),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(.65),
          ),
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

// ---------- DADOS DO GRÁFICO / TIPOS ----------

class _ReportData {
  final String totalStr;
  final String porDiaStr;
  final String porKmStr;
  final String kmTotalStr;
  final String kmMediaStr;

  _ReportData({
    required this.totalStr,
    required this.porDiaStr,
    required this.porKmStr,
    required this.kmTotalStr,
    required this.kmMediaStr,
  });
}

class DonutSegment {
  final double value;
  final Color color;

  const DonutSegment({required this.value, required this.color});
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double thickness;
  final double gap;

  const DonutChart({
    super.key,
    required this.segments,
    this.thickness = 16,
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
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
  final double gap;

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
    const double tau = 2 * 3.141592653589793;
    final double gapRad = gap * 3.141592653589793 / 180.0;

    double startAngle = -3.141592653589793 / 2;

    for (final seg in segments) {
      double sweep = seg.value * tau;
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
