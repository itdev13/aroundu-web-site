import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/views/lobby/provider/selected_tickets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

//here

class TicketOptionsForAttendee extends ConsumerStatefulWidget {
  final List<LobbyTicketOption> ticketOptions;
  final String lobbyTitle;
  final bool isMultiplePricing;
  final String lobbyId;
  
  const TicketOptionsForAttendee({
    super.key,
    required this.ticketOptions,
    this.lobbyTitle = "",
    required this.isMultiplePricing,
    required this.lobbyId,
  });

  @override
  ConsumerState<TicketOptionsForAttendee> createState() => _TicketOptionsForAttendeeState();
}

class _TicketOptionsForAttendeeState extends ConsumerState<TicketOptionsForAttendee> {
  @override
  void initState() {
    Future.microtask((){
      ref.read(selectedTicketsProvider.notifier).clearAll();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final selectedTickets = ref.watch(selectedTicketsProvider);
    final currentLobbyTickets = selectedTickets[widget.lobbyId] ?? [];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: DesignText(
          text: widget.lobbyTitle,
          fontSize: 18,
        ),
        leading: IconButton(
          onPressed: () {
            Get.back(result: {
              'shouldProceed': false,
              'selectedTickets': currentLobbyTickets,
            });
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: widget.ticketOptions.length,
                itemBuilder: (context, index) {
                  final ticketOption = widget.ticketOptions[index];
                  final isSelected = currentLobbyTickets.any((t) => t.ticketId == ticketOption.id);
                  final selectedTicket = currentLobbyTickets.firstWhere(
                    (t) => t.ticketId == ticketOption.id,
                    orElse: () => SelectedTicket(ticketId: '', name: '', slots: 0),
                  );
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: (index == widget.ticketOptions.length - 1) ? 0 : 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? DesignColors.accent : Color(0xFFe7e8ea),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DesignText(
                          text: ticketOption.name,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignColors.primary,
                        ),
                        Space.h(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DesignText(
                              text: '₹${ticketOption.price.toStringAsFixed(2)}',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: DesignColors.primary,
                            ),
                            if (!widget.isMultiplePricing && !isSelected)
                              DesignButton(
                                onPress: () {
                                  ref.read(selectedTicketsProvider.notifier).addTicket(
                                    lobbyId: widget.lobbyId,
                                    isMultiplePricing: widget.isMultiplePricing,
                                    ticketOption: ticketOption,
                                    slots: 1,
                                  );
                                },
                                title: "ADD",
                                titleSize: 12,
                                titleColor: DesignColors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(6),
                                constraints: BoxConstraints(maxWidth: widget.isMultiplePricing ? 96 : 80),
                                decoration: BoxDecoration(
                                  color: DesignColors.accent,
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.isMultiplePricing || (isSelected && selectedTicket.slots > 0))
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (selectedTicket.slots > 0) {
                                              final newSlots = selectedTicket.slots - 1;
                                              if (newSlots == 0) {
                                                ref.read(selectedTicketsProvider.notifier).removeTicket(
                                                  lobbyId: widget.lobbyId,
                                                  ticketId: ticketOption.id,
                                                );
                                              } else {
                                                ref.read(selectedTicketsProvider.notifier).addTicket(
                                                  lobbyId: widget.lobbyId,
                                                  isMultiplePricing: widget.isMultiplePricing,
                                                  ticketOption: ticketOption,
                                                  slots: newSlots,
                                                );
                                              }
                                            }
                                          },
                                          child: Icon(
                                            Icons.remove,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    if (widget.isMultiplePricing || (isSelected && selectedTicket.slots > 0))
                                      Space.w(width: 12),
                                    Expanded(
                                      child: DesignText(
                                        text: !widget.isMultiplePricing && selectedTicket.slots == 0
                                            ? "ADD"
                                            : selectedTicket.slots.toString(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    // if ( (selectedTicket.slots > 0))
                                      Space.w(width: 12),
                                    if (( selectedTicket.slots < ticketOption.maxQuantity))
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            final currentSlots = selectedTicket.slots;
                                            final maxSlots = ticketOption.maxQuantity;
                                            final newSlots = currentSlots + 1;
                                            
                                            if (newSlots <= maxSlots) {
                                              ref.read(selectedTicketsProvider.notifier).addTicket(
                                                lobbyId: widget.lobbyId,
                                                isMultiplePricing: widget.isMultiplePricing,
                                                ticketOption: ticketOption,
                                                slots: newSlots,
                                              );
                                            }
                                          },
                                          child: Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        //  Space(height: 4),
                        Divider(color: Color(0xFFe7e8ea)),
                        //  Space(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DesignText(
                                text: ticketOption.description,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: DesignColors.primary,
                                maxLines: null,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: DesignText(
                                  text: "Max: ${ticketOption.maxQuantity}",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: DesignColors.accent,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Selected Tickets Summary
            if (currentLobbyTickets.isNotEmpty) ...[
              Space.h(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: "Selected Tickets",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignColors.primary,
                    ),
                    Space.h(height: 12),
                    ...currentLobbyTickets.map((ticket) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DesignText(
                            text: ticket.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DesignColors.primary,
                          ),
                          DesignText(
                            text: "${ticket.slots} ${ticket.slots == 1 ? 'ticket' : 'tickets'}",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignColors.accent,
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DesignButton(
            isEnabled: currentLobbyTickets.isNotEmpty,
            onPress: currentLobbyTickets.isNotEmpty ? () {
              Get.back(result: {
                'shouldProceed': true,
                'selectedTickets': currentLobbyTickets,
              });
            } : (){},
            title: "Proceed",
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
