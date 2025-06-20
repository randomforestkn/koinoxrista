import 'package:flutter/material.dart';
import '../../../models/result_row.dart';
import 'dart:convert';
import 'package:hive/hive.dart';

import '../../../models/building.dart';

import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


import '../../../services/pdf_service.dart';
import '../../../services/excel_service.dart';



class ResultPage extends StatelessWidget {
  final List<ResultRow> results;
  const ResultPage({super.key, required this.results});

  double get _totalBuilding => results.fold(0, (s, r) => s + r.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Πίνακας Κατανομής')),
      body: Column(
        children: [
          Expanded(child: _dataTable()),
          _footer(context),
        ],
      ),
    );
  }

  Widget _dataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('m²')),
          DataColumn(label: Text('‰')),
          DataColumn(label: Text('Πάγια')),
          DataColumn(label: Text('Έκτακτα')),
          DataColumn(label: Text('Ανελκ.')),
          DataColumn(label: Text('Θέρμ.')),
          DataColumn(label: Text('Σύνολο')),
        ],
        rows: [
          for (final r in results)
            DataRow(cells: [
              DataCell(Text(r.apartment.id.toString())),
              DataCell(Text(r.apartment.area.toStringAsFixed(0))),
              DataCell(Text((r.mills * 1000).toStringAsFixed(1))),
              DataCell(Text(r.shareFixed.toStringAsFixed(2))),
              DataCell(Text(r.shareExtra.toStringAsFixed(2))),
              DataCell(Text(r.shareElevator.toStringAsFixed(2))),
              DataCell(Text(r.shareHeating.toStringAsFixed(2))),
              DataCell(Text(r.total.toStringAsFixed(2))),
            ]),
        ],
      ),
    );
  }


Widget _footer(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal:16),
      child: Row(
        children:[
          Text('Σύνολο πολυκατοικίας: ',
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text('${_totalBuilding.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight:FontWeight.bold)),
          const SizedBox(width:16),
          FilledButton.icon(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Export PDF'),
            onPressed: () async {
              final bytes = await generatePdfWithResults(results);
              await Printing.sharePdf(bytes: bytes, filename: 'koinoxrista.pdf');
            },
          ),
          const SizedBox(width:8),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.table_view_outlined),
            label: const Text('Export Excel'),
            onPressed: () async {
              final Uint8List xlsx = ExcelService().buildXlsx(results);

              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/koinoxrista.xlsx');
              await file.writeAsBytes(xlsx, flush: true);

              await Share.shareXFiles([XFile(file.path)], text: 'Πίνακας κοινοχρήστων');
            },
          ),
        ],
      ),
    );
  }
}



