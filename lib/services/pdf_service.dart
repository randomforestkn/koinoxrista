import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../models/result_row.dart';

Future<Uint8List> generatePdfWithResults(List<ResultRow> results) async {
  // 🔠 Φόρτωση της γραμματοσειράς Roboto από τα assets
  final roboto = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );

  final pdf = pw.Document();

  // Δημιουργία γραμμών δεδομένων
  final List<List<String>> rows = results.map((r) => [
    r.apartment.id.toString(),
    r.apartment.area.toStringAsFixed(0),
    (r.mills * 1000).toStringAsFixed(1),
    r.shareFixed.toStringAsFixed(2),
    r.shareExtra.toStringAsFixed(2),
    r.shareElevator.toStringAsFixed(2),
    r.shareHeating.toStringAsFixed(2),
    r.total.toStringAsFixed(2),
  ]).toList();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Πίνακας Κατανομής',
              style: pw.TextStyle(font: roboto, fontSize: 18),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['#', 'm²', '‰', 'Πάγια', 'Έκτακτα', 'Ανελκ.', 'Θέρμ.', 'Σύνολο'],
              data: rows,
              cellStyle: pw.TextStyle(font: roboto, fontSize: 10),
              headerStyle: pw.TextStyle(
                font: roboto,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.centerRight,
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
