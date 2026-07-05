import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import '../models/category_model.dart';
import 'category_remote_datasource.dart';

@LazySingleton(as: CategoryRemoteDataSource)
class FirestoreCategoryDataSource implements CategoryRemoteDataSource {
  final FirebaseFirestore _db;

  FirestoreCategoryDataSource(this._db);

  /// Nested under `environments/{flavor}` so dev/staging/prod never share
  /// documents in the same Firebase project.
  CollectionReference<Map<String, dynamic>> _col(String userId) => _db
      .collection('environments')
      .doc(FlavorConfig.instance.name)
      .collection('users')
      .doc(userId)
      .collection('categories');

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    final snapshot = await _col(userId).get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> createCategory(String userId, CategoryModel category) async {
    await _col(userId).doc(category.id).set(category.toMap());
  }

  @override
  Future<void> updateCategory(String userid, CategoryModel category) async {
    await _col(
      userid,
    ).doc(category.id).set(category.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteCategory(String userId, String id) async {
    await _col(userId).doc(id).delete();
  }

  @override
  Future<void> uploadAll(
    String userId,
    List<CategoryModel> categories,
  ) async {
    final batch = _db.batch();
    for (final c in categories) {
      batch.set(_col(userId).doc(c.id), c.toMap());
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
