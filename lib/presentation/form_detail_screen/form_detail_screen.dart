import '../../core/app_export.dart';
import '../../services/pdf_service.dart';
import '../../services/supabase_service.dart';

class FormDetailScreen extends StatefulWidget {
  final Map<String, dynamic> submission;

  const FormDetailScreen({super.key, required this.submission});

  @override
  State<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailScreen> {
  bool _isDownloadingPdf = false;

  String _formatDateTime(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloadingPdf = true);
    try {
      await PdfService.instance.generateAndShareForm(widget.submission);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim gjatë gjenerimit të PDF: ${e.toString().substring(0, e.toString().length.clamp(0, 60))}',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitterName = widget.submission['submitter_name'] ?? '—';
    final workOrder = widget.submission['work_order'] ?? '—';
    final submittedAt = _formatDateTime(widget.submission['submitted_at']);
    final workTypes =
        widget.submission['work_types'] as Map<String, dynamic>? ?? {};
    final activities =
        widget.submission['activities'] as Map<String, dynamic>? ?? {};
    final ppeChecklist =
        widget.submission['ppe_checklist'] as Map<String, dynamic>? ?? {};
    final employees =
        (widget.submission['employees'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    final suspensionReason = widget.submission['suspension_reason'] ?? '';
    final rawPhotoUrls = widget.submission['photo_urls'];
    final List<String> photoUrls = rawPhotoUrls is List
        ? SupabaseService.instance.refreshPhotoUrls(rawPhotoUrls)
        : [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderCard(submitterName, workOrder, submittedAt),
                    const SizedBox(height: 12),
                    _buildWorkTypesCard(workTypes),
                    const SizedBox(height: 12),
                    if (activities.isNotEmpty) ...[
                      _buildActivitiesCard(activities),
                      const SizedBox(height: 12),
                    ],
                    _buildPPECard(ppeChecklist),
                    const SizedBox(height: 12),
                    if (employees.isNotEmpty) ...[
                      _buildEmployeesCard(employees),
                      const SizedBox(height: 12),
                    ],
                    if (photoUrls.isNotEmpty) ...[
                      _buildPhotosCard(photoUrls),
                      const SizedBox(height: 12),
                    ],
                    if (suspensionReason.isNotEmpty) ...[
                      _buildSuspensionCard(suspensionReason),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    _buildDownloadPdfButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.outlineDark)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.onSurfaceText,
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              'Detajet e Formës',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceText,
              ),
            ),
          ),
          // PDF download button in app bar
          _isDownloadingPdf
              ? Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                )
              : IconButton(
                  onPressed: _downloadPdf,
                  tooltip: 'Shkarko PDF',
                  icon: CustomIconWidget(
                    iconName: 'picture_as_pdf',
                    color: AppTheme.errorColor,
                    size: 22,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildDownloadPdfButton() {
    return GestureDetector(
      onTap: _isDownloadingPdf ? null : _downloadPdf,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isDownloadingPdf
              ? AppTheme.surfaceVariantDark
              : const Color(0xFF2D0A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isDownloadingPdf
                ? AppTheme.outlineDark
                : AppTheme.errorColor.withAlpha(120),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloadingPdf)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.errorColor,
                ),
              )
            else
              CustomIconWidget(
                iconName: 'picture_as_pdf',
                color: AppTheme.errorColor,
                size: 20,
              ),
            const SizedBox(width: 10),
            Text(
              _isDownloadingPdf
                  ? 'Duke gjeneruar PDF...'
                  : 'Shkarko Formën si PDF',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isDownloadingPdf
                    ? AppTheme.mutedText
                    : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    String submitterName,
    String workOrder,
    String submittedAt,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.primary,
                    size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurfaceText,
                      ),
                    ),
                    Text(
                      'Punonjësi',
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
          const SizedBox(height: 12),
          _buildInfoRow('Nr. Urdhëri', workOrder, 'work_outline'),
          const SizedBox(height: 6),
          _buildInfoRow('Data & Ora', submittedAt, 'schedule'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String icon) {
    return Row(
      children: [
        CustomIconWidget(iconName: icon, color: AppTheme.mutedText, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            color: AppTheme.mutedText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTypesCard(Map<String, dynamic> workTypes) {
    final selected = <String>[];
    if (workTypes['instalim_ri'] == true) selected.add('Instalim i Ri');
    if (workTypes['suport'] == true) selected.add('Suport');
    if (workTypes['migrim'] == true) selected.add('Migrim');
    if (workTypes['kulle'] == true) selected.add('Punime ne Kulle');

    return _buildSectionCard(
      title: 'PUNA E PLANIFIKUAR',
      icon: 'work',
      child: selected.isEmpty
          ? Text(
              'Asnjë lloj pune i zgjedhur',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: AppTheme.mutedText,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 6,
              children: selected
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(40),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primary.withAlpha(80),
                        ),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildActivitiesCard(Map<String, dynamic> activities) {
    final actTitles = {
      'act1': 'Kushtet Atmosferike',
      'act2': 'Drejtimi i Mjetit',
      'act3': 'Punime ne Lartesi',
      'act4': 'Pune me pajisje elektrike',
      'act5': 'Pune prane instalimeve',
      'act6': 'Pune ne Pusin Teknik',
      'act7': 'Ngritja e peshave',
      'act8': 'Ngjitja ne Kulle',
      'act9': 'Hapesira te Kufizuara',
      'act10': 'Komunikimi',
    };

    final actQuestions = <String, List<String>>{
      'act1': [
        '1. A jeni te informuar per ndalimin e punimeve jashte nen kushte atmosferike te papershtatshme si Shi i dendur, Shkarkesa atmosferike, Rreshje bore, Ngrice etj?',
        '2. A jane kushtet atmosferike te pershtatshme per nje pune te sigurte dhe pa rreziqe shoqeruese (rreshqitje, goditje nga shkarkesa elektrike, mungese shikueshmerie etj)?',
      ],
      'act2': [
        '1. A eshte kontrolluar mjeti i punes qe te jete i sigurte?',
        '2. A eshte personeli i autorizuar qe te drejtoj mjetin (leje drejtimi, trajnim)?',
        '3. A eshte mjeti i pajisur me fikse zjarri/kuti te ndihmes se pare?',
        '4. A eshte stafi i trajnuar mbi Drejtimin e Sigurte, Politiken e Tolerances Zero dhe Pergjigjen ne rastet emergjente te nje aksidenti rrugor? (112;127;128;129)',
      ],
      'act3': [
        '1. A eshte shkalle qe do te perdoret ne pune standart EN 131, e kontrolluar dhe pa difekte?',
        '2. A jeni te trajnuar per punime te sigurta mbi shkalle ne lartesi mbi 2 metra duke perdorur masat mbrojtese ndaj renies (rregulli 4;1 gjithmone 3 pika kontakti, pune ne grup, rripi sig, sigurim shkalles)?',
        '3. A jane te pajisur me shkalle dielektrike, pajisje mbrojtese ndaj renies (litar pozicionimi, frenues ndaj renies, litar per te fiksuar shkalle ne shtylle, helmet, kepuce pune, jelek sinjalizues, indikator/dedektor)?',
        '4. A eshte kontrolluar vendi i punes te jete i sigurte per vendosjen e shkalles (terreni i sheshte, nese ka linja elektrike ne lartesine qe do te punohet, nese egzistojne rreziqe te tjera)?',
        '5. A eshte i rrethuar vendi i punes me sinjalistiken e duhur dhe te vendosur?',
      ],
      'act4': [
        '1. A jeni autorizuar dhe trajnuar per pune me paisje elektrike (Cert e Sigurimit Teknik Elektrik)?',
        '2. A eshte shkeputur paisja / instalimi nga tensioni?',
        '3. A keni veshur Pajisjet Personale Mbrojtese qe ju mbrojne nga renia ne kontakt me rrymen?',
        '4. A keni dijeni mbi proceduren per pune me paisejet elektrike?',
        '5. A ka tokezim paisja / Instalimi elektrik? *',
        '6. A jane te kontrolluara pajisjet qe perdorni? (te izoluara nga kontakti elektrik)?',
        '7. A i keni detektuesin e tensionit pa prekje (Indikator pa kontakt)* dhe dedektorin e afersise?',
        '8. A dispononi fikse zjarri / kuti e ndihmes se shpejte per perdorim ne rast emergjence?',
      ],
      'act5': [
        '1. A jeni trajnuar per pune afer inst & paisjeve elektrike (Cert e Sigurimit Teknik Elektrik)?',
        '2. A jeni te pajisur me PMI /Helmetat, kepucet, doreza pune, indikator, dedektor tenisoni afersie?',
        '3. A eshte distanca nga linja elektrike e sigurte (Deri 1000V->2m ; >10kV – >3m); 120kV>6m)? *',
        '4. A dispononi shkallet jopercjellese te standartit EN 131 per pune afer linjave/pajsijeve elektrike?',
        '5. I keni detektoret e prezences se tensionit/ indikatoret pa kontakt? Keni kryer testet paraprak me to?',
      ],
      'act6': [
        '1. A mund te kryhet puna e sigurte (ka barriera & parmake anesore per mbrojtje nga renia, skare mbrojtese ne dritare)?',
        '2. A punohet ne grup minimumi 2 ose me shume punetor?',
        '3. A jane marre masa nese nuk ka mbrojtje per reniet nga lartesia? A duhen perdorur pajisjet mbrojtese ndaj renies nga lartesia dhe te fiksohen ne pike te sigurte ankorimi?',
        '4. Eshte rrethuar puseta e hapur me kone / shirit / tabela sinjalizuese?',
        '5. A keni kryer testimet e duhura nese ne pus, parking, cati, sip te brishte per prezence tensioni?',
      ],
      'act7': [
        '1. A jeni te trajnuar per ngritjen manuale me forcen e krahut?',
        '2. Ngritja, levizja, transporti te behet me dy ose me shume punetore kur pesha i kalon 25kg?',
        '3. Ka paisje te pershtatshme per ngritjen e kapakeve (leve, ganxhe...)?',
      ],
      'act8': [
        '1. A eshte i trajnuar dhe certifikuar personeli i trajnuar qe te punoj ne kulle? *',
        '2. A i keni kontrolluar pajisjet mbrojtese per pune ne lartesi (rripat e sigurise dhe aksesoret)? *',
        '3. A i keni PMI e tjera te veshura (kaska, kepuce, doreza etj)? *',
        '4. Ka nje pike ankorimi (fiksimi) te pershtatshme? *',
        '5. Jane shkallet vertikale te kontrolluara para se te ngjiteni?',
        '6. Ka cante per veglat / ose vend per lidhjen e veglave?',
      ],
      'act9': [
        '3. Eshte personeli qe do te punoj ne hapsire i trajnuar dhe certifikuar?',
        '4. Jane paisje e punes te kontrolluar dhe funksionale?',
        '5. Jane PAISJET INDIVIDUALE MBROJTESE ne dispozicion (perfshire maskat)? *',
        '6. Ka detektor gazi (O2 / H2S / CO) prezent dhe funksional? *',
        '7. Ka person qe ben mbikqyrjen ne hyrje te hapsires? *',
        '8. A keni njohuri per proceduren e hyrjes dhe te emergjences? Jane paisjet e emergjences prezente (tripod, rripa)? *',
        '9. Rrethoni zonen e punes',
      ],
      'act10': [
        '1. A hasni veshtiresi me komunikimin me klientin (A tregon ai agresivitet, reagon ashper, tregon shenja nervozizmi, eshte ofendues dhe a kerkon konflikt me ju)?',
        '2. A ndiheni te ofenduar/kercenuar kur operoni ne brendesi te objektit, baneses, ambjentit te klientit?',
      ],
    };

    return _buildSectionCard(
      title: 'AKTIVITETET',
      icon: 'checklist',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activities.entries.map((entry) {
          final actKey = entry.key;
          final actData = entry.value as Map<String, dynamic>? ?? {};
          final answers = actData['answers'] as Map<String, dynamic>? ?? {};
          final title = actTitles[actKey] ?? actKey;
          final questions = actQuestions[actKey] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...answers.entries.map((ans) {
                  final val = ans.value?.toString() ?? '—';
                  final qIndex =
                      int.tryParse(ans.key.replaceAll('q', '')) ?? -1;
                  final questionText =
                      (qIndex >= 0 && qIndex < questions.length)
                      ? questions[qIndex]
                      : 'Pyetja ${qIndex + 1}';

                  Color valColor;
                  if (val == 'Po') {
                    valColor = AppTheme.success;
                  } else if (val == 'Jo') {
                    valColor = AppTheme.errorColor;
                  } else {
                    valColor = AppTheme.mutedText;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            questionText,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              color: AppTheme.mutedText,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: valColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: valColor.withAlpha(80)),
                          ),
                          child: Text(
                            val,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: valColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPPECard(Map<String, dynamic> ppe) {
    final ppeLabels = {
      'kepuce': 'Kepucet e punes',
      'helmet': 'Helmeta',
      'doreza': 'Dorezat',
      'rroba': 'Rroba pune',
      'jelek': 'Jelek fosforishent',
      'syze': 'Syze sigurie',
      'maske': 'Maske gazi',
      'rrip': 'Rrip sigurimi',
      'mbrojtese': 'Mbrojtese degjimi',
    };

    return _buildSectionCard(
      title: 'PPE — PAJISJET MBROJTËSE',
      icon: 'security',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: ppeLabels.entries.map((e) {
          final checked = ppe[e.key] == true;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: checked
                  ? AppTheme.success.withAlpha(30)
                  : AppTheme.surfaceVariantDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: checked
                    ? AppTheme.success.withAlpha(80)
                    : AppTheme.outlineDark,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: checked ? 'check_circle' : 'cancel',
                  color: checked ? AppTheme.success : AppTheme.mutedText,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  e.value,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    color: checked
                        ? AppTheme.onSurfaceText
                        : AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmployeesCard(List<String> employees) {
    return _buildSectionCard(
      title: 'PUNONJËSIT',
      icon: 'group',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: employees
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariantDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          color: AppTheme.onSurfaceText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPhotosCard(List<String> photoUrls) {
    return _buildSectionCard(
      title: 'FOTO (${photoUrls.length})',
      icon: 'photo_library',
      child: SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: photoUrls.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final url = photoUrls[i];
            return GestureDetector(
              onTap: () => _showFullPhoto(ctx, url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _PhotoThumbnail(url: url),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspensionCard(String reason) {
    return _buildSectionCard(
      title: 'ARSYEJA E PEZULLIMIT',
      icon: 'warning',
      borderColor: AppTheme.warning.withAlpha(80),
      child: Text(
        reason,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          color: AppTheme.onSurfaceText,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String icon,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: AppTheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.mutedText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Stateful thumbnail widget that handles loading, error, and retry for a photo URL.
class _PhotoThumbnail extends StatefulWidget {
  final String url;
  const _PhotoThumbnail({required this.url});

  @override
  State<_PhotoThumbnail> createState() => _PhotoThumbnailState();
}

class _PhotoThumbnailState extends State<_PhotoThumbnail> {
  late String _effectiveUrl;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _effectiveUrl = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: 120,
        height: 120,
        color: AppTheme.surfaceVariantDark,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'broken_image',
              color: AppTheme.mutedText,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Foto',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 10,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return Image.network(
      _effectiveUrl,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      headers: const {'Cache-Control': 'no-cache'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 120,
          height: 120,
          color: AppTheme.surfaceVariantDark,
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, error, __) {
        final publicUrl = _tryBuildPublicUrl(_effectiveUrl);
        if (publicUrl != null && publicUrl != _effectiveUrl) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _effectiveUrl = publicUrl;
              });
            }
          });
          return Container(
            width: 120,
            height: 120,
            color: AppTheme.surfaceVariantDark,
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _hasError = true);
        });
        return Container(
          width: 120,
          height: 120,
          color: AppTheme.surfaceVariantDark,
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  String? _tryBuildPublicUrl(String url) {
    try {
      final supabaseUrl = SupabaseService.supabaseUrl;
      if (supabaseUrl.isEmpty) return null;
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.contains('public')) return null;
      final signIdx = segments.indexOf('sign');
      if (signIdx != -1 && signIdx + 1 < segments.length) {
        final rest = segments.sublist(signIdx + 1).join('/');
        return '$supabaseUrl/storage/v1/object/public/$rest';
      }
      final authIdx = segments.indexOf('authenticated');
      if (authIdx != -1 && authIdx + 1 < segments.length) {
        final rest = segments.sublist(authIdx + 1).join('/');
        return '$supabaseUrl/storage/v1/object/public/$rest';
      }
    } catch (_) {}
    return null;
  }
}
