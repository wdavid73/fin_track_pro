# Model & Entity Patterns

## Entity (Domain Layer)

Entities are pure Dart classes with no framework dependencies. They represent
the core business data the app works with.

```dart
class PaymentEntity {
  final String id;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  PaymentEntity copyWith({
    String? id,
    double? amount,
    String? currency,
    PaymentStatus? status,
    DateTime? createdAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentEntity &&
        other.id == id &&
        other.amount == amount &&
        other.currency == currency &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, amount, currency, status, createdAt);

  @override
  String toString() =>
      'PaymentEntity(id: $id, amount: $amount, currency: $currency, '
      'status: $status, createdAt: $createdAt)';
}

enum PaymentStatus { pending, completed, failed, cancelled }
```

## Model (Data Layer)

Models handle serialization and map to/from entities. They live in `data/models/`.

```dart
class PaymentModel {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  /// Always handle both int and String IDs from backend.
  /// Always use `num` → `toDouble()` for numeric fields.
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      amount: amount,
      currency: currency,
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: createdAt,
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status.name,
      createdAt: entity.createdAt,
    );
  }

  PaymentModel copyWith({
    String? id,
    double? amount,
    String? currency,
    String? status,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel &&
        other.id == id &&
        other.amount == amount &&
        other.currency == currency &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, amount, currency, status, createdAt);
}
```

## JSON Parsing Safety Rules

1. **IDs:** Always `json['id'].toString()` — backends may return int or String.
2. **Numbers:** Always `(json['field'] as num).toDouble()` for doubles, `(json['field'] as num).toInt()` for ints.
3. **Dates:** Always `DateTime.parse(json['field'] as String)`.
4. **Enums:** Use `firstWhere` with `orElse` fallback — never trust backend strings blindly.
5. **Nullable fields:** Use `json['field'] as String?` with `?? defaultValue` where appropriate.
6. **Nested objects:** `NestedModel.fromJson(json['nested'] as Map<String, dynamic>)`.
7. **Lists:** `(json['items'] as List).map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList()`.

## Enum Serialization Pattern

```dart
// In the entity
enum PaymentMethod { commodo, nequi, daviplata, pse }

// In the model — convert using a map for non-trivial mappings
extension PaymentMethodX on PaymentMethod {
  String toJsonValue() {
    return switch (this) {
      PaymentMethod.commodo => 'COMMODO',
      PaymentMethod.nequi => 'NEQUI',
      PaymentMethod.daviplata => 'DAVIPLATA',
      PaymentMethod.pse => 'PSE',
    };
  }

  static PaymentMethod fromJsonValue(String value) {
    return switch (value.toUpperCase()) {
      'COMMODO' => PaymentMethod.commodo,
      'NEQUI' => PaymentMethod.nequi,
      'DAVIPLATA' => PaymentMethod.daviplata,
      'PSE' => PaymentMethod.pse,
      _ => PaymentMethod.commodo, // safe fallback
    };
  }
}
```
