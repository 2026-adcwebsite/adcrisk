import '../../../core/app_export.dart';

class ReportActionGridWidget extends StatelessWidget {
  final bool isGenerating;
  final Function(String) onExport;

  const ReportActionGridWidget({
    super.key,
    required this.isGenerating,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Eksporto PDF',
        sublabel: 'Raport i formatuar',
        iconName: 'picture_as_pdf',
        color: AppTheme.errorColor,
        bgColor: const Color(0xFF2D0A0A),
        exportType: 'PDF',
      ),
      _ActionItem(
        label: 'Eksporto CSV',
        sublabel: 'Të dhëna tabelare',
        iconName: 'table_chart',
        color: AppTheme.success,
        bgColor: AppTheme.successContainer,
        exportType: 'CSV',
      ),
      _ActionItem(
        label: 'Dërgo me Email',
        sublabel: 'Raporti dërguar direkt',
        iconName: 'email',
        color: AppTheme.primary,
        bgColor: AppTheme.primaryMuted,
        exportType: 'Email',
      ),
      _ActionItem(
        label: 'Printo',
        sublabel: 'Printer lokal / Wi-Fi',
        iconName: 'print',
        color: AppTheme.warning,
        bgColor: AppTheme.warningContainer,
        exportType: 'Print',
      ),
    ];

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
                iconName: 'download',
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Veprimet e Eksportimit',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 UNIFORM grid — anatomy locked from reference image extraction
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: actions
                .map(
                  (action) => _ActionCard(
                    action: action,
                    isGenerating: isGenerating,
                    onTap: () => onExport(action.exportType),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final String sublabel;
  final String iconName;
  final Color color;
  final Color bgColor;
  final String exportType;

  const _ActionItem({
    required this.label,
    required this.sublabel,
    required this.iconName,
    required this.color,
    required this.bgColor,
    required this.exportType,
  });
}

class _ActionCard extends StatefulWidget {
  final _ActionItem action;
  final bool isGenerating;
  final VoidCallback onTap;

  const _ActionCard({
    required this.action,
    required this.isGenerating,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressAnim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _pressAnim.forward(),
        onTapUp: (_) {
          _pressAnim.reverse();
          if (!widget.isGenerating) widget.onTap();
        },
        onTapCancel: () => _pressAnim.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariantDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isGenerating
                  ? AppTheme.outlineDark
                  : widget.action.color.withAlpha(60),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.action.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: widget.isGenerating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.action.color,
                          ),
                        )
                      : CustomIconWidget(
                          iconName: widget.action.iconName,
                          color: widget.action.color,
                          size: 20,
                        ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.action.label,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: widget.isGenerating
                          ? AppTheme.mutedText
                          : AppTheme.onSurfaceText,
                    ),
                  ),
                  Text(
                    widget.action.sublabel,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      color: AppTheme.mutedText,
                    ),
                    overflow: TextOverflow.ellipsis,
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
