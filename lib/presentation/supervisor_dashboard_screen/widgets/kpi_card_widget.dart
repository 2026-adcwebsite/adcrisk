import '../../../core/app_export.dart';

class KpiCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final String iconName;
  final bool isAlert;
  final bool isWarning;
  final String trend; // 'up' | 'down' | 'neutral'

  const KpiCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.iconName,
    this.isAlert = false,
    this.isWarning = false,
    this.trend = 'neutral',
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    Color bgColor;
    if (isAlert) {
      accentColor = AppTheme.errorColor;
      bgColor = const Color(0xFF2D0A0A);
    } else if (isWarning) {
      accentColor = AppTheme.warning;
      bgColor = AppTheme.warningContainer;
    } else {
      accentColor = AppTheme.primary;
      bgColor = AppTheme.primaryMuted;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isAlert || isWarning)
              ? accentColor.withAlpha(80)
              : AppTheme.outlineDark,
          width: (isAlert || isWarning) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: accentColor,
                    size: 17,
                  ),
                ),
              ),
              if (trend != 'neutral')
                CustomIconWidget(
                  iconName: trend == 'up' ? 'trending_up' : 'trending_down',
                  color: trend == 'up'
                      ? (isAlert ? AppTheme.errorColor : AppTheme.success)
                      : AppTheme.success,
                  size: 16,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isAlert
                      ? AppTheme.errorColor
                      : isWarning
                      ? AppTheme.warning
                      : AppTheme.onSurfaceText,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  color: AppTheme.mutedText.withAlpha(160),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
