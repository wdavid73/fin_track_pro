import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import '../models/transaction_model.dart';
import 'transaction_remote_datasource.dart';

@LazySingleton(as: TransactionRemoteDataSource)
class FirestoreTransactionDataSource implements TransactionRemoteDataSource {
  final FirebaseFirestore _db;

  FirestoreTransactionDataSource(this._db);

  /// Nested under `environments/{flavor}` so dev/staging/prod never share
  /// documents in the same Firebase project.
  CollectionReference<Map<String, dynamic>> _col(String userId) => _db
      .collection('environments')
      .doc(FlavorConfig.instance.name)
      .collection('users')
      .doc(userId)
      .collection('transactions');

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final snapshot = await _col(userId).get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> createTransaction(
    String userId,
    TransactionModel transaction,
  ) async {
    await _col(userId).doc(transaction.id).set(transaction.toMap());
  }

  @override
  Future<void> updateTransaction(
    String userId,
    TransactionModel transaction,
  ) async {
    await _col(
      userId,
    ).doc(transaction.id).set(transaction.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTransaction(String userId, String id) async {
    await _col(userId).doc(id).delete();
  }

  @override
  Future<void> uploadAll(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    final batch = _db.batch();
    for (final t in transactions) {
      batch.set(_col(userId).doc(t.id), t.toMap());
    }
    await batch.commit();
  }

  @override
  Future<void> deleteAll(String userId) async {
    final snapshot = await _col(userId).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
