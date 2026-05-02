import 'dart:io';


import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@lazySingleton
class ExportTransactionsCsv {
  final TransactionRepository repository;

  ExportTransactionsCsv(this.repository);

  Future<void> call() async {
    final transactions = await repository.getTransactions();

    final List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'ID',
      'Amount',
      'Type',
      'Date',
      'Category ID',
      'Note'
    ]);

    // Data
    for (final t in transactions) {
      rows.add([
        t.id,
        t.amount,
        t.type,
        DateFormat('yyyy-MM-dd HH:mm').format(t.date),
        t.categoryId,
        t.note ?? '',
      ]);
    }

    final StringBuffer sb = StringBuffer();
    for (final row in rows) {
      final String rowString = row.map((e) {
        final String str = e.toString().replaceAll('"', '""');
        return '"$str"';
      }).join(',');
      sb.writeln(rowString);
    }
    final String csvData = sb.toString();

    final directory = await getTemporaryDirectory();
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String filePath = '${directory.path}/transactions_$timestamp.csv';

    final File file = File(filePath);
    await file.writeAsString(csvData);

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(filePath)], text: 'Exported Transactions CSV');
  }
}
