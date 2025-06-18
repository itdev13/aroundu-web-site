import 'package:aroundu/models/transactions_history_model.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionFilterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionFilterLoading extends TransactionFilterState {}

class TransactionFilterLoaded extends TransactionFilterState {
  final List<TransactionsHistoryModel> transactions;
  final String? selectedFilter;

  TransactionFilterLoaded({
    required this.transactions,
    this.selectedFilter,
  });

  @override
  List<Object?> get props => [transactions, selectedFilter];
}

class TransactionFilterOptionsLoaded extends TransactionFilterState {
  final List<String> filterOptions;

  TransactionFilterOptionsLoaded({required this.filterOptions});

  @override
  List<Object?> get props => [filterOptions];
}

class TransactionFilterError extends TransactionFilterState {
  final String message;

  TransactionFilterError(this.message);

  @override
  List<Object?> get props => [message];
}
