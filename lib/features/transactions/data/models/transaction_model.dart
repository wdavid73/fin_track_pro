import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:hive/hive.dart';

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

  const TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.type,
    super.note,
    required super.date,
    required super.createdAt,
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
    );
  }
}
