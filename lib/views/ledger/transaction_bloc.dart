
import 'package:aroundu/models/transactions_history_model.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/ledger/transaction_state.dart';
import 'package:aroundu/views/ledger/transation_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionHistoryBloc
    extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  final AuthService authService = AuthService();
  final List<TransactionsHistoryModel> _allTransactions = [];

  TransactionHistoryBloc() : super(TransactionHistoryLoading()) {
    on<FetchTransactions>(_fetchTransactions);
    on<ApplyFilter>(_applyFilter);
  }
  Future<List<TransactionsHistoryModel>> getTransactions({
    String? lobbyId,
    String? settlementStatus,
  }) async {
    final headers = await authService.getAuthHeaders();
    final queryParams = <String, String>{};

    if (lobbyId != null) {
      queryParams['lobbyId'] = lobbyId;
    }
    if (settlementStatus != null) {
      queryParams['settlementStatus'] = settlementStatus;
    }

    final uri =
        Uri.parse('https://api.aroundu.in/payment/transactions/api/v1/filter')
            .replace(queryParameters: queryParams);

    print('API Call: ${uri.toString()}');

    try {
      final response =
          await http.get(uri, headers: headers.cast<String, String>());

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Safety check if the response has 'transactions' key
        if (!jsonResponse.containsKey('transactions')) {
          print("Key 'transactions' not found in API response.");
          throw Exception("Transactions key not found.");
        }

        final List<dynamic> transactionsList = jsonResponse['transactions'];

        // Convert the list of dynamic maps into your model list
        List<TransactionsHistoryModel> transactions = transactionsList
            .map((item) => TransactionsHistoryModel.fromJson(item))
            .toList();
        // if (jsonResponse.isEmpty) {
        //   return [];
        // }
        return transactions;
      } else {
        final errorMessage =
            'Failed to load transactions. Status code: ${response.statusCode}, Body: ${response.body}';
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error in API Call: $e');
      rethrow;
    }
  }

  Future<void> _fetchTransactions(
      FetchTransactions event, Emitter<TransactionHistoryState> emit) async {
    emit(TransactionHistoryLoading());

    try {
      final transactions = await getTransactions(
        lobbyId: (event.lobbyId?.isNotEmpty ?? false) ? event.lobbyId : null,
        settlementStatus: (event.settlementStatus?.isNotEmpty ?? false)
            ? event.settlementStatus
            : null,
      );
      emit(TransactionHistoryLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionHistoryError("Failed to load transactions."));
    }
  }

//   Future<void> _fetchTransactions(
//       FetchTransactions event, Emitter<TransactionHistoryState> emit) async {
//     emit(TransactionHistoryLoading());

//     try {
//       final transactions = await getTransactions(
//         lobbyId: event.lobbyId,
//         settlementStatus: event.settlementStatus,
//       );
//       emit(TransactionHistoryLoaded(transactions: transactions));
//     } catch (e) {
//       emit(TransactionHistoryError(""));
//     }
// // }

//   }

  void _applyFilter(ApplyFilter event, Emitter<TransactionHistoryState> emit) {
    List<TransactionsHistoryModel> filteredTransactions = _allTransactions;

    if (event.filterType == "Sort by lobby name") {
      filteredTransactions.sort((a, b) => a.lobbyId!.compareTo(b.lobbyId!));
    } else if (event.filterType == "Status of payment") {
      filteredTransactions =
          filteredTransactions.where((txn) => txn.status == "Success").toList();
    } else if (event.filterType == "Sort by date of settlement") {
      filteredTransactions
          .sort((a, b) => a.txnSuccessDate!.compareTo(b.txnSuccessDate!));
    }

    emit(TransactionHistoryLoaded(
        transactions: filteredTransactions, selectedFilter: event.filterType));
  }
}


  // // Future<void> _fetchTransactions(
  // //     FetchTransactions event, Emitter<TransactionHistoryState> emit) async {
  // //   emit(TransactionHistoryLoading());

  // //   try {
  // //     final response = await Api.getTransactionsHistory();

  // //     print("Raw API response: ${response}");

  // //     if (response is Response) {
  // //       final data = response.data;
  // //       print("Response data: $data");

  // //       if (data is List) {
  // //         print("Data is a List");
  // //         _allTransactions =
  // //             data.map((e) => TransactionsHistoryModel.fromJson(e)).toList();
  // //       } else if (data is Map<String, dynamic> && data.containsKey("data")) {
  // //         print("Data is a Map with 'data' key");
  // //         final List<dynamic> transactionsData = data["data"];
  // //         _allTransactions = transactionsData
  // //             .map((e) => TransactionsHistoryModel.fromJson(e))
  // //             .toList();
  // //       } else {
  // //         print("Unexpected format: ${data.runtimeType}");
  // //         throw Exception("Unexpected response format");
  // //       }

  // //       emit(TransactionHistoryLoaded(transactions: _allTransactions));
  // //     } else {
  // //       throw Exception("API response is not a valid Dio Response object");
  // //     }
  // //   } catch (e, stackTrace) {
  // //     print("Error fetching transactions: $e");
  // //     print("Stack trace: $stackTrace");

  // //     if (e is DioError) {
  // //       print("DioError details: ${e.message}");
  // //       print("DioError response: ${e.response?.data}");
  // //     }

  // //     emit(TransactionHistoryError("Failed to load transactions"));
  // //   }
  // // }

  // Future<void> _fetchTransactions(
  //     FetchTransactions event, Emitter<TransactionHistoryState> emit) async {
  //   emit(TransactionHistoryLoading());

  //   try {
  //     final response = await Api.getTransactionsHistory();

  //     if (response is Response) {
  //       // If using Dio, extract response.data
  //       final data = response.data;

  //       if (data is List) {
  //         // If response.data is a list, map it to the model
  //         _allTransactions =
  //             data.map((e) => TransactionsHistoryModel.fromJson(e)).toList();
  //       } else if (data is Map<String, dynamic> && data.containsKey("data")) {
  //         // If API wraps data inside a key, extract the list
  //         final List<dynamic> transactionsData = data["data"];
  //         _allTransactions = transactionsData
  //             .map((e) => TransactionsHistoryModel.fromJson(e))
  //             .toList();
  //       } else {
  //         throw Exception("Unexpected response format");
  //       }
  //     } else {
  //       throw Exception("API response is not a valid Dio Response object");
  //     }

  //     emit(TransactionHistoryLoaded(transactions: _allTransactions));
  //   } catch (e) {
  //     print("Error fetching transactions: $e");
  //     emit(TransactionHistoryError("Failed to load transactions"));
  //   }
  // }

