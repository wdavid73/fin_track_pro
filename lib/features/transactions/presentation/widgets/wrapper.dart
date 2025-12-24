import 'package:fin_track_pro/app/injection_container.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class WrapperBlocProviderTransaction extends StatelessWidget {
  final Widget child;
  const WrapperBlocProviderTransaction({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Use singleton TransactionBloc from get_it
    final transactionBloc = getIt<TransactionBloc>();
    final addTransactionCubit = getIt<AddTransactionCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: transactionBloc),
        BlocProvider(create: (_) => addTransactionCubit),
      ],
      child: child,
    );
  }
}
