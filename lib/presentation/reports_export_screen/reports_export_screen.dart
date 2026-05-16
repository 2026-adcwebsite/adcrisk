import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../services/pdf_service.dart';
import '../../services/supabase_service.dart';
import './widgets/report_action_grid_widget.dart';
import './widgets/report_filter_section_widget.dart';
import './widgets/report_summary_stats_widget.dart';

class ReportsExportScreen extends StatefulWidget {
  const ReportsExportScreen({super.key});

  @override
  State<ReportsExportScreen> createState() => _ReportsExportScreenState();
}

class _ReportsExportScreenState extends State<ReportsExportScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String _riskFilter = 'Të gjitha';
  String _employeeFilter = 'Të gjithë punonjësit';
  bool _isGenerating = false;
  List<Map<String, dynamic>> _allSubmissions = [];
  bool _isLoadingData = true;

  final List<String> _riskFilters = [
    'Të gjitha',
    'Proceed',
    'No Proceed',
    'Rrezik i lartë',
  ];
  List<String> _employeeFilters = ['Të gjithë punonjësit'];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoadingData = true);
    try {
      final data = await SupabaseService.instance.getAllSubmissions();
      final names =
          data
              .map((s) => (s['submitter_name'] ?? '').toString())
              .where((n) => n.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      setState(() {
        _allSubmissions = data;
        _employeeFilters = ['Të gjithë punonjësit', ...names];
        _isLoadingData = false;
      });
    } catch (_) {
      setState(() => _isLoadingData = false);
    }
  }

  List<Map<String, dynamic>> get _filteredSubmissions {
    return _allSubmissions.where((s) {
      // Date filter
      try {
        final dt = DateTime.parse(s['submitted_at'] ?? '').toLocal();
        if (dt.isBefore(_dateRange.start) ||
            dt.isAfter(_dateRange.end.add(const Duration(days: 1)))) {
          return false;
        }
      } catch (_) {}

      // Employee filter
      if (_employeeFilter != 'Të gjithë punonjësit') {
        if ((s['submitter_name'] ?? '') != _employeeFilter) return false;
      }

      // Risk filter
      if (_riskFilter != 'Të gjitha') {
        final hasSuspension =
            (s['suspension_reason'] ?? '').toString().isNotEmpty &&
            (s['suspension_reason'] ?? '').toString() != 'null';
        if (_riskFilter == 'Proceed' && hasSuspension) return false;
        if (_riskFilter == 'No Proceed' && !hasSuspension) return false;
        if (_riskFilter == 'Rrezik i lartë' && !hasSuspension) return false;
      }

      return true;
    }).toList();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surfaceDark,
            onSurface: AppTheme.onSurfaceText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _generateExport(String type) async {
    if (type == 'PDF') {
      await _generatePdfReport();
      return;
    }
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _isGenerating = false);
    Fluttertoast.showToast(
      msg: '$type u eksportua me sukses',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successContainer,
      textColor: AppTheme.success,
    );
  }

  Future<void> _generatePdfReport() async {
    setState(() => _isGenerating = true);
    try {
      final filtered = _filteredSubmissions;
      if (filtered.isEmpty) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Nuk ka të dhëna për filtrat e zgjedhur',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppTheme.warningContainer,
            textColor: AppTheme.warning,
          );
        }
        setState(() => _isGenerating = false);
        return;
      }
      await PdfService.instance.generateAndShareReport(
        submissions: filtered,
        dateRange: _dateRange,
        riskFilter: _riskFilter,
        employeeFilter: _employeeFilter,
      );
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg:
              'Gabim gjatë gjenerimit të PDF: ${e.toString().substring(0, e.toString().length.clamp(0, 60))}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.errorColor.withAlpha(200),
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  int get _recordCount => _isLoadingData ? 0 : _filteredSubmissions.length;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 24 : 16,
                  12,
                  isTablet ? 24 : 16,
                  100,
                ),
                child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
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
                  'Raporte & Eksportim',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                Text(
                  'Gjenero dhe eksporto të dhënat',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duke ngarkuar...',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (_isGenerating)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duke gjeneruar...',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportFilterSectionWidget(
          dateRange: _dateRange,
          riskFilter: _riskFilter,
          employeeFilter: _employeeFilter,
          riskFilters: _riskFilters,
          employeeFilters: _employeeFilters,
          onDateRangeTap: _selectDateRange,
          onRiskFilterChanged: (v) =>
              setState(() => _riskFilter = v ?? _riskFilter),
          onEmployeeFilterChanged: (v) =>
              setState(() => _employeeFilter = v ?? _employeeFilter),
          formatDate: _formatDate,
        ),
        const SizedBox(height: 16),
        ReportSummaryStatsWidget(
          recordCount: _recordCount,
          dateRange: _dateRange,
          riskFilter: _riskFilter,
          employeeFilter: _employeeFilter,
          formatDate: _formatDate,
        ),
        const SizedBox(height: 16),
        ReportActionGridWidget(
          isGenerating: _isGenerating,
          onExport: _generateExport,
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              ReportFilterSectionWidget(
                dateRange: _dateRange,
                riskFilter: _riskFilter,
                employeeFilter: _employeeFilter,
                riskFilters: _riskFilters,
                employeeFilters: _employeeFilters,
                onDateRangeTap: _selectDateRange,
                onRiskFilterChanged: (v) =>
                    setState(() => _riskFilter = v ?? _riskFilter),
                onEmployeeFilterChanged: (v) =>
                    setState(() => _employeeFilter = v ?? _employeeFilter),
                formatDate: _formatDate,
              ),
              const SizedBox(height: 16),
              ReportSummaryStatsWidget(
                recordCount: _recordCount,
                dateRange: _dateRange,
                riskFilter: _riskFilter,
                employeeFilter: _employeeFilter,
                formatDate: _formatDate,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: ReportActionGridWidget(
            isGenerating: _isGenerating,
            onExport: _generateExport,
          ),
        ),
      ],
    );
  }
}
