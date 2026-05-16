import '../../../core/app_export.dart';

class SubmissionModel {
  final String caseId;
  final String location;
  final String workType;
  final DateTime date;
  final bool canProceed;
  final bool isSynced;
  final bool isHighRisk;

  const SubmissionModel({
    required this.caseId,
    required this.location,
    required this.workType,
    required this.date,
    required this.canProceed,
    required this.isSynced,
    required this.isHighRisk,
  });
}

class SubmissionCardWidget extends StatelessWidget {
  final SubmissionModel submission;
  final VoidCallback onTap;

  const SubmissionCardWidget({
    super.key,
    required this.submission,
    required this.onTap,
  });

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isHighRisk = submission.isHighRisk;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighRisk
              ? AppTheme.errorColor.withAlpha(80)
              : AppTheme.outlineDark,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primaryMuted,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusBadgeWidget(
                    status: submission.canProceed
                        ? RiskStatus.proceed
                        : RiskStatus.doNotProceed,
                    compact: true,
                  ),
                  const SizedBox(width: 6),
                  StatusBadgeWidget(
                    status: submission.isSynced
                        ? RiskStatus.synced
                        : RiskStatus.pendingSync,
                    compact: true,
                  ),
                  if (isHighRisk) ...[
                    const SizedBox(width: 6),
                    StatusBadgeWidget(
                      status: RiskStatus.highRisk,
                      compact: true,
                    ),
                  ],
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(submission.date),
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          color: AppTheme.mutedText,
                        ),
                      ),
                      Text(
                        _formatTime(submission.date),
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'work',
                    color: AppTheme.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    submission.caseId,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurfaceText,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.mutedText,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.mutedText,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      submission.location,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: AppTheme.mutedText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'construction',
                    color: AppTheme.mutedText,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    submission.workType,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
