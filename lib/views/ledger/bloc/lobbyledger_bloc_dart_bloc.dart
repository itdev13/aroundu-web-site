import 'package:aroundu/models/transactions_history_model.dart';
import 'package:aroundu/views/ledger/bloc/lobbyledger_bloc_dart_event.dart';
import 'package:aroundu/views/ledger/bloc/lobbyledger_bloc_dart_state.dart';
import 'package:aroundu/views/profile/services/apis.dart';
// import 'package:aroundu/views/payment/services/blog/transaction_filter_state.dart';
// import 'package:aroundu/views/payment/services/blog/transaction_filter_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

class TransactionFilterBloc
    extends Bloc<TransactionFilterEvent, TransactionFilterState> {
  List<TransactionsHistoryModel> _allTransactions = [];
  List<String> _filterOptions = []; // Store dynamic filters from backend

  TransactionFilterBloc() : super(TransactionFilterLoading()) {
    on<FetchTransactions>(_fetchTransactions);
    on<FetchFilterOptions>(_fetchFilterOptions); // New event handler
    on<ApplyFilter>(_applyFilter);
  }

  // Fetching transactions
  Future<void> _fetchTransactions(
      FetchTransactions event, Emitter<TransactionFilterState> emit) async {
    emit(TransactionFilterLoading());

    try {
      final response = await Api.getTransactionsHistory('');

      if (response is Response) {
        final data = response.data;

        if (data is List) {
          _allTransactions =
              data.map((e) => TransactionsHistoryModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey("data")) {
          final List<dynamic> transactionsData = data["data"];
          _allTransactions = transactionsData
              .map((e) => TransactionsHistoryModel.fromJson(e))
              .toList();
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("API response is not a valid Dio Response object");
      }

      emit(TransactionFilterLoaded(transactions: _allTransactions));
    } catch (e) {
      print("Error fetching transactions: $e");
      emit(TransactionFilterError("Failed to load transactions"));
    }
  }

  // Fetching filter options dynamically
  Future<void> _fetchFilterOptions(
      FetchFilterOptions event, Emitter<TransactionFilterState> emit) async {
    emit(TransactionFilterLoading());

    try {
      final response = await Api
          .getFilterOption(); // Assuming this returns a list of filters

      if (response is Response) {
        final data = response.data;

        if (data is List) {
          _filterOptions = List<String>.from(
              data); // Make sure your API returns a list of strings
        } else if (data is Map<String, dynamic> && data.containsKey("data")) {
          final List<dynamic> filtersData = data["data"];
          _filterOptions = filtersData.cast<String>();
        } else {
          throw Exception("Unexpected filter options format");
        }

        emit(TransactionFilterOptionsLoaded(filterOptions: _filterOptions));
      } else {
        throw Exception("API response is not a valid Dio Response object");
      }
    } catch (e) {
      print("Error fetching filter options: $e");
      emit(TransactionFilterError("Failed to load filter options"));
    }
  }

  // Applying the selected filter (dynamic now)
  void _applyFilter(ApplyFilter event, Emitter<TransactionFilterState> emit) {
    List<TransactionsHistoryModel> filteredTransactions = _allTransactions;

    switch (event.filterType) {
      case "Sort by lobby name":
        filteredTransactions.sort((a, b) => a.lobbyId!.compareTo(b.lobbyId!));
        break;
      case "Status of payment":
        filteredTransactions = filteredTransactions
            .where((txn) => txn.status == "Success")
            .toList();
        break;
      case "Sort by date of settlement":
        filteredTransactions
            .sort((a, b) => a.txnSuccessDate!.compareTo(b.txnSuccessDate!));
        break;
      default:
        print("Unknown filter applied: ${event.filterType}");
        // If backend sends unknown filter, do nothing or add logic here
        break;
    }

    emit(TransactionFilterLoaded(
      transactions: filteredTransactions,
      selectedFilter: event.filterType,
    ));
  }
}
