import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/create_budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/delete_budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/get_budgets.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/update_budget.dart';

part 'budget_event.dart';
part 'budget_state.dart';

@injectable
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgets _getBudgets;
  final CreateBudget _createBudget;
  final UpdateBudget _updateBudget;
  final DeleteBudget _deleteBudget;

  BudgetBloc(
    this._getBudgets,
    this._createBudget,
    this._updateBudget,
    this._deleteBudget,
  ) : super(const BudgetInitial()) {
    on<LoadBudgets>(_onLoad);
    on<CreateBudgetEvent>(_onCreate);
    on<UpdateBudgetEvent>(_onUpdate);
    on<DeleteBudgetEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());
    try {
      final budgets = await _getBudgets();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _createBudget(event.budget);
      final budgets = await _getBudgets();
      emit(BudgetActionSuccess(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _updateBudget(event.budget);
      final budgets = await _getBudgets();
      emit(BudgetActionSuccess(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _deleteBudget(event.id);
      final budgets = await _getBudgets();
      emit(BudgetActionSuccess(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
