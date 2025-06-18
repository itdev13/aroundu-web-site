import 'package:aroundu/designs/fonts.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/transactions_history_model.dart';
import 'package:aroundu/views/ledger/transaction_bloc.dart';
import 'package:aroundu/views/ledger/transaction_state.dart';
import 'package:aroundu/views/ledger/transation_event.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers_util.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LobbyLedgerPage extends ConsumerStatefulWidget {
  final String userId;
  final String lobbyId;

  const LobbyLedgerPage({super.key, this.userId = '', this.lobbyId = ''});
  @override
  ConsumerState<LobbyLedgerPage> createState() => _LobbyLedgerPageState();
}

class _LobbyLedgerPageState extends ConsumerState<LobbyLedgerPage> {
  String? selectedLobby;
  String? selectedLobbyId;
  String? selectedSettlementStatus;
  bool isLobbyHasData = true;
  late Future<dynamic> transactionsFuture;
  @override
  void initState() {
    super.initState();
    transactionsFuture = fetchTransactions();
    if (widget.lobbyId.isEmpty) {
      context
          .read<TransactionHistoryBloc>()
          .add(FetchTransactions()); // trigger bloc event here
    } else {
      context
          .read<TransactionHistoryBloc>()
          .add(FetchTransactions(lobbyId: widget.lobbyId));
    }
  }

  Future<dynamic> fetchTransactions() async {
    final response = widget.lobbyId.isNotEmpty
        ? await Api.getLobbyTransactionsHistory(widget.lobbyId)
        : await Api.getTransactionsHistory(widget.userId);

    final data = response.data;

    if (data == null || data['transactions'].isEmpty) {
      isLobbyHasData = false; // Update state variable
    } else {
      isLobbyHasData = true;
    }

    return response;
  }

