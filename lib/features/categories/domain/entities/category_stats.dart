import 'package:equatable/equatable.dart';
import 'category.dart';

class CategoryStats extends Equatable {
  final Category category;
  final int transactionCount;
  final double totalAmount;

  const CategoryStats({
    required this.category,
    required this.transactionCount,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [category, transactionCount, totalAmount];

  @override
  String toString() {
    return 'CategoryStats(category: ${category.name}, count: $transactionCount, total: $totalAmount)';
  }
}
