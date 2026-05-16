import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' show DateTimeRange;

class PdfService {
  static PdfService? _instance;
  static PdfService get instance => _instance ??= PdfService._();
  PdfService._();

  // ─── Color palette matching app theme ─────────────────────────────────────
  static const _primary = PdfColor.fromInt(0xFF2979FF);
  static const _success = PdfColor.fromInt(0xFF00C853);
  static const _error = PdfColor.fromInt(0xFFFF5252);
  static const _warning = PdfColor.fromInt(0xFFFFAB40);
  static const _bg = PdfColor.fromInt(0xFF0D1117);
  static const _surface = PdfColor.fromInt(0xFF161B22);
  static const _surfaceVariant = PdfColor.fromInt(0xFF1C2333);
  static const _onSurface = PdfColor.fromInt(0xFFE6EDF3);
  static const _muted = PdfColor.fromInt(0xFF8B949E);
  static const _outline = PdfColor.fromInt(0xFF30363D);

  static const _actTitles = {
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

  static const _ppeLabels = {
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

  static const _actQuestions = <String, List<String>>{
    'act1': [
      '1. A jeni te informuar per ndalimin e punimeve jashte nen kushte atmosferike te papershtatshme?',
      '2. A jane kushtet atmosferike te pershtatshme per nje pune te sigurte?',
    ],
    'act2': [
      '1. A eshte kontrolluar mjeti i punes?',
      '2. A eshte personeli i autorizuar qe te drejtoj mjetin?',
      '3. A eshte mjeti i pajisur me fikse zjarri/kuti te ndihmes se pare?',
      '4. A eshte stafi i trajnuar mbi Drejtimin e Sigurte?',
    ],
    'act3': [
      '1. A eshte shkalle standart EN 131, e kontrolluar dhe pa difekte?',
      '2. A jeni te trajnuar per punime te sigurta mbi shkalle?',
      '3. A jane te pajisur me shkalle dielektrike dhe pajisje mbrojtese?',
      '4. A eshte kontrolluar vendi i punes te jete i sigurte?',
      '5. A eshte i rrethuar vendi i punes me sinjalistiken e duhur?',
    ],
    'act4': [
      '1. A jeni autorizuar dhe trajnuar per pune me paisje elektrike?',
      '2. A eshte shkeputur paisja nga tensioni?',
      '3. A keni veshur PPE qe ju mbrojne nga renia ne kontakt me rrymen?',
      '4. A keni dijeni mbi proceduren per pune me paisejet elektrike?',
      '5. A ka tokezim paisja / Instalimi elektrik?',
      '6. A jane te kontrolluara pajisjet qe perdorni?',
      '7. A i keni detektuesin e tensionit pa prekje?',
      '8. A dispononi fikse zjarri / kuti e ndihmes se shpejte?',
    ],
    'act5': [
      '1. A jeni trajnuar per pune afer inst & paisjeve elektrike?',
      '2. A jeni te pajisur me PMI?',
      '3. A eshte distanca nga linja elektrike e sigurte?',
      '4. A dispononi shkallet jopercjellese te standartit EN 131?',
      '5. I keni detektoret e prezences se tensionit?',
    ],
    'act6': [
      '1. A mund te kryhet puna e sigurte?',
      '2. A punohet ne grup minimumi 2 ose me shume punetor?',
      '3. A jane marre masa nese nuk ka mbrojtje per reniet nga lartesia?',
      '4. Eshte rrethuar puseta e hapur?',
      '5. A keni kryer testimet e duhura?',
    ],
    'act7': [
      '1. A jeni te trajnuar per ngritjen manuale?',
      '2. Ngritja te behet me dy ose me shume punetore kur pesha i kalon 25kg?',
      '3. Ka paisje te pershtatshme per ngritjen e kapakeve?',
    ],
    'act8': [
      '1. A eshte i trajnuar dhe certifikuar personeli?',
      '2. A i keni kontrolluar pajisjet mbrojtese?',
      '3. A i keni PMI e tjera te veshura?',
      '4. Ka nje pike ankorimi te pershtatshme?',
      '5. Jane shkallet vertikale te kontrolluara?',
      '6. Ka cante per veglat?',
    ],
    'act9': [
      '3. Eshte personeli i trajnuar dhe certifikuar?',
      '4. Jane paisje e punes te kontrolluar?',
      '5. Jane PAISJET INDIVIDUALE MBROJTESE ne dispozicion?',
      '6. Ka detektor gazi prezent dhe funksional?',
      '7. Ka person qe ben mbikqyrjen ne hyrje?',
      '8. A keni njohuri per proceduren e hyrjes dhe te emergjences?',
      '9. Rrethoni zonen e punes',
    ],
    'act10': [
      '1. A hasni veshtiresi me komunikimin me klientin?',
      '2. A ndiheni te ofenduar/kercenuar kur operoni ne brendesi te objektit?',
    ],
  };

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> generateAndShareReport({
    required List<Map<String, dynamic>> submissions,
    required DateTimeRange dateRange,
    required String riskFilter,
    required String employeeFilter,
  }) async {
    final pdf = await _buildReportPdf(
      submissions: submissions,
      dateRange: dateRange,
      riskFilter: riskFilter,
      employeeFilter: employeeFilter,
    );
    await Printing.sharePdf(
      bytes: pdf,
      filename:
          'raport_${_fileDate(dateRange.start)}_${_fileDate(dateRange.end)}.pdf',
    );
  }

  Future<void> generateAndShareForm(Map<String, dynamic> submission) async {
    final pdf = await _buildFormPdf(submission);
    final workOrder = (submission['work_order'] ?? 'forme')
        .toString()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    await Printing.sharePdf(bytes: pdf, filename: 'forme_$workOrder.pdf');
  }

  // ─── Report PDF builder ────────────────────────────────────────────────────

  Future<Uint8List> _buildReportPdf({
    required List<Map<String, dynamic>> submissions,
    required DateTimeRange dateRange,
    required String riskFilter,
    required String employeeFilter,
  }) async {
    final pdf = pw.Document();

    final total = submissions.length;
    final suspended = submissions.where((s) {
      final r = s['suspension_reason'] ?? '';
      return r.toString().isNotEmpty && r.toString() != 'null';
    }).length;
    final proceed = total - suspended;
    final proceedPct = total > 0 ? (proceed / total * 100).round() : 0;
    final highRiskPct = total > 0 ? (suspended / total * 100).round() : 0;
    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    final avgPerDay = total > 0 ? (total / days).toStringAsFixed(1) : '0';

    final Map<String, int> workerMap = {};
    for (final s in submissions) {
      final name = (s['submitter_name'] ?? 'I panjohur').toString();
      workerMap[name] = (workerMap[name] ?? 0) + 1;
    }
    final sortedWorkers = workerMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, int> dayCount = {};
    final trendDays = <DateTime>[];
    for (int i = 6; i >= 0; i--) {
      final d = dateRange.end.subtract(Duration(days: i));
      if (!d.isBefore(dateRange.start)) {
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        dayCount[key] = 0;
        trendDays.add(d);
      }
    }
    for (final s in submissions) {
      try {
        final dt = DateTime.parse(s['submitted_at'] ?? '').toLocal();
        final key =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        if (dayCount.containsKey(key)) dayCount[key] = (dayCount[key] ?? 0) + 1;
      } catch (_) {}
    }
    final maxTrend = dayCount.values.fold(0, (a, b) => a > b ? a : b);

    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
          buildBackground: (context) =>
              pw.FullPage(ignoreMargins: true, child: pw.Container(color: _bg)),
        ),
        build: (context) => [
          _buildReportHeader(dateRange, riskFilter, employeeFilter),
          pw.SizedBox(height: 20),
          _buildKpiRow(
            total,
            proceed,
            suspended,
            proceedPct,
            highRiskPct,
            avgPerDay,
          ),
          pw.SizedBox(height: 20),
          if (trendDays.isNotEmpty) ...[
            _buildSectionTitle('Trendi i Dorëzimeve (7 Ditët e Fundit)'),
            pw.SizedBox(height: 10),
            _buildTrendChart(trendDays, dayCount, maxTrend),
            pw.SizedBox(height: 20),
          ],
          if (sortedWorkers.isNotEmpty) ...[
            _buildSectionTitle('Performanca e Punonjësve'),
            pw.SizedBox(height: 10),
            _buildWorkerTable(sortedWorkers, total),
            pw.SizedBox(height: 20),
          ],
          if (submissions.isNotEmpty) ...[
            _buildSectionTitle('Lista e Dorëzimeve (${submissions.length})'),
            pw.SizedBox(height: 10),
            _buildSubmissionTable(submissions),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Individual form PDF builder ───────────────────────────────────────────

  Future<Uint8List> _buildFormPdf(Map<String, dynamic> submission) async {
    final pdf = pw.Document();

    final submitterName = submission['submitter_name'] ?? '—';
    final workOrder = submission['work_order'] ?? '—';
    final submittedAt = _formatDateTime(submission['submitted_at']);
    final workTypes = submission['work_types'] as Map<String, dynamic>? ?? {};
    final activities = submission['activities'] as Map<String, dynamic>? ?? {};
    final ppeChecklist =
        submission['ppe_checklist'] as Map<String, dynamic>? ?? {};
    final employees =
        (submission['employees'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    final suspensionReason = (submission['suspension_reason'] ?? '').toString();

    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
          buildBackground: (context) =>
              pw.FullPage(ignoreMargins: true, child: pw.Container(color: _bg)),
        ),
        build: (context) => [
          _buildFormHeader(
            submitterName.toString(),
            workOrder.toString(),
            submittedAt,
          ),
          pw.SizedBox(height: 16),
          _buildFormSectionTitle('PUNA E PLANIFIKUAR'),
          pw.SizedBox(height: 8),
          _buildWorkTypesSection(workTypes),
          pw.SizedBox(height: 16),
          if (activities.isNotEmpty) ...[
            _buildFormSectionTitle('AKTIVITETET'),
            pw.SizedBox(height: 8),
            _buildActivitiesSection(activities),
            pw.SizedBox(height: 16),
          ],
          _buildFormSectionTitle('PPE — PAJISJET MBROJTËSE'),
          pw.SizedBox(height: 8),
          _buildPpeSection(ppeChecklist),
          pw.SizedBox(height: 16),
          if (employees.isNotEmpty) ...[
            _buildFormSectionTitle('PUNONJËSIT'),
            pw.SizedBox(height: 8),
            _buildEmployeesSection(employees),
            pw.SizedBox(height: 16),
          ],
          if (suspensionReason.isNotEmpty && suspensionReason != 'null') ...[
            _buildFormSectionTitle('ARSYEJA E PEZULLIMIT', color: _warning),
            pw.SizedBox(height: 8),
            _buildSuspensionSection(suspensionReason),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Report PDF widgets ────────────────────────────────────────────────────

  pw.Widget _buildReportHeader(
    DateTimeRange dateRange,
    String riskFilter,
    String employeeFilter,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: _primary, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'ADC Risk — Raport i Dorëzimeve',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _onSurface,
                ),
              ),
              pw.Text(
                _fmtDate(DateTime.now()),
                style: pw.TextStyle(fontSize: 11, color: _muted),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _chip(
                'Periudha: ${_fmtDate(dateRange.start)} — ${_fmtDate(dateRange.end)}',
                _primary,
              ),
              _chip('Rreziku: $riskFilter', _warning),
              _chip('Punonjësi: $employeeFilter', _success),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildKpiRow(
    int total,
    int proceed,
    int suspended,
    int proceedPct,
    int highRiskPct,
    String avgPerDay,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(child: _kpiTile('Gjithsej', total.toString(), _primary)),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _kpiTile('Proceed', proceed.toString(), _success)),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _kpiTile('No Proceed', suspended.toString(), _error),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _kpiTile('% Proceed', '$proceedPct%', _success)),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _kpiTile('Rrezik i Lartë', '$highRiskPct%', _warning),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _kpiTile('Mes./Ditë', avgPerDay, _primary)),
      ],
    );
  }

  pw.Widget _kpiTile(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _surfaceVariant,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: color, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(label, style: pw.TextStyle(fontSize: 8, color: _muted)),
        ],
      ),
    );
  }

