import '../../../core/app_export.dart';

class FormSectionCardWidget extends StatefulWidget {
  final String sectionNumber;
  final String title;
  final String icon;
  final Widget child;
  final bool hasRisk;

  const FormSectionCardWidget({
    super.key,
    required this.sectionNumber,
    required this.title,
    required this.icon,
    required this.child,
    this.hasRisk = false,
  });

  @override
  State<FormSectionCardWidget> createState() => _FormSectionCardWidgetState();
}

class _FormSectionCardWidgetState extends State<FormSectionCardWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.hasRisk
              ? AppTheme.errorColor.withAlpha(100)
              : AppTheme.outlineDark,
          width: widget.hasRisk ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.hasRisk
                          ? AppTheme.errorColor.withAlpha(30)
                          : AppTheme.primaryMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: widget.icon,
                        color: widget.hasRisk
                            ? AppTheme.errorColor
                            : AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seksioni ${widget.sectionNumber}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurfaceText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.hasRisk)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D0A0A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.errorColor.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'warning',
                            color: AppTheme.errorColor,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rrezik',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 10,
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.mutedText,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
