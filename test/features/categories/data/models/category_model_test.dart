import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCategoryModel = CategoryModel(
    id: '1',
    name: 'Food',
    icon: 'food_icon',
    color: 123,
    type: 'expense',
  );

  const tCategory = Category(
    id: '1',
    name: 'Food',
    icon: 'food_icon',
    color: 123,
    type: 'expense',
  );

  group('CategoryModel', () {
    test('should be a subclass of Category entity', () {
      expect(tCategoryModel, isA<Category>());
    });

    group('fromEntity', () {
      test('should return a valid model from entity', () {
        final result = CategoryModel.fromEntity(tCategory);
        expect(result, tCategoryModel);
      });
    });

    group('toEntity', () {
      test('should return a valid entity from model', () {
        final result = tCategoryModel.toEntity();
        expect(result, tCategory);
      });
    });
  });
}
