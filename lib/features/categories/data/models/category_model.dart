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

  @HiveField(5)
  @override
  DateTime get updatedAt => super.updatedAt;

  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    required super.updatedAt,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
      updatedAt: category.updatedAt,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as int,
      type: map['type'] as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
