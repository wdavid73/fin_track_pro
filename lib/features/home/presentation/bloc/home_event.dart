part of 'home_bloc.dart';

/// Base class for all Home events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load home data (recent transactions and balance)
class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

/// Event to refresh home data
class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}