  pw.Widget _buildTrendChart(
    List<DateTime> days,
    Map<String, int> dayCount,
    int maxVal,
  ) {
    final barMax = maxVal < 1 ? 1 : maxVal;
    const chartHeight = 80.0;
    const barWidth = 20.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _outline),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: days.map((d) {
          final key =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          final count = dayCount[key] ?? 0;
          final barH = (count / barMax) * chartHeight;
          final label =
              '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                count.toString(),
                style: pw.TextStyle(fontSize: 8, color: _primary),
              ),
              pw.SizedBox(height: 2),
              pw.Container(
                width: barWidth,
                height: barH < 4 ? 4 : barH,
                decoration: const pw.BoxDecoration(
                  color: _primary,
                  borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(3),
                    topRight: pw.Radius.circular(3),
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(label, style: pw.TextStyle(fontSize: 7, color: _muted)),
            ],
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildWorkerTable(List<MapEntry<String, int>> workers, int total) {
    final maxCount = workers.isNotEmpty ? workers.first.value : 1;
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _outline),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const pw.BoxDecoration(
              color: _surfaceVariant,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(10),
                topRight: pw.Radius.circular(10),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Punonjësi',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Dorëzime',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '%',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Bari',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...workers.take(10).map((e) {
            final pct = total > 0 ? (e.value / total * 100).round() : 0;
            final barFrac = maxCount > 0 ? e.value / maxCount : 0.0;
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: _outline, width: 0.5),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      e.key,
                      style: pw.TextStyle(fontSize: 10, color: _onSurface),
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      e.value.toString(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '$pct%',
                      style: pw.TextStyle(fontSize: 10, color: _muted),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Stack(
                      children: [
                        pw.Container(
                          height: 8,
                          decoration: const pw.BoxDecoration(
                            color: _surfaceVariant,
                            borderRadius: pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                        ),
                        pw.Container(
                          width: (barFrac * double.infinity).isNaN ? 0 : null,
                          constraints: pw.BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          height: 8,
                          decoration: const pw.BoxDecoration(
                            color: _primary,
                            borderRadius: pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
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

  pw.Widget _buildSubmissionTable(List<Map<String, dynamic>> submissions) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _outline),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const pw.BoxDecoration(
              color: _surfaceVariant,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(10),
                topRight: pw.Radius.circular(10),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Punonjësi',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Urdhëri',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Data',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Statusi',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...submissions.take(50).map((s) {
            final name = (s['submitter_name'] ?? '—').toString();
            final order = (s['work_order'] ?? '—').toString();
            final date = _formatDateTime(s['submitted_at']);
            final hasSuspension =
                (s['suspension_reason'] ?? '').toString().isNotEmpty &&
                (s['suspension_reason'] ?? '').toString() != 'null';
            final statusColor = hasSuspension ? _error : _success;
            final statusText = hasSuspension ? 'No Proceed' : 'Proceed';
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: _outline, width: 0.5),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      name,
                      style: pw.TextStyle(fontSize: 9, color: _onSurface),
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      order,
                      style: pw.TextStyle(fontSize: 9, color: _muted),
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      date,
                      style: pw.TextStyle(fontSize: 9, color: _muted),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: statusColor,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        statusText,
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
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
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Row(
      children: [
        pw.Container(width: 3, height: 16, color: _primary),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  // ─── Form PDF widgets ──────────────────────────────────────────────────────

  pw.Widget _buildFormHeader(
    String name,
    String workOrder,
    String submittedAt,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: _primary, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ADC Risk — Formulari i Vlerësimit të Rrezikut',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _onSurface,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(child: _formInfoRow('Punonjësi', name)),
              pw.Expanded(child: _formInfoRow('Nr. Urdhëri', workOrder)),
            ],
          ),
          pw.SizedBox(height: 6),
          _formInfoRow('Data & Ora', submittedAt),
        ],
      ),
    );
  }

  pw.Widget _formInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$label: ', style: pw.TextStyle(fontSize: 10, color: _muted)),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _onSurface,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFormSectionTitle(String title, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _surfaceVariant,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: color ?? _primary, width: 0.5),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: color ?? _primary,
        ),
      ),
    );
  }

  pw.Widget _buildWorkTypesSection(Map<String, dynamic> workTypes) {
    final selected = <String>[];
    if (workTypes['instalim_ri'] == true) selected.add('Instalim i Ri');
    if (workTypes['suport'] == true) selected.add('Suport');
    if (workTypes['migrim'] == true) selected.add('Migrim');
    if (workTypes['kulle'] == true) selected.add('Punime ne Kulle');

    if (selected.isEmpty) {
      return pw.Text(
        'Asnjë lloj pune i zgjedhur',
        style: pw.TextStyle(fontSize: 10, color: _muted),
      );
    }
    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: selected.map((s) => _chip(s, _primary)).toList(),
    );
  }

  pw.Widget _buildActivitiesSection(Map<String, dynamic> activities) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: activities.entries.map((entry) {
        final actKey = entry.key;
        final actData = entry.value as Map<String, dynamic>? ?? {};
        final answers = actData['answers'] as Map<String, dynamic>? ?? {};
        final title = _actTitles[actKey] ?? actKey;
        final questions = _actQuestions[actKey] ?? [];

        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _surfaceVariant,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                  border: pw.Border.all(color: _primary, width: 0.5),
                ),
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              ...answers.entries.map((ans) {
                final val = ans.value?.toString() ?? '—';
                final qIndex = int.tryParse(ans.key.replaceAll('q', '')) ?? -1;
                final questionText = (qIndex >= 0 && qIndex < questions.length)
                    ? questions[qIndex]
                    : 'Pyetja ${qIndex + 1}';
                final valColor = val == 'Po'
                    ? _success
                    : (val == 'Jo' ? _error : _muted);
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          questionText,
                          style: pw.TextStyle(fontSize: 9, color: _muted),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          color: valColor,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(3),
                          ),
                        ),
                        child: pw.Text(
                          val,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
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
    );
  }

  pw.Widget _buildPpeSection(Map<String, dynamic> ppe) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _ppeLabels.entries.map((e) {
        final checked = ppe[e.key] == true;
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: _surfaceVariant,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            border: pw.Border.all(
              color: checked ? _success : _outline,
              width: 0.5,
            ),
          ),
          child: pw.Text(
            '${checked ? '✓' : '✗'} ${e.value}',
            style: pw.TextStyle(
              fontSize: 9,
              color: checked ? _success : _muted,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildEmployeesSection(List<String> employees) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: employees
          .asMap()
          .entries
          .map(
            (e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 20,
                    height: 20,
                    decoration: const pw.BoxDecoration(
                      color: _surfaceVariant,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${e.key + 1}',
                        style: pw.TextStyle(fontSize: 9, color: _muted),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    e.value,
                    style: pw.TextStyle(fontSize: 10, color: _onSurface),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildSuspensionSection(String reason) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _surfaceVariant,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _warning, width: 0.5),
      ),
      child: pw.Text(
        reason,
        style: pw.TextStyle(fontSize: 10, color: _onSurface),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  pw.Widget _chip(String label, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: _surfaceVariant,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: color, width: 0.5),
      ),
      child: pw.Text(label, style: pw.TextStyle(fontSize: 9, color: color)),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _fileDate(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';

  String _formatDateTime(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
