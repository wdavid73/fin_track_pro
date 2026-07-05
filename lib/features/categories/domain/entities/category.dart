import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String type; // 'income' or 'expense'
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type, updatedAt];

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    String? type,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type)';
  }
}
