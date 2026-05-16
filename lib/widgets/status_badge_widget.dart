import '../core/app_export.dart';

enum RiskStatus {
  proceed,
  doNotProceed,
  pending,
  synced,
  pendingSync,
  highRisk,
}

class StatusBadgeWidget extends StatelessWidget {
  final RiskStatus status;
  final bool compact;

  const StatusBadgeWidget({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: config.icon,
            color: config.textColor,
            size: compact ? 11 : 13,
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig(RiskStatus status) {
    switch (status) {
      case RiskStatus.proceed:
        return _BadgeConfig(
          label: 'PROCEED',
          icon: 'check_circle',
          textColor: AppTheme.success,
          bgColor: AppTheme.successContainer,
          borderColor: AppTheme.success.withAlpha(80),
        );
      case RiskStatus.doNotProceed:
        return _BadgeConfig(
          label: 'NO PROCEED',
          icon: 'cancel',
          textColor: AppTheme.errorColor,
          bgColor: const Color(0xFF2D0A0A),
          borderColor: AppTheme.errorColor.withAlpha(80),
        );
      case RiskStatus.pending:
        return _BadgeConfig(
          label: 'PENDING',
          icon: 'pending',
          textColor: AppTheme.warning,
          bgColor: AppTheme.warningContainer,
          borderColor: AppTheme.warning.withAlpha(80),
        );
      case RiskStatus.synced:
        return _BadgeConfig(
          label: 'SINKRONIZUAR',
          icon: 'cloud_done',
          textColor: AppTheme.success,
          bgColor: AppTheme.successContainer,
          borderColor: AppTheme.success.withAlpha(80),
        );
      case RiskStatus.pendingSync:
        return _BadgeConfig(
          label: 'PA SINKR.',
          icon: 'cloud_upload',
          textColor: AppTheme.warning,
          bgColor: AppTheme.warningContainer,
          borderColor: AppTheme.warning.withAlpha(80),
        );
      case RiskStatus.highRisk:
        return _BadgeConfig(
          label: 'RREZIK I LARTË',
          icon: 'warning',
          textColor: AppTheme.errorColor,
          bgColor: const Color(0xFF2D0A0A),
          borderColor: AppTheme.errorColor.withAlpha(80),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final String icon;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  _BadgeConfig({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}
