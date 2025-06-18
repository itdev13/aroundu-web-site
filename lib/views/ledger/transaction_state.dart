import 'package:aroundu/models/transactions_history_model.dart';
import 'package:equatable/equatable.dart';
// import 'package:aroundu/models/transaction_history_model.dart';

abstract class TransactionHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionHistoryLoading extends TransactionHistoryState {}

class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionsHistoryModel> transactions;
  final String? selectedFilter;

  TransactionHistoryLoaded({required this.transactions, this.selectedFilter});

  @override
  List<Object?> get props => [transactions, selectedFilter];
}

class TransactionHistoryError extends TransactionHistoryState {
  final String message;

  TransactionHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
