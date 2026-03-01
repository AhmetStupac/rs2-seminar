import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:personaltrainer_desktop/models/dashboard_report.dart';
import 'package:personaltrainer_desktop/models/trainer_dashboard.dart';

class PdfReportService {
  // ─── SuperAdmin Platform Report ─────────────────────────────────────────────

  static Future<void> downloadSuperAdminReport(DashboardReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _buildHeader('Platform Statistics Report'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          _buildGeneratedDate(),
          pw.SizedBox(height: 24),

          // Summary cards
          _buildSectionTitle('Platform Overview'),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _buildStatBox('Personal Trainers', report.totalPersonalTrainers.toString(), PdfColors.blue700),
            pw.SizedBox(width: 12),
            _buildStatBox('Registered Users', report.totalUsers.toString(), PdfColors.green700),
            pw.SizedBox(width: 12),
            _buildStatBox('Gyms', report.totalGyms.toString(), PdfColors.orange700),
          ]),

          pw.SizedBox(height: 28),

          // Top trainers table
          _buildSectionTitle('Top Rated Trainers'),
          pw.SizedBox(height: 12),
          if (report.topTrainers.isEmpty)
            pw.Text('No rated trainers yet.', style: pw.TextStyle(color: PdfColors.grey600))
          else
            _buildTopTrainersTable(report.topTrainers),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'platform_statistics_report.pdf',
    );
  }

  // ─── Trainer Personal Report ─────────────────────────────────────────────────

  static Future<void> downloadTrainerReport(TrainerDashboard d) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _buildHeader('Trainer Performance Report'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          _buildGeneratedDate(),
          pw.SizedBox(height: 8),

          // Trainer name
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.teal200),
            ),
            child: pw.Row(children: [
              pw.Text('Trainer: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.Text(d.trainerFullName, style: const pw.TextStyle(fontSize: 13)),
              pw.Spacer(),
              pw.Text('Total Clients: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.Text(d.totalClients.toString(), style: const pw.TextStyle(fontSize: 13)),
            ]),
          ),

          pw.SizedBox(height: 24),

          // Revenue
          _buildSectionTitle('Revenue'),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.green200),
            ),
            child: pw.Row(children: [
              pw.Text('Total Earned:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.SizedBox(width: 8),
              pw.Text('€${d.totalEarnedEur.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
            ]),
          ),

          pw.SizedBox(height: 24),

          // Sales breakdown
          _buildSectionTitle('Sales Breakdown'),
          pw.SizedBox(height: 10),
          pw.Row(children: [
            _buildStatBox('Training Plans\nSold', d.soldTrainingPlans.toString(), PdfColors.blue700),
            pw.SizedBox(width: 12),
            _buildStatBox('Nutrition Plans\nSold', d.soldNutritionPlans.toString(), PdfColors.purple700),
            pw.SizedBox(width: 12),
            _buildStatBox('Memberships\nSold', d.soldMemberships.toString(), PdfColors.teal700),
          ]),

          pw.SizedBox(height: 24),

          // Plans created
          _buildSectionTitle('Plans Created'),
          pw.SizedBox(height: 10),
          pw.Row(children: [
            _buildStatBox('Training Plans\nCreated', d.totalTrainingPlansCreated.toString(), PdfColors.orange700),
            pw.SizedBox(width: 12),
            _buildStatBox('Nutrition Plans\nCreated', d.totalNutritionPlansCreated.toString(), PdfColors.deepOrange700),
          ]),

          pw.SizedBox(height: 24),

          // Rating
          _buildSectionTitle('Rating'),
          pw.SizedBox(height: 10),
          _buildRatingBox(d.averageRating, d.ratingCount),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'trainer_report_${d.trainerFullName.replaceAll(' ', '_')}.pdf',
    );
  }

  // ─── Shared helpers ──────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
          ),
          pw.Text(
            'Personal Trainer App',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Confidential', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  static pw.Widget _buildGeneratedDate() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return pw.Text(
      'Generated: $d.$m.${now.year} $h:$min',
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 0.8),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 4),
            pw.Text(label,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTopTrainersTable(List<TopTrainerReportItem> trainers) {
    const medals = ['🥇 1st', '🥈 2nd', '🥉 3rd'];
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('Rank', bold: true),
            _tableCell('Trainer', bold: true),
            _tableCell('Avg Rating', bold: true),
            _tableCell('Reviews', bold: true),
          ],
        ),
        ...trainers.asMap().entries.map((e) {
          final rank = e.key < medals.length ? medals[e.key] : '#${e.key + 1}';
          final t = e.value;
          return pw.TableRow(children: [
            _tableCell(rank),
            _tableCell(t.trainerFullName),
            _tableCell(t.averageRating.toStringAsFixed(1)),
            _tableCell(t.ratingCount.toString()),
          ]);
        }),
      ],
    );
  }

  static pw.Widget _buildRatingBox(double rating, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.amber200),
      ),
      child: pw.Row(children: [
        pw.Text(
          rating.toStringAsFixed(1),
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800),
        ),
        pw.Text(' / 5', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey600)),
        pw.SizedBox(width: 16),
        pw.Text('based on $count review${count == 1 ? '' : 's'}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ]),
    );
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: bold
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)
            : const pw.TextStyle(fontSize: 11),
      ),
    );
  }
}
