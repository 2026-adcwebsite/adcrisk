import '../../../core/app_export.dart';

class ReportFilterSectionWidget extends StatelessWidget {
  final DateTimeRange dateRange;
  final String riskFilter;
  final String employeeFilter;
  final List<String> riskFilters;
  final List<String> employeeFilters;
  final VoidCallback onDateRangeTap;
  final Function(String?) onRiskFilterChanged;
  final Function(String?) onEmployeeFilterChanged;
  final String Function(DateTime) formatDate;

  const ReportFilterSectionWidget({
    super.key,
    required this.dateRange,
    required this.riskFilter,
    required this.employeeFilter,
    required this.riskFilters,
    required this.employeeFilters,
    required this.onDateRangeTap,
    required this.onRiskFilterChanged,
    required this.onEmployeeFilterChanged,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
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
                iconName: 'filter_list',
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrat e Raportit',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date range picker
          GestureDetector(
            onTap: onDateRangeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineDark),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'date_range',
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Periudha',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        Text(
                          '${formatDate(dateRange.start)} — ${formatDate(dateRange.end)}',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.mutedText,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Risk level filter
          _buildDropdownField(
            label: 'Niveli i Rrezikut',
            value: riskFilter,
            items: riskFilters,
            onChanged: onRiskFilterChanged,
            icon: 'warning',
          ),
          const SizedBox(height: 12),
          // Employee filter
          _buildDropdownField(
            label: 'Punonjësi',
            value: employeeFilter,
            items: employeeFilters,
            onChanged: onEmployeeFilterChanged,
            icon: 'person',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Row(
        children: [
          CustomIconWidget(iconName: icon, color: AppTheme.mutedText, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceDark,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  color: AppTheme.onSurfaceText,
                ),
                hint: Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(
                    color: AppTheme.mutedText,
                    fontSize: 13,
                  ),
                ),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
