import '../../../core/app_export.dart';

class ReportSummaryStatsWidget extends StatelessWidget {
  final int recordCount;
  final DateTimeRange dateRange;
  final String riskFilter;
  final String employeeFilter;
  final String Function(DateTime) formatDate;

  const ReportSummaryStatsWidget({
    super.key,
    required this.recordCount,
    required this.dateRange,
    required this.riskFilter,
    required this.employeeFilter,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final proceedCount = (recordCount * 0.78).round();
    final noGoCount = recordCount - proceedCount;
    final highRiskCount = (noGoCount * 0.6).round();
    final days = dateRange.end.difference(dateRange.start).inDays + 1;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Përmbledhja e Raportit',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${formatDate(dateRange.start)} — ${formatDate(dateRange.end)}  ($days ditë)',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCell(
                  'Gjithsej',
                  recordCount.toString(),
                  'assignment',
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCell(
                  'Proceed',
                  proceedCount.toString(),
                  'check_circle',
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCell(
                  'No Proceed',
                  noGoCount.toString(),
                  'cancel',
                  AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCell(
                  'Rrezik i lartë',
                  highRiskCount.toString(),
                  'warning',
                  AppTheme.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCell(
                  'Mesatare/ditë',
                  (recordCount / days.clamp(1, 999)).toStringAsFixed(1),
                  'speed',
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCell(
                  '% Proceed',
                  '${(proceedCount / recordCount.clamp(1, 999) * 100).toStringAsFixed(0)}%',
                  'verified',
                  AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10,
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
