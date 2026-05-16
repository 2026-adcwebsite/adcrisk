import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';

class RiskAssessmentFormScreen extends StatefulWidget {
  const RiskAssessmentFormScreen({super.key});

  @override
  State<RiskAssessmentFormScreen> createState() =>
      _RiskAssessmentFormScreenState();
}

// Po / Jo / N/A options
enum TriOption { po, jo, na }

extension TriOptionExt on TriOption {
  String get label {
    switch (this) {
      case TriOption.po:
        return 'Po';
      case TriOption.jo:
        return 'Jo';
      case TriOption.na:
        return 'N/A';
    }
  }

  String get value {
    switch (this) {
      case TriOption.po:
        return 'Po';
      case TriOption.jo:
        return 'Jo';
      case TriOption.na:
        return 'N/A';
    }
  }
}

class _RiskAssessmentFormScreenState extends State<RiskAssessmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  bool _isFormSubmitted = false;

  // Current user info
  String _currentUserName = '';
  String _currentUserRole = 'worker';

  // Header fields
  final _workOrderController = TextEditingController();
  String _submittedAt = '';

  // Work types
  bool _wtInstalimRi = false;
  bool _wtSuport = false;
  bool _wtMigrim = false;
  bool _wtKulle = false;

  // Activity answers: Map<activityKey, Map<questionKey, TriOption?>>
  final Map<String, Map<String, TriOption?>> _activityAnswers = {};

  // Activity active flags
  final Map<String, bool> _activityActive = {};

  // PPE Checklist
  bool _ppeKepuce = false;
  bool _ppeHelmet = false;
  bool _ppeDoreza = false;
  bool _ppeRroba = false;
  bool _ppeJelek = false;
  bool _ppeSyze = false;
  bool _ppeMaske = false;
  bool _ppeRrip = false;
  bool _ppeMbrojtese = false;

  // Employees
  final List<TextEditingController> _employeeControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  // Suspension reason
  final _suspensionReasonController = TextEditingController();

  // Photos
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  // Activity definitions
  static const List<Map<String, dynamic>> _activities = [
    {
      'key': 'act1',
      'number': '1',
      'title': 'Kushtet Atmosferike',
      'hazards': 'Kushte te pafavorshme atmosferike',
      'questions': [
        '1. A jeni te informuar per ndalimin e punimeve jashte nen kushte atmosferike te papershtatshme si Shi i dendur, Shkarkesa atmosferike, Rreshje bore, Ngrice etj?',
        '2. A jane kushtet atmosferike te pershtatshme per nje pune te sigurte dhe pa rreziqe shoqeruese (rreshqitje, goditje nga shkarkesa elektrike, mungese shikueshmerie etj)?',
      ],
    },
    {
      'key': 'act2',
      'number': '2',
      'title': 'Drejtimi i Mjetit',
      'hazards': 'Aksidentet rrugore\nZjarr i mundshem',
      'questions': [
        '1. A eshte kontrolluar mjeti i punes qe te jete i sigurte?',
        '2. A eshte personeli i autorizuar qe te drejtoj mjetin (leje drejtimi, trajnim)?',
        '3. A eshte mjeti i pajisur me fikse zjarri/kuti te ndihmes se pare?',
        '4. A eshte stafi i trajnuar mbi Drejtimin e Sigurte, Politiken e Tolerances Zero dhe Pergjigjen ne rastet emergjente te nje aksidenti rrugor? (112;127;128;129)',
      ],
    },
    {
      'key': 'act3',
      'number': '3',
      'title': 'Punime ne Lartesi - Shkalle - Fasade - Terrace - Objekti',
      'hazards': 'Renie nga Lartesia\nRenie Objektesh',
      'questions': [
        '1. A eshte shkalle qe do te perdoret ne pune standart EN 131, e kontrolluar dhe pa difekte?',
        '2. A jeni te trajnuar per punime te sigurta mbi shkalle ne lartesi mbi 2 metra duke perdorur masat mbrojtese ndaj renies (rregulli 4;1 gjithmone 3 pika kontakti, pune ne grup, rripi sig, sigurim shkalles)?',
        '3. A jane te pajisur me shkalle dielektrike, pajisje mbrojtese ndaj renies (litar pozicionimi, frenues ndaj renies, litar per te fiksuar shkalle ne shtylle, helmet, kepuce pune, jelek sinjalizues, indikator/dedektor)?',
        '4. A eshte kontrolluar vendi i punes te jete i sigurte per vendosjen e shkalles (terreni i sheshte, nese ka linja elektrike ne lartesine qe do te punohet, nese egzistojne rreziqe te tjera)?',
        '5. A eshte i rrethuar vendi i punes me sinjalistiken e duhur dhe te vendosur?',
      ],
    },
    {
      'key': 'act4',
      'number': '4',
      'title': 'Pune me pajisje manuale elektrike',
      'hazards':
          'Renia ne kontakt me rrymen elektrike\nElektroshok / Djegie nga harku Elektrik\nZjarr i mundshem',
      'questions': [
        '1. A jeni autorizuar dhe trajnuar per pune me paisje elektrike (Cert e Sigurimit Teknik Elektrik)?',
        '2. A eshte shkeputur paisja / instalimi nga tensioni?',
        '3. A keni veshur Pajisjet Personale Mbrojtese qe ju mbrojne nga renia ne kontakt me rrymen?',
        '4. A keni dijeni mbi proceduren per pune me paisejet elektrike?',
        '5. A ka tokezim paisja / Instalimi elektrik? *',
        '6. A jane te kontrolluara pajisjet qe perdorni? (te izoluara nga kontakti elektrik)?',
        '7. A i keni detektuesin e tensionit pa prekje (Indikator pa kontakt)* dhe dedektorin e afersise?',
        '8. A dispononi fikse zjarri / kuti e ndihmes se shpejte per perdorim ne rast emergjence?',
      ],
    },
    {
      'key': 'act5',
      'number': '5',
      'title': 'Pune prane instalimeve & Pajisjeve Elektrike',
      'hazards':
          'Renia ne kontakt me rrymen / Elektroshok\nRenie nga lartesia ne rast kontakti',
      'questions': [
        '1. A jeni trajnuar per pune afer inst & paisjeve elektrike (Cert e Sigurimit Teknik Elektrik)?',
        '2. A jeni te pajisur me PMI /Helmetat, kepucet, doreza pune, indikator, dedektor tenisoni afersie?',
        '3. A eshte distanca nga linja elektrike e sigurte (Deri 1000V->2m ; >10kV – >3m); 120kV>6m)? *',
        '4. A dispononi shkallet jopercjellese te standartit EN 131 per pune afer linjave/pajsijeve elektrike?',
        '5. I keni detektoret e prezences se tensionit/ indikatoret pa kontakt? Keni kryer testet paraprak me to?',
      ],
    },
    {
      'key': 'act6',
      'number': '6',
      'title': 'Pune ne Pusin Teknik / Parking te Godines, Cati',
      'hazards':
          'Renia nga Lartesia / nga hapesira e pusit teknik.\nRenie nga siperfaqe te brishte.\nRenie ne pusete.',
      'questions': [
        '1. A mund te kryhet puna e sigurte (ka barriera & parmake anesore per mbrojtje nga renia, skare mbrojtese ne dritare)?',
        '2. A punohet ne grup minimumi 2 ose me shume punetor?',
        '3. A jane marre masa nese nuk ka mbrojtje per reniet nga lartesia? A duhen perdorur pajisjet mbrojtese ndaj renies nga lartesia dhe te fiksohen ne pike te sigurte ankorimi?',
        '4. Eshte rrethuar puseta e hapur me kone / shirit / tabela sinjalizuese?',
        '5. A keni kryer testimet e duhura nese ne pus, parking, cati, sip te brishte per prezence tensioni?',
      ],
    },
    {
      'key': 'act7',
      'number': '7',
      'title': 'Ngritja, spostimi, transporti manual i peshave',
      'hazards': 'Ngritja e peshave me forcen e kraheve',
      'questions': [
        '1. A jeni te trajnuar per ngritjen manuale me forcen e krahut?',
        '2. Ngritja, levizja, transporti te behet me dy ose me shume punetore kur pesha i kalon 25kg?',
        '3. Ka paisje te pershtatshme per ngritjen e kapakeve (leve, ganxhe...)?',
      ],
    },
    {
      'key': 'act8',
      'number': '8',
      'title': 'Ngjitja ne Kulle',
      'hazards': 'Renia nga lartesia\nRenia e objekteve/paisjeve te punes',
      'questions': [
        '1. A eshte i trajnuar dhe certifikuar personeli i trajnuar qe te punoj ne kulle? *',
        '2. A i keni kontrolluar pajisjet mbrojtese per pune ne lartesi (rripat e sigurise dhe aksesoret)? *',
        '3. A i keni PMI e tjera te veshura (kaska, kepuce, doreza etj)? *',
        '4. Ka nje pike ankorimi (fiksimi) te pershtatshme? *',
        '5. Jane shkallet vertikale te kontrolluara para se te ngjiteni?',
        '6. Ka cante per veglat / ose vend per lidhjen e veglave?',
      ],
    },
    {
      'key': 'act9',
      'number': '9',
      'title': 'Punime ne Hapesira te Kufizuara',
      'hazards':
          'Asfiksim, mbytje nga lengje, zenie nga materiale inerte etj.\nZjarr i mundshem',
      'questions': [
        '3. Eshte personeli qe do te punoj ne hapsire i trajnuar dhe certifikuar?',
        '4. Jane paisje e punes te kontrolluar dhe funksionale?',
        '5. Jane PAISJET INDIVIDUALE MBROJTESE ne dispozicion (perfshire maskat)? *',
        '6. Ka detektor gazi (O2 / H2S / CO) prezent dhe funksional? *',
        '7. Ka person qe ben mbikqyrjen ne hyrje te hapsires? *',
        '8. A keni njohuri per proceduren e hyrjes dhe te emergjences? Jane paisjet e emergjences prezente (tripod, rripa)? *',
        '9. Rrethoni zonen e punes',
      ],
    },
    {
      'key': 'act10',
      'number': '10',
      'title': 'Komunikimi',
      'hazards': 'Konflikte Verbale/Fizike me Klientin',
      'questions': [
        '1. A hasni veshtiresi me komunikimin me klientin (A tregon ai agresivitet, reagon ashper, tregon shenja nervozizmi, eshte ofendues dhe a kerkon konflikt me ju)?',
        '2. A ndiheni te ofenduar/kercenuar kur operoni ne brendesi te objektit, baneses, ambjentit te klientit?',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _submittedAt = _formatDateTime(DateTime.now());
    _loadUserProfile();
    // Initialize activity answers
    for (final act in _activities) {
      final key = act['key'] as String;
      final questions = act['questions'] as List<String>;
      _activityActive[key] = false;
      _activityAnswers[key] = {};
      for (int i = 0; i < questions.length; i++) {
        _activityAnswers[key]!['q$i'] = null;
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await SupabaseService.instance.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUserName = profile?['full_name'] ?? '';
        _currentUserRole = profile?['role'] ?? 'worker';
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final date =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date  $time';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _workOrderController.dispose();
    _suspensionReasonController.dispose();
    for (final c in _employeeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => _selectedPhotos.add(photo));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gabim gjatë zgjedhjes së fotos: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Shto Foto',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                title: Text(
                  'Bëj Foto',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'photo_library',
                      color: AppTheme.secondary,
                      size: 22,
                    ),
                  ),
                ),
                title: Text(
                  'Zgjidh nga Galeria',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a work-stop dialog listing the triggering questions.
  /// Returns true if the user confirms they have notified supervisors and
  /// still wants to proceed with submitting the form (for record-keeping).
  /// Returns false if the user cancels.
  Future<bool> _showWorkStopDialog(List<String> reasons) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.errorColor.withAlpha(120)),
            ),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'block',
                      color: AppTheme.errorColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'NDALO PUNIMET',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.errorColor.withAlpha(80),
                      ),
                    ),
                    child: Text(
                      'Punimet NUK mund të kryhen! Lajmëro menjëherë supervizorët dhe ndalo aktivitetin.',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pyetjet që kërkojnë ndalim:',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurfaceText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...reasons.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomIconWidget(
                            iconName: 'warning',
                            color: AppTheme.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 11,
                                color: AppTheme.onSurfaceText,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warning.withAlpha(80)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'notifications_active',
                          color: AppTheme.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Supervizori i grupit duhet të pezullojë aktivitetin, të bëjë foto, të dërgojë vendndodhjen dhe të lajmërojë drejtuesin.',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              color: AppTheme.onSurfaceText,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Kthehu',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Supervizori u lajmërua — Dërgo',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submitForm() async {
    // ── Work-stop check ──────────────────────────────────────────────────────
    // Sections 1–9 (act1–act9): any "Jo" answer → must stop work
    // Section 10 (act10): any "Po" answer → must stop work
    final List<String> stopReasons = [];

    for (final act in _activities) {
      final key = act['key'] as String;
      if (_activityActive[key] != true) continue;

      final questions = act['questions'] as List<String>;
      final answers = _activityAnswers[key] ?? {};
      final isKomunikimi = key == 'act10';

      for (int i = 0; i < questions.length; i++) {
        final answer = answers['q$i'];
        final shouldStop = isKomunikimi
            ? answer == TriOption.po
            : answer == TriOption.jo;

        if (shouldStop) {
          stopReasons.add('• [${act['title']}] ${questions[i]}');
        }
      }
    }

    if (stopReasons.isNotEmpty) {
      final confirmed = await _showWorkStopDialog(stopReasons);
      if (!confirmed) return; // user cancelled — do not submit
    }
    // ────────────────────────────────────────────────────────────────────────

    setState(() => _isSubmitting = true);

    // Upload photos
    final List<String> photoUrls = [];
    for (final photo in _selectedPhotos) {
      try {
        final bytes = await photo.readAsBytes();
        final url = await SupabaseService.instance.uploadPhoto(
          photo.name,
          bytes,
        );
        if (url != null) photoUrls.add(url);
      } catch (_) {}
    }

    // Build form data
    final activitiesData = <String, dynamic>{};
    for (final act in _activities) {
      final key = act['key'] as String;
      if (_activityActive[key] == true) {
        final answers = _activityAnswers[key] ?? {};
        activitiesData[key] = {
          'active': true,
          'answers': answers.map((k, v) => MapEntry(k, v?.value)),
        };
      }
    }

    final formData = {
      'work_order': _workOrderController.text,
      'work_types': {
        'instalim_ri': _wtInstalimRi,
        'suport': _wtSuport,
        'migrim': _wtMigrim,
        'kulle': _wtKulle,
      },
      'activities': activitiesData,
      'ppe_checklist': {
        'kepuce': _ppeKepuce,
        'helmet': _ppeHelmet,
        'doreza': _ppeDoreza,
        'rroba': _ppeRroba,
        'jelek': _ppeJelek,
        'syze': _ppeSyze,
        'maske': _ppeMaske,
        'rrip': _ppeRrip,
        'mbrojtese': _ppeMbrojtese,
      },
      'employees': _employeeControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .toList(),
      'suspension_reason': _suspensionReasonController.text,
    };

    final error = await SupabaseService.instance.submitForm(
      formData: formData,
      photoUrls: photoUrls,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vlerësimi u dërgua me sukses!',
            style: GoogleFonts.ibmPlexSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() => _isFormSubmitted = true);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gabim: $error',
            style: GoogleFonts.ibmPlexSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 24 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _buildDocHeader(),
                      const SizedBox(height: 12),
                      _buildUserAndDateCard(),
                      const SizedBox(height: 12),
                      _buildWorkTypes(),
                      const SizedBox(height: 12),
                      ..._activities.map(
                        (act) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildActivityCard(act),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildPPESection(),
                      const SizedBox(height: 12),
                      _buildEmployeesSection(),
                      const SizedBox(height: 12),
                      _buildPhotoSection(),
                      const SizedBox(height: 12),
                      _buildSuspensionSection(),
                      const SizedBox(height: 12),
                      _buildWorkOrderSection(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(
        currentIndex: 0,
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.outlineDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'assignment',
                color: Colors.white,
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
                  'SPOT JHA — Vlerësim Risku',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                Text(
                  'Ref: POS_ADCFTTXRAMS-HSM-ST-10001',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildDocHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VLERËSIMI I RISKUT NE VENDIN E PUNËS - SPOT JHA',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Doc.title: Vleresimi I Riskut ne Vendin e Pune_ADCFTTX-HSM-RA-TE-rev03',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariantDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.outlineVariantDark),
            ),
            child: Text(
              'Pas kontrollit të vendoset Po / Jo / N/A sipas rastit.',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: AppTheme.onSurfaceText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAndDateCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(80)),
      ),
      child: Row(
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
                iconName: 'person',
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
                  _currentUserName.isNotEmpty
                      ? _currentUserName
                      : 'Duke ngarkuar...',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Punonjësi',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DATA & ORA:',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _submittedAt,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTypes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PUNA E PLANIFIKUAR?',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceText,
            ),
          ),
          const SizedBox(height: 10),
          _buildWorkTypeCheckbox(
            'Instalim i Ri',
            '(Punime ne lartesi, prane linjave elektrike, brenda klientit)',
            _wtInstalimRi,
            (v) => setState(() => _wtInstalimRi = v),
          ),
          const SizedBox(height: 6),
          _buildWorkTypeCheckbox(
            'Suport',
            '(Punime ne Lartesi ne Shtylle/Fasade/Terrace Objekti)',
            _wtSuport,
            (v) => setState(() => _wtSuport = v),
          ),
          const SizedBox(height: 6),
          _buildWorkTypeCheckbox(
            'Migrim',
            '(Punime ne lartesi, prane linjave elektrike, pusete, brenda klientit)',
            _wtMigrim,
            (v) => setState(() => _wtMigrim = v),
          ),
          const SizedBox(height: 6),
          _buildWorkTypeCheckbox(
            'Punime ne Kulle',
            '(Punime ne lartesi, pusete, terren te hapur, Objekt)',
            _wtKulle,
            (v) => setState(() => _wtKulle = v),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTypeCheckbox(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppTheme.primary,
              side: BorderSide(color: AppTheme.mutedText),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: value ? AppTheme.onSurfaceText : AppTheme.mutedText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
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

  Widget _buildActivityCard(Map<String, dynamic> act) {
    final key = act['key'] as String;
    final isActive = _activityActive[key] ?? false;
    final questions = act['questions'] as List<String>;
    final answers = _activityAnswers[key] ?? {};

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.primary.withAlpha(120)
              : AppTheme.outlineDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _activityActive[key] = !isActive),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary.withAlpha(30)
                    : AppTheme.surfaceVariantDark,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : AppTheme.outlineDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        act['number'] as String,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: isActive,
                                onChanged: (v) => setState(
                                  () => _activityActive[key] = v ?? false,
                                ),
                                activeColor: AppTheme.primary,
                                side: BorderSide(color: AppTheme.mutedText),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                act['title'] as String,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? AppTheme.onSurfaceText
                                      : AppTheme.mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RREZIQET: ${act['hazards']}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: AppTheme.warning,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isActive) ...[
            const Divider(height: 1, color: Color(0xFF2A2D35)),
            // Column headers
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  const Expanded(child: SizedBox()),
                  ...['Po', 'Jo', 'N/A'].map(
                    (label) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          label,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(questions.length, (i) {
              final qKey = 'q$i';
              final current = answers[qKey];
              return _buildQuestionRow(
                questions[i],
                current,
                (val) => setState(() => _activityAnswers[key]![qKey] = val),
              );
            }),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionRow(
    String question,
    TriOption? current,
    Function(TriOption?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.outlineVariantDark, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              question,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: AppTheme.onSurfaceText,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 4),
          ...TriOption.values.map((opt) {
            final isSelected = current == opt;
            Color bgColor;
            Color borderColor;
            Color textColor;
            if (isSelected) {
              switch (opt) {
                case TriOption.po:
                  bgColor = AppTheme.success.withAlpha(40);
                  borderColor = AppTheme.success;
                  textColor = AppTheme.success;
                  break;
                case TriOption.jo:
                  bgColor = AppTheme.errorColor.withAlpha(40);
                  borderColor = AppTheme.errorColor;
                  textColor = AppTheme.errorColor;
                  break;
                case TriOption.na:
                  bgColor = AppTheme.mutedText.withAlpha(40);
                  borderColor = AppTheme.mutedText;
                  textColor = AppTheme.mutedText;
                  break;
              }
            } else {
              bgColor = AppTheme.surfaceVariantDark;
              borderColor = AppTheme.outlineDark;
              textColor = AppTheme.mutedText;
            }
            return SizedBox(
              width: 40,
              child: Center(
                child: GestureDetector(
                  onTap: () => onChanged(isSelected ? null : opt),
                  child: Container(
                    width: 34,
                    height: 26,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        opt.label,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPPESection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAJISJET MBROJTËSE PERSONALE (PPE)',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceText,
            ),
          ),
          const SizedBox(height: 10),
          _buildPPEItem(
            'Kepucet e punes EN ISO 20345:2011',
            _ppeKepuce,
            (v) => setState(() => _ppeKepuce = v),
          ),
          _buildPPEItem(
            'HELMETA EN397 & EN-12492. ANSI/ISEA Z89.1 Type I, Class C',
            _ppeHelmet,
            (v) => setState(() => _ppeHelmet = v),
          ),
          _buildPPEItem(
            'Dorezat e punes EN ISO 21420:2020',
            _ppeDoreza,
            (v) => setState(() => _ppeDoreza = v),
          ),
          _buildPPEItem(
            'Rroba pune',
            _ppeRroba,
            (v) => setState(() => _ppeRroba = v),
          ),
          _buildPPEItem(
            'Jelek fosforishent EN ISO 20471 Class 1',
            _ppeJelek,
            (v) => setState(() => _ppeJelek = v),
          ),
          _buildPPEItem(
            'Syze sigurie EN 166, EN 170',
            _ppeSyze,
            (v) => setState(() => _ppeSyze = v),
          ),
          _buildPPEItem(
            'Maske gazi EN-136:1998',
            _ppeMaske,
            (v) => setState(() => _ppeMaske = v),
          ),
          _buildPPEItem(
            'Rrip sigurimi EN 361-2002 EN358-2018 EN813-2008 EN795.2012-B/C EN12841-2008-C',
            _ppeRrip,
            (v) => setState(() => _ppeRrip = v),
          ),
          _buildPPEItem(
            'Mbrojtese degjimi EN 352-2 SNR 37dB',
            _ppeMbrojtese,
            (v) => setState(() => _ppeMbrojtese = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPPEItem(String label, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppTheme.success,
                side: BorderSide(color: AppTheme.mutedText),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: value ? AppTheme.onSurfaceText : AppTheme.mutedText,
                  fontWeight: value ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Expanded(
                child: Text(
                  'PUNONJËSIT QE DO TË PUNOJNË:',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _employeeControllers.add(TextEditingController());
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.primary,
                  size: 16,
                ),
                label: Text(
                  'Shto',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_employeeControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariantDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.outlineDark),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _employeeControllers[i],
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: AppTheme.onSurfaceText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Emri dhe Mbiemri — Firma',
                        hintStyle: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          color: AppTheme.mutedText,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  if (_employeeControllers.length > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _employeeControllers[i].dispose();
                          _employeeControllers.removeAt(i);
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: 'remove_circle_outline',
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
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
              CustomIconWidget(
                iconName: 'photo_camera',
                color: AppTheme.secondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'FOTO TË VENDNDODHJES',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _showPhotoOptions,
                icon: CustomIconWidget(
                  iconName: 'add_a_photo',
                  color: AppTheme.primary,
                  size: 16,
                ),
                label: Text(
                  'Shto',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedPhotos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Nuk ka foto të shtuara',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
            )
          else ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedPhotos[i].readAsBytes(),
                          builder: (ctx, snap) {
                            if (snap.hasData) {
                              return Image.memory(
                                snap.data!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              width: 90,
                              height: 90,
                              color: AppTheme.surfaceVariantDark,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPhotos.removeAt(i)),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuspensionSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NE KUSHTE KUR PUNIMET NUK MUND TË KRYHEN',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.warningContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Supervizori i grupit pezullon aktivitetin, ben foto, dergon location, lajmeron drejtuesin dhe largohet deri ne marrjen e masave te duhura.',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: AppTheme.onSurfaceText,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'SHKRUAJ ARSYEN PSE:',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _suspensionReasonController,
            maxLines: 3,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              color: AppTheme.onSurfaceText,
            ),
            decoration: InputDecoration(
              hintText: 'Shkruaj arsyen e pezullimit të punimeve...',
              hintStyle: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nr i Urdhërit të Punës',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceText,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _workOrderController,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 15,
              color: AppTheme.onSurfaceText,
            ),
            decoration: InputDecoration(
              hintText: 'p.sh. WO-2026-00842',
              hintStyle: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: AppTheme.mutedText,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'work_outline',
                  color: AppTheme.mutedText,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (_isFormSubmitted) {
      return _buildOpenTicketButton();
    }
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'send',
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Dërgo Vlerësimin',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOpenTicketButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.success.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.success.withAlpha(102)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Formulari u dërgua me sukses! Tani mund të hapni aplikacionin e ticketave.',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: AppTheme.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _openTicketApp,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'open_in_new',
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Hap Aplikacionin e Ticketave',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.submissionHistoryScreen,
              (r) => false,
            );
          },
          child: Text(
            'Kthehu tek Historia',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openTicketApp() async {
    // Deep-link URL for the ticket application
    // Uses a generic intent/URL scheme — update the scheme to match the actual ticket app
    const String ticketAppUrl = String.fromEnvironment(
      'TICKET_APP_URL',
      defaultValue: 'https://adcrisk5177.builtwithrocket.new',
    );
    final Uri uri = Uri.parse(ticketAppUrl);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nuk mund të hapej aplikacioni i ticketave.',
              style: GoogleFonts.ibmPlexSans(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nuk mund të hapej aplikacioni i ticketave.',
              style: GoogleFonts.ibmPlexSans(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
