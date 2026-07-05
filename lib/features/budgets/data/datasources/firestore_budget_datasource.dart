import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import '../models/budget_model.dart';
import 'budget_remote_datasource.dart';

@LazySingleton(as: BudgetRemoteDataSource)
class FirestoreBudgetDataSource implements BudgetRemoteDataSource {
  final FirebaseFirestore _db;

  FirestoreBudgetDataSource(this._db);

  /// Nested under `environments/{flavor}` so dev/staging/prod never share
  /// documents in the same Firebase project.
  CollectionReference<Map<String, dynamic>> _col(String userId) => _db
      .collection('environments')
      .doc(FlavorConfig.instance.name)
      .collection('users')
      .doc(userId)
      .collection('budgets');

  @override
  Future<List<BudgetModel>> getBudgets(String userId) async {
    final snapshot = await _col(userId).get();
    return snapshot.docs.map((doc) => BudgetModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> saveBudget(String userId, BudgetModel budget) async {
    await _col(
      userId,
    ).doc(budget.id).set(budget.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteBudget(String userId, String id) async {
    await _col(userId).doc(id).delete();
  }

  @override
  Future<void> uploadAll(String userId, List<BudgetModel> budgets) async {
    final batch = _db.batch();
    for (final b in budgets) {
      batch.set(_col(userId).doc(b.id), b.toMap());
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
