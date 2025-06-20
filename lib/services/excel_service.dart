import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/result_row.dart';

class ExcelService {
  Uint8List buildXlsx(List<ResultRow> rows) {
    final excel = Excel.createExcel();
    final sheet = excel['Κατανομή'];

    sheet.appendRow(
      ['#','m²','‰','Πάγια','Έκτακτα','Ανελκ.','Θέρμ.','Σύνολο'],
    );

    for (final r in rows) {
      sheet.appendRow([
        r.apartment.id,
        r.apartment.area,
        (r.mills*1000),
        r.shareFixed,
        r.shareExtra,
        r.shareElevator,
        r.shareHeating,
        r.total,
      ]);
    }

    sheet.appendRow([]);
    sheet.appendRow([
      '',
      '',
      '',
      '',
      '',
      '',
      'Σύνολο',
      rows.fold<double>(0,(s,r)=>s+r.total)
    ]);

    return Uint8List.fromList(excel.encode()!);
  }
}
