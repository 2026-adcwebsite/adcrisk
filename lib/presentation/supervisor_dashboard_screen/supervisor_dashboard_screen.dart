import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../form_detail_screen/form_detail_screen.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  String _currentUserRole = 'supervisor';
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = await SupabaseService.instance.getCurrentUserProfile();
    final submissions = await SupabaseService.instance.getAllSubmissions();
    if (mounted) {
      setState(() {
        _currentUserRole = profile?['role'] ?? 'supervisor';
        _currentUserName = profile?['full_name'] ?? '';
        _submissions = submissions;
        _isLoading = false;
      });
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
                      child: _submissions.isEmpty
                          ? _buildEmpty()
                          : _buildSubmissionsList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentUserRole == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.adminUserManagementScreen,
              ),
              backgroundColor: AppTheme.primary,
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Shto User',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      bottomNavigationBar: AppNavigation(
        currentIndex: 3,
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
                  _currentUserRole == 'admin'
                      ? 'Dashboard Admin'
                      : 'Dashboard Mbikëqyrësi',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withAlpha(80)),
            ),
            child: Text(
              '${_submissions.length} Forma',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              await SupabaseService.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.signUpLoginScreen,
                  (r) => false,
                );
              }
            },
            icon: CustomIconWidget(
              iconName: 'logout',
              color: AppTheme.mutedText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'assignment_outlined',
            color: AppTheme.mutedText,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Nuk ka forma të dërguara',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _submissions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _buildSubmissionCard(_submissions[i]),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> sub) {
    final submitterName = sub['submitter_name'] ?? 'I panjohur';
    final workOrder = sub['work_order'] ?? '—';
    final submittedAt = sub['submitted_at'] ?? '';
    final photoUrls = (sub['photo_urls'] as List?)?.cast<String>() ?? [];

    DateTime? dt;
    try {
      dt = DateTime.parse(submittedAt).toLocal();
    } catch (_) {}

    final dateStr = dt != null
        ? '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : submittedAt;

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
          border: Border.all(color: AppTheme.outlineDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submitterName,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'WO: $workOrder',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.mutedText,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.mutedText,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    color: AppTheme.mutedText,
                  ),
                ),
                const Spacer(),
                if (photoUrls.isNotEmpty) ...[
                  CustomIconWidget(
                    iconName: 'photo_camera',
                    color: AppTheme.secondary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${photoUrls.length} foto',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      color: AppTheme.secondary,
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
