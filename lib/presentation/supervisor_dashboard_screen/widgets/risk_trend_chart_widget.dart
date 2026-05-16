import 'package:fl_chart/fl_chart.dart';

import '../../../core/app_export.dart';

class RiskTrendChartWidget extends StatefulWidget {
  const RiskTrendChartWidget({super.key});

  @override
  State<RiskTrendChartWidget> createState() => _RiskTrendChartWidgetState();
}

class _RiskTrendChartWidgetState extends State<RiskTrendChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _barAnim;

  // Domain data: daily submissions by risk level for past 7 days
  // [day: {proceed, doNotProceed}]
  final List<Map<String, dynamic>> _chartData = [
    {'day': 'E Hë', 'proceed': 8, 'noGo': 2},
    {'day': 'E Ma', 'proceed': 11, 'noGo': 1},
    {'day': 'E Më', 'proceed': 6, 'noGo': 4},
    {'day': 'E En', 'proceed': 9, 'noGo': 2},
    {'day': 'E Pr', 'proceed': 13, 'noGo': 1},
    {'day': 'E Sh', 'proceed': 4, 'noGo': 3},
    {'day': 'E Di', 'proceed': 7, 'noGo': 5},
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _barAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'bar_chart',
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vlerësimet sipas Ditës',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
              ),
              Text(
                '7 ditët e fundit',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(AppTheme.success, 'Proceed'),
              const SizedBox(width: 16),
              _legendDot(AppTheme.errorColor, 'No Proceed'),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _barAnim,
            builder: (context, _) {
              return SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 16,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: AppTheme.surfaceVariantDark,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = _chartData[groupIndex]['day'];
                          final label = rodIndex == 0
                              ? 'Proceed'
                              : 'No Proceed';
                          return BarTooltipItem(
                            '$day\n$label: ${rod.toY.toInt()}',
                            GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              color: AppTheme.onSurfaceText,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 4,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 10,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= _chartData.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _chartData[idx]['day'],
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 10,
                                  color: AppTheme.mutedText,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.outlineDark,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _chartData.asMap().entries.map((e) {
                      final idx = e.key;
                      final data = e.value;
                      final proceedH =
                          (data['proceed'] as int).toDouble() * _barAnim.value;
                      final noGoH =
                          (data['noGo'] as int).toDouble() * _barAnim.value;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: proceedH,
                            color: AppTheme.success,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: noGoH,
                            color: AppTheme.errorColor,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                        barsSpace: 3,
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            color: AppTheme.mutedText,
          ),
        ),
      ],
    );
  }
}