  void _fetchFilteredTransactions() {
    context.read<TransactionHistoryBloc>().add(
          FetchTransactions(
            lobbyId: widget.lobbyId != '' ? widget.lobbyId : selectedLobbyId,
            settlementStatus: selectedSettlementStatus,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DesignText(
          text: 'Lobby ledger',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 1.0,
        shadowColor: Colors.grey[300],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          children: [
            SizedBox(height: 10.0),
            Container(
              height: 40.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildChip('All'),
                  if (widget.lobbyId.isEmpty) _buildChip2('Lobby'),
                  _buildChip1('Settlement Status'),
                ],
              ),
            ),
            // SizedBox(height: 10.0),
            // VerifyCard(),
            SizedBox(height: 10.0),
            FutureBuilder<dynamic>(
              future: transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data.data['transactions'].isEmpty) {
                  return Container(); // No transactions, so return empty
                }

                final transactions = snapshot.data.data;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Settlement detail',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          _buildRow('Total Money Collected',
                              '₹${transactions['totalMoneyCollected'] ?? 0}'),
                          const SizedBox(height: 12),
                          _buildRow(
                            'Total Refund deducted',
                            '-₹${transactions['totalRefundDeducted'] ?? 0}',
                            valueColor: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          _buildRow('Aroundu Service Fees',
                              '₹${transactions['aroundUMDR'] ?? 0}'),
                          const SizedBox(height: 12),
                          _buildRow(
                            'Total Money Settled',
                            '₹${transactions['totalMoneySettled'] ?? 0}',
                            valueColor: Colors.green,
                            isBold: true,
                          ),
                          const Divider(color: Colors.grey, thickness: 0.5),
                          const SizedBox(height: 12),
                          _buildRow(
                            'Pending Settlement',
                            '₹${transactions['totalMoneyToBeSettled'] ?? 0}',
                            valueColor: Colors.red,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            Expanded(
              child:
                  BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
                builder: (context, state) {
                  if (state is TransactionHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TransactionHistoryLoaded) {
                    if (state.transactions.isEmpty) {
                      if (isLobbyHasData) {
                        return const Center(
                          child: DesignText(
                            text:
                                'No transactions found for the selected filters.',
                            fontSize: 14,
                            maxLines: 3,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return const Center(
                        child: DesignText(
                          text:
                              'No transactions yet! 🚀 Create a paid lobby to start tracking your earnings and settlements here..',
                          fontSize: 14,
                          maxLines: 3,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    return _buildDataTable(state.transactions);
                  } else if (state is TransactionHistoryError) {
                    return const Center(
                        child: Text("Failed to load transactions"));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Chip(
        label: Text(
          label,
          style: DesignFonts.poppins
              .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // Widget _buildChip1(String label) {
  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       return Padding(
  //         padding: const EdgeInsets.only(right: 4),
  //         child: PopupMenuButton<String>(
  //           onSelected: (value) {
  //             setState(() {
  //               selectedSettlementStatus = value; // Save selected
  //             });
  //             _fetchFilteredTransactions(); // Trigger API with filters
  //           },
  //           itemBuilder: (context) => [
  //             PopupMenuItem(value: 'pending', child: Text('Pending')),
  //             PopupMenuItem(value: 'settled', child: Text('Settled')),
  //           ],
  //           child: Chip(
  //             label:
  //             Text(
  //               selectedSettlementStatus ?? label,
  //               style: DesignFonts.poppins
  //                   .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
  //             ),
  //             deleteIcon: Icon(Icons.arrow_drop_down),
  //             onDeleted: () {},
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //               side: BorderSide(color: Colors.grey),
  //             ),
  //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildChip2(String label) {
  //   final lobbiesAsync =
  //       ref.watch(LobbyProviderUtil.getProvider(LobbyType.myLobbies));

  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       return Padding(
  //         padding: const EdgeInsets.only(right: 4),
  //         child: lobbiesAsync.when(
  //           data: (lobbies) => PopupMenuButton<String>(
  //             onSelected: (value) {
  //               setState(() {
  //                 selectedLobbyId = value; // Save selected
  //               });
  //               _fetchFilteredTransactions(); // Trigger API with filters
  //             },
  //             itemBuilder: (context) => lobbies.isNotEmpty
  //                 ? lobbies
  //                     .map((lobby) => PopupMenuItem(
  //                           value: lobby.id, // Send lobbyId, not title
  //                           child: Text(lobby.title),
  //                         ))
  //                     .toList()
  //                 : [],
  //             child: Chip(
  //               label: Text(
  //                 selectedLobbyId ?? label,
  //                 style: DesignFonts.poppins
  //                     .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
  //               ),
  //               deleteIcon: Icon(Icons.arrow_drop_down),
  //               onDeleted: () {},
  //               backgroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20),
  //                 side: BorderSide(color: Colors.grey),
  //               ),
  //               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //             ),
  //           ),
  //           loading: () => Chip(
  //             label: Text('Loading...',
  //                 style: DesignFonts.poppins.copyWith(fontSize: 12)),
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //               side: BorderSide(color: Colors.grey),
  //             ),
  //           ),
  //           error: (error, stack) => Chip(
  //             label: Text('Error',
  //                 style: DesignFonts.poppins.copyWith(fontSize: 12)),
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //               side: BorderSide(color: Colors.grey),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget _buildChip1(String label) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedSettlementStatus = value;
              });
              _fetchFilteredTransactions();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'settled', child: Text('Settled')),
            ],
            child: Chip(
              label: Text(
                selectedSettlementStatus ?? label,
                style: DesignFonts.poppins
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
              ),
              deleteIcon: selectedSettlementStatus != null
                  ? Icon(Icons.close, size: 18, color: Colors.red)
                  : Icon(Icons.arrow_drop_down),
              onDeleted: selectedSettlementStatus != null
                  ? () {
                      setState(() {
                        selectedSettlementStatus = null; // Remove filter
                      });
                      _fetchFilteredTransactions(); // Trigger API with updated filters
                    }
                  : null,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip2(String label) {
    final lobbiesAsync =
        ref.watch(LobbyProviderUtil.getProvider(LobbyType.myLobbies));

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: lobbiesAsync.when(
            data: (lobbies) => PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedLobbyId = value;
                });
                _fetchFilteredTransactions();
              },
              itemBuilder: (context) => lobbies.isNotEmpty
                  ? lobbies
                      .map((lobby) => PopupMenuItem(
                            value: lobby.id,
                            child: Text(lobby.title),
                          ))
                      .toList()
                  : [],
              child: Chip(
                label: Text(
                  selectedLobbyId ?? label,
                  style: DesignFonts.poppins
                      .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
                ),
                deleteIcon: selectedLobbyId != null
                    ? Icon(Icons.close, size: 18, color: Colors.red)
                    : Icon(Icons.arrow_drop_down),
                onDeleted: selectedLobbyId != null
                    ? () {
                        setState(() {
                          selectedLobbyId = null;
                        });
                        _fetchFilteredTransactions();
                      }
                    : null,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            loading: () => Chip(
              label: Text('Loading...',
                  style: DesignFonts.poppins.copyWith(fontSize: 12)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey),
              ),
            ),
            error: (error, stack) => Chip(
              label: Text('Error',
                  style: DesignFonts.poppins.copyWith(fontSize: 12)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<TransactionsHistoryModel> transactions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      child: DataTable(
        columnSpacing: 16.0,
        headingRowColor:
            MaterialStateColor.resolveWith((states) => Colors.lightBlue[100]!),
        border: TableBorder.all(
          color: Colors.grey,
          width: 1.0,
        ),
        columns: [
          _buildDataColumn('Transaction ID'),
          _buildDataColumn('User Name'),
          _buildDataColumn('Lobby Name'),
          _buildDataColumn('Amount'),
          _buildDataColumn('Expected Settlement Date'),
          _buildDataColumn('Settlement Status'),
          _buildDataColumn('Transaction Date'),
        ],
        rows: transactions.map((txn) {
          return DataRow(
            cells: [
              _buildDataCell(txn?.transactionId ?? ''),
              _buildDataCell(txn.userSummary?.userName ?? 'N/A'),
              _buildDataCell(txn.lobbyName ?? 'N/A'),
              _buildDataCell('₹ ${txn.amount?.toStringAsFixed(2) ?? '0.00'}'),
              _buildDataCell(txn.expectedSettlementDate ?? 'No Date'),
              _buildDataCell(txn.settlementStatus ?? 'Pending'),
              _buildDataCell(txn.txnSuccessDate ?? 'No Date'),
            ],
          );
        }).toList(),
      ),
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: DesignText(
        text: label,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  DataCell _buildDataCell(String value) {
    return DataCell(
      DesignText(
        text: value,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color valueColor = Colors.black, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DesignText(
          text: label,
          // style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          // ),
        ),
        DesignText(
          text: value,
          // style: TextStyle(
          fontSize: 14,
          color: valueColor,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          // ),
        ),
      ],
    );
  }
}
