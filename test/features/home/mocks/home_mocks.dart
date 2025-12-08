import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_recent_transactions.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_total_balance.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRecentTransactions extends Mock implements GetRecentTransactions {}

class MockGetTotalBalance extends Mock implements GetTotalBalance {}

class MockGetCategories extends Mock implements GetCategoriesUseCase {}

class MockGetBudgetData extends Mock implements GetBudgetData {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}
