import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_cubit.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_state.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/amount_input_widget.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAddTransactionCubit extends MockCubit<AddTransactionState>
    implements AddTransactionCubit {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockAddTransactionCubit mockCubit;
  late MockTransactionBloc mockTransactionBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockCubit = MockAddTransactionCubit();
    mockTransactionBloc = MockTransactionBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AddTransactionCubit>.value(value: mockCubit),
          BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
        ],
        child: const Scaffold(body: AddTransactionPage()),
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  final tCategory = const Category(
    id: '1',
    name: 'Food',
    icon: 'restaurant',
    color: 0xFF000000,
    type: 'expense',
  );

  final tDate = DateTime(2024, 1, 1);

  testWidgets('should render all input widgets', (tester) async {
    when(() => mockCubit.state).thenReturn(
      AddTransactionState(
        categories: [tCategory],
        isLoadingCategories: false,
        selectedDate: tDate,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.byType(AmountInputWidget), findsOneWidget);
    expect(find.byType(CategorySelector), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  testWidgets('should show loading indicator when categories are loading', (
    tester,
  ) async {
    when(() => mockCubit.state).thenReturn(
      AddTransactionState(isLoadingCategories: true, selectedDate: tDate),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CategorySelector), findsNothing);
  });

  testWidgets('should call updateAmount when amount changes', (tester) async {
    when(() => mockCubit.state).thenReturn(
      AddTransactionState(
        categories: [tCategory],
        isLoadingCategories: false,
        selectedDate: tDate,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).first, '50');
    verify(() => mockCubit.updateAmount(50.0)).called(1);
  });
}
