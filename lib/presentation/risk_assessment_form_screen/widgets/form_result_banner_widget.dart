import '../../../core/app_export.dart';

enum AssessmentResult { proceed, doNotProceed }

class FormResultBannerWidget extends StatefulWidget {
  final AssessmentResult result;
  final String caseId;
  final VoidCallback onOpenVodafone;
  final VoidCallback onReset;

  const FormResultBannerWidget({
    super.key,
    required this.result,
    required this.caseId,
    required this.onOpenVodafone,
    required this.onReset,
  });

  @override
  State<FormResultBannerWidget> createState() => _FormResultBannerWidgetState();
}

class _FormResultBannerWidgetState extends State<FormResultBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProceed = widget.result == AssessmentResult.proceed;
    final bgColor = isProceed
        ? AppTheme.successContainer
        : const Color(0xFF2D0A0A);
    final borderColor = isProceed
        ? AppTheme.success.withAlpha(120)
        : AppTheme.errorColor.withAlpha(120);
    final iconName = isProceed ? 'check_circle' : 'cancel';
    final iconColor = isProceed ? AppTheme.success : AppTheme.errorColor;
    final label = isProceed ? 'MUND TË VAZHDOHET' : 'NUK MUND TË VAZHDOHET';
    final sublabel = isProceed
        ? 'Rreziqet janë brenda kufijve të pranueshëm. Puna mund të fillojë.'
        : 'Janë identifikuar rreziqe të larta. Puna nuk mund të fillojë pa masa korrigjuese.';

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: iconColor.withAlpha(40),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: iconColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (widget.caseId.isNotEmpty)
                        Text(
                          'Rast: ${widget.caseId}',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 12,
                            color: iconColor.withAlpha(180),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              sublabel,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: AppTheme.onSurfaceText.withAlpha(200),
              ),
            ),
            const SizedBox(height: 16),
            // Vodafone deep-link button — shown only after form completion
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: widget.onOpenVodafone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60000), // Vodafone red
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'open_in_new',
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hap Ticketin në Vodafone',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: widget.onReset,
              child: Text(
                'Plotëso formular të ri',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: AppTheme.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
