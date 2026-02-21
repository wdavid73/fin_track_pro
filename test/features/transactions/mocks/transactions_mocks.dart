import 'package:fin_track_pro/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/usecases.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTransactions extends Mock implements GetTransactions {}

class MockGetPaginatedTransactions extends Mock
    implements GetPaginatedTransactions {}

class MockCreateTransaction extends Mock implements CreateTransaction {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockTransactionLocalDataSource extends Mock
    implements TransactionLocalDataSource {}

class MockTransactionBloc extends Mock implements TransactionBloc {}

class MockEditTransactionCubit extends Mock implements EditTransactionCubit {}
