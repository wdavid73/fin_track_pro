import 'package:fin_track_pro/app/injection_container.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/add_transaction_cubit/add_transaction_cubit.dart';
import '../bloc/bloc.dart';

class WrapperBlocProviderTransaction extends StatelessWidget {
  final Widget child;
  const WrapperBlocProviderTransaction({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final transactionBloc = getIt.get<TransactionBloc>();
    final addTransactionCubit = getIt.get<AddTransactionCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: transactionBloc),
        BlocProvider(create: (_) => addTransactionCubit),
      ],
      child: child,
    );
  }
}
