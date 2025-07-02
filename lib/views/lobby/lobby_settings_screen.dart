import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/icons.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
// import 'package:aroundu/designs/widgets/app_bar.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/dashboard/dashboard.view.dart';
import 'package:aroundu/views/lobby/provider/delete_lobby_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_settings_provider.dart';
import 'package:aroundu/views/lobby/provider/markClosed_lobby_provider.dart';
import 'package:aroundu/views/lobby/provider/past_lobby_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class LobbySettingsScreen extends ConsumerStatefulWidget {
  final Lobby lobby;

  const LobbySettingsScreen({super.key, required this.lobby});

  @override
  ConsumerState<LobbySettingsScreen> createState() =>
      _LobbySettingsScreenState();
}

class _LobbySettingsScreenState extends ConsumerState<LobbySettingsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch current settings when screen loads
    Future.microtask(() async {
      await ref
          .read(lobbySettingsProvider(widget.lobby.id).notifier)
          .fetchSettings(
            lobbyId: widget.lobby.id,
            showLobbyMembers: widget.lobby.setting.showLobbyMembers,
            enableChat: widget.lobby.setting.enableChat,
          );
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the settings state
    final settingsState = ref.watch(lobbySettingsProvider(widget.lobby.id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DesignColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: DesignText(
          text: 'Settings',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DesignColors.primary,
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: DesignColors.accent),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lobby title
                      // DesignText(
                      //   text: widget.lobbyTitle,
                      //   fontSize: 18,
                      //   fontWeight: FontWeight.w600,
                      //   color: DesignColors.primary,
                      // ),
                      // Space.h(height: 24.h),

                      // Settings section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Show Lobby Members setting
                            _buildSettingTile(
                              title: 'Show Lobby Members',
                              subtitle:
                                  'Allow members to see who else is in the lobby',
                              value: settingsState.showLobbyMembers,
                              onChanged:
                                  (value) =>
                                      _updateSetting(showLobbyMembers: value),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            // Enable Chat setting
                            _buildSettingTile(
                              title: 'Enable Chat',
                              subtitle: 'Allow members to chat with each other',
                              value: settingsState.enableChat,
                              onChanged:
                                  (value) => _updateSetting(enableChat: value),
                            ),
                            if (widget.lobby.lobbyStatus != "CLOSED") ...[
                              Divider(
                                height: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              Space.h(height: 8),
                              ListTile(
                                leading: DesignIcon.custom(
                                  icon: DesignIcons.disabled,
                                  size: 16,
                                  color: const Color(0xFFEC4B5D),
                                ),
                                title: DesignText(
                                  text: 'Mark as closed',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF323232),
                                ),
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: DesignText(
                                          text: 'Close Lobby?',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        content: DesignText(
                                          text:
                                              'Are you sure you want to close the lobby? Once closed, no more people will be able to join this lobby.',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          maxLines: null,
                                          overflow: TextOverflow.visible,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      side: BorderSide(
                                                        color:
                                                            DesignColors.accent,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: DesignText(
                                                    text: 'Cancel',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: DesignColors.accent,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        DesignColors.accent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                      context,
                                                    ); // Close dialog
                                                    bool isClosedSuccess =
                                                        await ref.read(
                                                          markAsClosedLobbyProvider(
                                                            widget.lobby.id,
                                                          ).future,
                                                        );
                                                    // Close menu
                                                    if (isClosedSuccess) {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Lobby marked as closed",
                                                      );
                                                      ref
                                                          .read(
                                                            lobbyDetailsProvider(
                                                              widget.lobby.id,
                                                            ).notifier,
                                                          )
                                                          .reset();
                                                      await ref
                                                          .read(
                                                            lobbyDetailsProvider(
                                                              widget.lobby.id,
                                                            ).notifier,
                                                          )
                                                          .fetchLobbyDetails(
                                                            widget.lobby.id,
                                                          );
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Something went wrong please try again",
                                                      );
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  child: DesignText(
                                                    text: 'Close',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              Space.h(height: 8),
                            ],
                            if (widget.lobby.currentMembers == 0) ...[
                              Divider(
                                height: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              Space.h(height: 8),
                              ListTile(
                                leading: DesignIcon.custom(
                                  icon: DesignIcons.delete,
                                  size: 16,
                                  color: const Color(0xFFEC4B5D),
                                ),
                                title: DesignText(
                                  text: 'Delete',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF323232),
                                ),
                                onTap: () async {
                                  // Show confirmation dialog before deleting
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: DesignText(
                                          text: 'Delete Lobby?',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        content: DesignText(
                                          text:
                                              'Are you sure you want to delete this lobby? This action cannot be undone.',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          maxLines: null,
                                          overflow: TextOverflow.visible,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      side: BorderSide(
                                                        color:
                                                            DesignColors.accent,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: DesignText(
                                                    text: 'Cancel',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: DesignColors.accent,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                      context,
                                                    ); // Close dialog
                                                    bool isDeleteSuccess =
                                                        await ref.read(
                                                          deleteLobbyProvider(
                                                            widget.lobby.id,
                                                          ).future,
                                                        );
                                                    Get.offAllNamed(
                                                      AppRoutes.dashboard,
                                                    );
                                                    if (isDeleteSuccess) {
                                                      Fluttertoast.showToast(
                                                        msg: "Lobby Deleted",
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Something went wrong please try again",
                                                      );
                                                    }
                                                  },
                                                  child: DesignText(
                                                    text: 'Delete',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              Space.h(height: 8),
                            ],
                            if (widget.lobby.lobbyStatus != "PAST") ...[
                              Divider(
                                height: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              Space.h(height: 8),
                              ListTile(
                                leading: DesignIcon.custom(
                                  icon: DesignIcons.disabled,
                                  size: 16,
                                  color: const Color(0xFFEC4B5D),
                                ),
                                title: DesignText(
                                  text: 'Mark as Past',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF323232),
                                ),
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: DesignText(
                                          text: 'Close Lobby?',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        content: DesignText(
                                          text:
                                              'Are you sure you want to make this lobby status past? Once past, no more people will be able to join this lobby.',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          maxLines: null,
                                          overflow: TextOverflow.visible,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      side: BorderSide(
                                                        color:
                                                            DesignColors.accent,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: DesignText(
                                                    text: 'Cancel',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: DesignColors.accent,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        DesignColors.accent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                      context,
                                                    ); // Close dialog
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (
                                                        BuildContext context,
                                                      ) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          content: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              CircularProgressIndicator(
                                                                color:
                                                                    DesignColors
                                                                        .accent,
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                              DesignText(
                                                                text:
                                                                    "making lobby past...",
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    final activationNotifier =
                                                        ref.read(
                                                          lobbyPastProvider(
                                                            widget.lobby.id,
                                                          ).notifier,
                                                        );
                                                    final success =
                                                        await activationNotifier
                                                            .activateLobby(
                                                              widget.lobby.id,
                                                            );

                                                    // Close the loading dialog
                                                    if (Navigator.canPop(
                                                      context,
                                                    )) {
                                                      Navigator.pop(context);
                                                    }

                                                    // Show success or error message
                                                    if (success) {
                                                      CustomSnackBar.show(
                                                        context: context,
                                                        message:
                                                            "Lobby activated successfully!",
                                                        type:
                                                            SnackBarType
                                                                .success,
                                                      );

                                                      // Refresh the lobby details
                                                      ref
                                                          .read(
                                                            lobbyDetailsProvider(
                                                              widget.lobby.id,
                                                            ).notifier,
                                                          )
                                                          .reset();
                                                      await ref
                                                          .read(
                                                            lobbyDetailsProvider(
                                                              widget.lobby.id,
                                                            ).notifier,
                                                          )
                                                          .fetchLobbyDetails(
                                                            widget.lobby.id,
                                                          );
                                                    } else {
                                                      CustomSnackBar.show(
                                                        context: context,
                                                        message:
                                                            "Failed to activate lobby. Please try again.",
                                                        type:
                                                            SnackBarType.error,
                                                      );
                                                    }

                                                    Navigator.pop(context);
                                                  },
                                                  child: DesignText(
                                                    text: 'Close',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              Space.h(height: 8),
                            ],
                          ],
                        ),
                      ),

                      Space.h(height: 24),

                      // Settings description
                      DesignText(
                        text:
                            'These settings control how members interact within your lobby. Changes will take effect immediately.',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DesignColors.secondary,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: DesignColors.primary,
                ),
                Space.h(height: 4),
                DesignText(
                  text: subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: DesignColors.secondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            inactiveThumbColor: DesignColors.accent,
            trackOutlineColor: WidgetStateColor.resolveWith(
              (states) => Colors.white,
            ),
            activeColor: DesignColors.accent,
          ),
        ],
      ),
    );
  }

  Future<void> _updateSetting({
    bool? showLobbyMembers,
    bool? enableChat,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: DesignColors.accent),
              SizedBox(height: 16),
              DesignText(
                text: "Updating settings...",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );

    // Make API call to update settings
    final success = await ref
        .read(lobbySettingsProvider(widget.lobby.id).notifier)
        .updateSettings(
          widget.lobby.id,
          showLobbyMembers: showLobbyMembers,
          enableChat: enableChat,
        );

    // Close the loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show success or error message
    if (success) {
      CustomSnackBar.show(
        context: context,
        message: "Settings updated successfully",
        type: SnackBarType.success,
      );

      // Invalidate the lobby details provider to refresh data
      ref.invalidate(lobbyDetailsProvider(widget.lobby.id));
    } else {
      CustomSnackBar.show(
        context: context,
        message: "Failed to update settings",
        type: SnackBarType.error,
      );
    }
  }
}
