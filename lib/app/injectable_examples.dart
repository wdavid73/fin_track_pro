// Injectable configuration
// This file tells injectable how to generate the dependency injection code

// Available annotations:
// @injectable - For regular dependencies
// @singleton - For singleton instances (created once and reused)
// @lazySingleton - For singleton instances created only when first requested
// @module - For registering external dependencies (like Dio, SharedPreferences, etc.)

// Example usage when you create a BLoC:
// @injectable
// class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
//   final GetTransactions getTransactions;
//   
//   TransactionBloc(this.getTransactions) : super(TransactionInitial());
// }

// Example usage for a repository:
// @LazySingleton(as: TransactionRepository)
// class TransactionRepositoryImpl implements TransactionRepository {
//   final TransactionLocalDataSource localDataSource;
//   
//   TransactionRepositoryImpl(this.localDataSource);
// }

// Example usage for a use case:
// @injectable
// class GetTransactions {
//   final TransactionRepository repository;
//   
//   GetTransactions(this.repository);
// }

// Example module for external dependencies:
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   Dio get dio => Dio();
// }
