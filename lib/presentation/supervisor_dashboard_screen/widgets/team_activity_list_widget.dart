import '../../../core/app_export.dart';

class TeamMemberActivity {
  final String name;
  final String role;
  final String lastCaseId;
  final String lastLocation;
  final bool lastProceed;
  final bool isSynced;
  final String timeAgo;
  final String avatarInitials;
  final bool isHighRisk;

  const TeamMemberActivity({
    required this.name,
    required this.role,
    required this.lastCaseId,
    required this.lastLocation,
    required this.lastProceed,
    required this.isSynced,
    required this.timeAgo,
    required this.avatarInitials,
    required this.isHighRisk,
  });

  static TeamMemberActivity fromMap(Map<String, dynamic> map) {
    return TeamMemberActivity(
      name: map['name'] as String,
      role: map['role'] as String,
      lastCaseId: map['lastCaseId'] as String,
      lastLocation: map['lastLocation'] as String,
      lastProceed: map['lastProceed'] as bool,
      isSynced: map['isSynced'] as bool,
      timeAgo: map['timeAgo'] as String,
      avatarInitials: map['avatarInitials'] as String,
      isHighRisk: map['isHighRisk'] as bool,
    );
  }
}

final List<Map<String, dynamic>> _teamMaps = [
  {
    'name': 'Arta Hoxha',
    'role': 'Teknik fiber',
    'lastCaseId': 'TK-2026-0842',
    'lastLocation': 'Myslym Shyri, Tiranë',
    'lastProceed': true,
    'isSynced': true,
    'timeAgo': '15m',
    'avatarInitials': 'AH',
    'isHighRisk': false,
  },
  {
    'name': 'Besmir Kola',
    'role': 'Teknik fiber',
    'lastCaseId': 'TK-2026-0841',
    'lastLocation': 'Kombinat, Tiranë',
    'lastProceed': false,
    'isSynced': true,
    'timeAgo': '42m',
    'avatarInitials': 'BK',
    'isHighRisk': true,
  },
  {
    'name': 'Mirela Gjoka',
    'role': 'Teknik senior',
    'lastCaseId': 'TK-2026-0840',
    'lastLocation': 'Blloku, Tiranë',
    'lastProceed': true,
    'isSynced': false,
    'timeAgo': '1h',
    'avatarInitials': 'MG',
    'isHighRisk': false,
  },
  {
    'name': 'Erjon Dervishi',
    'role': 'Teknik fiber',
    'lastCaseId': 'TK-2026-0838',
    'lastLocation': 'Shkozë, Durrës',
    'lastProceed': true,
    'isSynced': true,
    'timeAgo': '2h',
    'avatarInitials': 'ED',
    'isHighRisk': false,
  },
  {
    'name': 'Valentina Peci',
    'role': 'Teknik koaksial',
    'lastCaseId': 'TK-2026-0835',
    'lastLocation': 'Rruga e Kavajës',
    'lastProceed': false,
    'isSynced': true,
    'timeAgo': '3h',
    'avatarInitials': 'VP',
    'isHighRisk': true,
  },
  {
    'name': 'Genti Lala',
    'role': 'Teknik fiber',
    'lastCaseId': 'TK-2026-0830',
    'lastLocation': 'Fresku, Tiranë',
    'lastProceed': true,
    'isSynced': true,
    'timeAgo': '4h',
    'avatarInitials': 'GL',
    'isHighRisk': false,
  },
];

class TeamActivityListWidget extends StatelessWidget {
  const TeamActivityListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final members = _teamMaps.map(TeamMemberActivity.fromMap).toList();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'group',
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aktiviteti i Ekipit',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMuted,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${members.length} punonjës',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.outlineDark, height: 1),
          ...members.asMap().entries.map((e) {
            final m = e.value;
            final isLast = e.key == members.length - 1;
            return Column(
              children: [
                _TeamMemberRow(member: m),
                if (!isLast)
                  Divider(
                    color: AppTheme.outlineVariantDark,
                    height: 1,
                    indent: 60,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  final TeamMemberActivity member;
  const _TeamMemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: member.isHighRisk
                  ? const Color(0xFF2D0A0A)
                  : AppTheme.primaryMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: member.isHighRisk
                    ? AppTheme.errorColor.withAlpha(80)
                    : AppTheme.outlineDark,
              ),
            ),
            child: Center(
              child: Text(
                member.avatarInitials,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: member.isHighRisk
                      ? AppTheme.errorColor
                      : AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceText,
                      ),
                    ),
                    const Spacer(),
                    StatusBadgeWidget(
                      status: member.lastProceed
                          ? RiskStatus.proceed
                          : RiskStatus.doNotProceed,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      member.lastCaseId,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.mutedText,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        member.lastLocation,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          color: AppTheme.mutedText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CustomIconWidget(
                      iconName: member.isSynced ? 'cloud_done' : 'cloud_upload',
                      color: member.isSynced
                          ? AppTheme.success
                          : AppTheme.warning,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      member.timeAgo,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 10,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
