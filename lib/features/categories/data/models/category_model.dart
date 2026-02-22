import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:hive_ce/hive_ce.dart';
part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends Category {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  String get icon => super.icon;

  @HiveField(3)
  @override
  int get color => super.color;

  @HiveField(4)
  @override
  String get type => super.type;

  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
    );
  }

  Category toEntity() {
    return Category(id: id, name: name, icon: icon, color: color, type: type);
  }
}
