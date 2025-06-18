import 'package:equatable/equatable.dart';

abstract class TransactionHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// class FetchTransactions extends TransactionHistoryEvent {}

class ApplyFilter extends TransactionHistoryEvent {
  final String filterType;

  ApplyFilter(this.filterType);

  @override
  List<Object?> get props => [filterType];
}
class FetchTransactions extends TransactionHistoryEvent {
  final String? lobbyId;
  final String? settlementStatus;

  FetchTransactions({this.lobbyId, this.settlementStatus});
}
