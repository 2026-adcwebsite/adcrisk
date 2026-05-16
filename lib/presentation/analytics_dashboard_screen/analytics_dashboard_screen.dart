import 'package:fl_chart/fl_chart.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _isLoading = true;
  String _currentUserRole = 'supervisor';
  String _currentUserName = '';

  // Metrics
  int _totalSubmissions = 0;
  double _avgCompletionMinutes = 0;
  double _highRiskPercent = 0;
  List<Map<String, dynamic>> _teamPerformance = [];
  List<FlSpot> _trendSpots = [];
  List<String> _trendLabels = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SupabaseService.instance.getCurrentUserProfile();

      if (!mounted) return;

      final role = profile?['role'] ?? 'worker';
      final name = profile?['full_name'] ?? '';

      // Workers see only their own submissions; managers/admins see all
      final isManagerOrAdmin =
          role == 'manager' || role == 'admin' || role == 'supervisor';
      final submissions = isManagerOrAdmin
          ? await SupabaseService.instance.getAllSubmissions()
          : await SupabaseService.instance.getMySubmissions();

      // ── Submission trend (last 7 days) ──────────────────────────────────
      final now = DateTime.now();
      final Map<String, int> dayCount = {};
      final List<String> labels = [];
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        dayCount[key] = 0;
        labels.add(
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}',
        );
      }

      for (final sub in submissions) {
        final raw = sub['submitted_at'] ?? '';
        try {
          final dt = DateTime.parse(raw).toLocal();
          final key =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          if (dayCount.containsKey(key)) {
            dayCount[key] = (dayCount[key] ?? 0) + 1;
          }
        } catch (_) {}
      }

      final spots = <FlSpot>[];
      int idx = 0;
      for (final key in dayCount.keys) {
        spots.add(FlSpot(idx.toDouble(), (dayCount[key] ?? 0).toDouble()));
        idx++;
      }

      // ── Average completion time (minutes between created_at & submitted_at) ─
      double totalMinutes = 0;
      int countWithTime = 0;
      for (final sub in submissions) {
        final submittedRaw = sub['submitted_at'] ?? '';
        final createdRaw = sub['created_at'] ?? '';
        if (submittedRaw.isNotEmpty && createdRaw.isNotEmpty) {
          try {
            final submitted = DateTime.parse(submittedRaw);
            final created = DateTime.parse(createdRaw);
            final diff = submitted.difference(created).inSeconds.abs();
            if (diff > 0 && diff < 86400) {
              // ignore outliers > 24h
              totalMinutes += diff / 60.0;
              countWithTime++;
            }
          } catch (_) {}
        }
      }
      final avgMin = countWithTime > 0 ? totalMinutes / countWithTime : 0.0;

      // ── High-risk percentage ─────────────────────────────────────────────
      int highRiskCount = 0;
      for (final sub in submissions) {
        final activities = sub['activities'];
        if (activities is List) {
          final hasHighRisk = activities.any((a) {
            if (a is Map) {
              final risk = (a['risk_level'] ?? '').toString().toLowerCase();
              return risk == 'high' || risk == 'lartë' || risk == 'i lartë';
            }
            return false;
          });
          if (hasHighRisk) highRiskCount++;
        }
        // Also check suspension_reason as proxy for high risk
        final suspension = sub['suspension_reason'] ?? '';
        if (suspension.toString().isNotEmpty &&
            suspension.toString() != 'null') {
          highRiskCount++;
        }
      }
      final highRiskPct = submissions.isNotEmpty
          ? (highRiskCount / submissions.length) * 100
          : 0.0;

      // ── Team performance (only for manager/admin) ────────────────────────
      List<Map<String, dynamic>> teamList = [];
      if (isManagerOrAdmin) {
        final Map<String, int> workerCount = {};
        for (final sub in submissions) {
          final workerName = (sub['submitter_name'] ?? 'I panjohur').toString();
          workerCount[workerName] = (workerCount[workerName] ?? 0) + 1;
        }
        teamList =
            workerCount.entries
                .map((e) => {'name': e.key, 'count': e.value})
                .toList()
              ..sort(
                (a, b) => (b['count'] as int).compareTo(a['count'] as int),
              );
      }

      setState(() {
        _currentUserRole = role;
        _currentUserName = name;
        _totalSubmissions = submissions.length;
        _avgCompletionMinutes = avgMin;
        _highRiskPercent = highRiskPct.clamp(0, 100);
        _trendSpots = spots;
        _trendLabels = labels;
        _teamPerformance = teamList.take(8).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      child: _buildBody(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(
        currentIndex: 4,
        onDestinationSelected: (i) => _handleNavigation(context, i),
        isSupervisor: true,
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      AppRoutes.riskAssessmentFormScreen,
      AppRoutes.submissionHistoryScreen,
      AppRoutes.notificationsScreen,
      AppRoutes.supervisorDashboardScreen,
      AppRoutes.analyticsDashboardScreen,
    ];
    if (index < routes.length) {
      Navigator.pushNamedAndRemoveUntil(context, routes[index], (r) => false);
    }
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.outlineDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analitika',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                Text(
                  _currentUserName,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.mutedText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final isManagerOrAdmin =
        _currentUserRole == 'manager' ||
        _currentUserRole == 'admin' ||
        _currentUserRole == 'supervisor';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (!isManagerOrAdmin)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withAlpha(80)),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Po shfaqen vetëm aplikimet tuaja personale',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _buildKpiGrid(),
        const SizedBox(height: 20),
        _buildTrendChart(),
        if (isManagerOrAdmin) ...[
          const SizedBox(height: 20),
          _buildTeamPerformance(),
        ],
      ],
    );
  }

  // ── KPI Grid ──────────────────────────────────────────────────────────────
  Widget _buildKpiGrid() {
    final avgStr = _avgCompletionMinutes < 1
        ? '< 1 min'
        : _avgCompletionMinutes < 60
        ? '${_avgCompletionMinutes.toStringAsFixed(1)} min'
        : '${(_avgCompletionMinutes / 60).toStringAsFixed(1)} orë';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Treguesit Kryesorë',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Totali Formave',
                value: '$_totalSubmissions',
                iconName: 'assignment',
                accentColor: AppTheme.primary,
                bgColor: AppTheme.primaryMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Koha Mesatare',
                value: avgStr,
                iconName: 'timer',
                accentColor: const Color(0xFF3B82F6),
                bgColor: const Color(0x403B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                label: 'Rrezik i Lartë',
                value: '${_highRiskPercent.toStringAsFixed(1)}%',
                iconName: 'warning_amber',
                accentColor: AppTheme.errorColor,
                bgColor: const Color(0x40EF4444),
                isAlert: _highRiskPercent > 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTile(
                label: 'Anëtarë Aktivë',
                value: '${_teamPerformance.length}',
                iconName: 'group',
                accentColor: AppTheme.success,
                bgColor: const Color(0x4022C55E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Trend Chart ───────────────────────────────────────────────────────────
  Widget _buildTrendChart() {
    final maxY = _trendSpots.isEmpty
        ? 5.0
        : (_trendSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primaryMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'show_chart',
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Trendet e Dorëzimeve (7 ditë)',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _trendSpots.isEmpty
                ? Center(
                    child: Text(
                      'Nuk ka të dhëna',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) =>
                            FlLine(color: AppTheme.outlineDark, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: GoogleFonts.ibmPlexSans(
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
                            reservedSize: 26,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= _trendLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _trendLabels[i],
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 9,
                                    color: AppTheme.mutedText,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _trendSpots,
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (s, _, __, ___) =>
                                FlDotCirclePainter(
                                  radius: 3.5,
                                  color: AppTheme.primary,
                                  strokeWidth: 1.5,
                                  strokeColor: Colors.white,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primary.withAlpha(60),
                                AppTheme.primary.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Team Performance ──────────────────────────────────────────────────────
  Widget _buildTeamPerformance() {
    final maxCount = _teamPerformance.isEmpty
        ? 1
        : (_teamPerformance.first['count'] as int);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0x4022C55E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'leaderboard',
                    color: AppTheme.success,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Performanca e Ekipit',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_teamPerformance.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Nuk ka të dhëna',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_teamPerformance.length, (i) {
              final item = _teamPerformance[i];
              final workerName = item['name'] as String;
              final count = item['count'] as int;
              final ratio = maxCount > 0 ? count / maxCount : 0.0;
              final isTop = i == 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isTop
                                ? AppTheme.warning.withAlpha(40)
                                : AppTheme.surfaceVariantDark,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isTop
                                    ? AppTheme.warning
                                    : AppTheme.mutedText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            workerName,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$count forma',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: AppTheme.outlineDark,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isTop ? AppTheme.warning : AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Internal KPI Tile ─────────────────────────────────────────────────────
class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String iconName;
  final Color accentColor;
  final Color bgColor;
  final bool isAlert;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.iconName,
    required this.accentColor,
    required this.bgColor,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAlert ? accentColor.withAlpha(100) : AppTheme.outlineDark,
          width: isAlert ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: accentColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isAlert ? accentColor : AppTheme.onSurfaceText,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
