import 'package:equatable/equatable.dart';
// part of 'lobbyledger_bloc_dart_bloc.dart';



abstract class TransactionFilterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTransactions extends TransactionFilterEvent {}

class ApplyFilter extends TransactionFilterEvent {
  final String filterType;

  ApplyFilter(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class FetchFilterOptions extends TransactionFilterEvent {} // New Event
