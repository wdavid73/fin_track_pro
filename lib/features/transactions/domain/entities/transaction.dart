import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final String type; // 'income' or 'expense'
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    categoryId,
    type,
    note,
    date,
    createdAt,
    updatedAt,
  ];

  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? type,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, date: $date)';
  }
}
