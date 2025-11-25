part of 'home_bloc.dart';

/// Base class for all Home states
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State while loading data
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State when data is successfully loaded
class HomeLoaded extends HomeState {
  final List<Transaction> recentTransactions;
  final double totalBalance;
  final Map<String, Category> categories;
  final BudgetData? budgetData;

  const HomeLoaded({
    required this.recentTransactions,
    required this.totalBalance,
    required this.categories,
    this.budgetData,
  });

  @override
  List<Object?> get props => [
    recentTransactions,
    totalBalance,
    categories,
    budgetData,
  ];
}

/// State when an error occurs
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
