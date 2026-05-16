import '../../../core/app_export.dart';

class FilterChipRowWidget extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final Function(String) onFilterSelected;

  const FilterChipRowWidget({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.outlineDark)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = filter == activeFilter;
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryMuted
                    : AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isActive ? AppTheme.primary : AppTheme.outlineDark,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Text(
                filter,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppTheme.primary : AppTheme.mutedText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
