import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:hive_ce/hive_ce.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends Transaction {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  double get amount => super.amount;

  @HiveField(2)
  @override
  String get categoryId => super.categoryId;

  @HiveField(3)
  @override
  String get type => super.type;

  @HiveField(4)
  @override
  String? get note => super.note;

  @HiveField(5)
  @override
  DateTime get date => super.date;

  @HiveField(6)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(7)
  @override
  DateTime get updatedAt => super.updatedAt;

  const TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.type,
    super.note,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      categoryId: categoryId,
      type: type,
      note: note,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'type': type,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      type: map['type'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
