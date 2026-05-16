import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../form_detail_screen/form_detail_screen.dart';
import './widgets/filter_chip_row_widget.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  State<SubmissionHistoryScreen> createState() =>
      _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  List<Map<String, dynamic>> _allSubmissions = [];
  List<Map<String, dynamic>> _filtered = [];
  String _activeFilter = 'Të gjitha';
  bool _isLoading = true;
  String _currentUserRole = 'worker';
  final Set<String> _retryingIds = {};

  final List<String> _filters = ['Të gjitha'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = await SupabaseService.instance.getCurrentUserProfile();
    final role = profile?['role'] ?? 'worker';

    List<Map<String, dynamic>> submissions;
    if (role == 'admin' || role == 'manager' || role == 'supervisor') {
      submissions = await SupabaseService.instance.getAllSubmissions();
    } else {
      submissions = await SupabaseService.instance.getMySubmissions();
    }

    if (mounted) {
      setState(() {
        _currentUserRole = role;
        _allSubmissions = submissions;
        _filtered = submissions;
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _filtered = _allSubmissions;
    });
  }

  Future<void> _retrySubmission(Map<String, dynamic> sub) async {
    final id = sub['id']?.toString() ?? '';
    if (id.isEmpty) return;
    setState(() => _retryingIds.add(id));
    try {
      // Attempt to re-fetch/re-sync by reloading data
      await _loadData();
    } finally {
      if (mounted) setState(() => _retryingIds.remove(id));
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
            FilterChipRowWidget(
              filters: _filters,
              activeFilter: _activeFilter,
              onFilterSelected: _applyFilter,
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : _filtered.isEmpty
                  ? EmptyStateWidget(
                      iconName: 'history',
                      title: 'Nuk ka formularë',
                      message: 'Nuk u gjetën formularë të dorëzuar.',
                      ctaLabel: 'Plotëso Vlerësim të Ri',
                      onCta: () => Navigator.pushNamed(
                        context,
                        AppRoutes.riskAssessmentFormScreen,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final sub = _filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildSubmissionCard(sub),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.riskAssessmentFormScreen),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(iconName: 'add', color: Colors.white, size: 22),
        label: Text(
          'Vlerësim i Ri',
          style: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(
        currentIndex: 1,
        onDestinationSelected: (i) => _handleNavigation(context, i),
        isSupervisor:
            _currentUserRole == 'admin' ||
            _currentUserRole == 'manager' ||
            _currentUserRole == 'supervisor',
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final isSupervisor =
        _currentUserRole == 'admin' ||
        _currentUserRole == 'manager' ||
        _currentUserRole == 'supervisor';
    final routes = isSupervisor
        ? [
            AppRoutes.riskAssessmentFormScreen,
            AppRoutes.submissionHistoryScreen,
            AppRoutes.notificationsScreen,
            AppRoutes.supervisorDashboardScreen,
            AppRoutes.reportsExportScreen,
          ]
        : [
            AppRoutes.riskAssessmentFormScreen,
            AppRoutes.submissionHistoryScreen,
            AppRoutes.notificationsScreen,
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
                  'Historia e Formularëve',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                Text(
                  '${_allSubmissions.length} vlerësime gjithsej',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> sub) {
    final submitterName = sub['submitter_name'] ?? 'I panjohur';
    final workOrder = sub['work_order'] ?? '—';
    final submittedAt = sub['submitted_at'] ?? '';
    final photoUrls = (sub['photo_urls'] as List?)?.cast<String>() ?? [];
    // Determine sync status: use field if present, default to 'synced' for DB records
    final syncStatus = sub['sync_status']?.toString() ?? 'synced';
    final id = sub['id']?.toString() ?? '';
    final isRetrying = _retryingIds.contains(id);

    DateTime? dt;
    try {
      dt = DateTime.parse(submittedAt).toLocal();
    } catch (_) {}

    final dateStr = dt != null
        ? '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : submittedAt;

    // Badge config based on sync status
    final bool isSynced = syncStatus == 'synced';
    final bool isPending = syncStatus == 'pending';
    final bool isOffline = syncStatus == 'offline' || syncStatus == 'failed';
    final bool canRetry = isPending || isOffline;

    Color badgeColor;
    Color badgeBg;
    Color badgeBorder;
    String badgeIcon;
    String badgeLabel;

    if (isSynced) {
      badgeColor = AppTheme.success;
      badgeBg = AppTheme.successContainer;
      badgeBorder = AppTheme.success.withAlpha(80);
      badgeIcon = 'cloud_done';
      badgeLabel = 'SINKRONIZUAR';
    } else if (isPending) {
      badgeColor = AppTheme.warning;
      badgeBg = AppTheme.warningContainer;
      badgeBorder = AppTheme.warning.withAlpha(80);
      badgeIcon = 'cloud_upload';
      badgeLabel = 'NË PRITJE';
    } else {
      // offline / failed
      badgeColor = AppTheme.errorColor;
      badgeBg = const Color(0xFFFFEDED);
      badgeBorder = AppTheme.errorColor.withAlpha(80);
      badgeIcon = 'cloud_off';
      badgeLabel = 'OFFLINE';
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FormDetailScreen(submission: sub)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOffline
                ? AppTheme.errorColor.withAlpha(60)
                : isPending
                ? AppTheme.warning.withAlpha(60)
                : AppTheme.outlineDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + name/work order + photo count + chevron
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'assignment',
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submitterName,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nr. Urdhëri: $workOrder',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (photoUrls.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'photo',
                          color: AppTheme.secondary,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${photoUrls.length}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.mutedText,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Status row: sync badge + timestamp + retry button
            Row(
              children: [
                // Sync status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: badgeIcon,
                        color: badgeColor,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        badgeLabel,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Timestamp
                Expanded(
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.mutedText,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          dateStr.isNotEmpty ? dateStr : '—',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Retry button for pending/offline/failed
                if (canRetry) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isRetrying ? null : () => _retrySubmission(sub),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isOffline
                            ? AppTheme.errorColor.withAlpha(20)
                            : AppTheme.warning.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isOffline
                              ? AppTheme.errorColor.withAlpha(80)
                              : AppTheme.warning.withAlpha(80),
                          width: 1,
                        ),
                      ),
                      child: isRetrying
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: isOffline
                                    ? AppTheme.errorColor
                                    : AppTheme.warning,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'refresh',
                                  color: isOffline
                                      ? AppTheme.errorColor
                                      : AppTheme.warning,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Riprovo',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isOffline
                                        ? AppTheme.errorColor
                                        : AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
