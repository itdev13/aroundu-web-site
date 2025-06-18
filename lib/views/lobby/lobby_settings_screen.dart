import 'package:aroundu/designs/colors.designs.dart';
// import 'package:aroundu/designs/widgets/app_bar.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LobbySettingsScreen extends ConsumerStatefulWidget {
  final String lobbyId;
  final String lobbyTitle;

  const LobbySettingsScreen({
    Key? key,
    required this.lobbyId,
    required this.lobbyTitle,
  }) : super(key: key);

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
          .read(lobbySettingsProvider(widget.lobbyId).notifier)
          .fetchSettings(widget.lobbyId);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the settings state
    final settingsState = ref.watch(lobbySettingsProvider(widget.lobbyId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: DesignColors.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: DesignText(
          text: 'Settings',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DesignColors.primary,
        )
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: DesignColors.accent))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lobby title
                    DesignText(
                      text: widget.lobbyTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DesignColors.primary,
                    ),
                    Space.h(height: 24),

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
                            onChanged: (value) => _updateSetting(
                              showLobbyMembers: value,
                            ),
                          ),
                          Divider(
                              height: 1, color: Colors.grey.withOpacity(0.2)),
                          // Enable Chat setting
                          _buildSettingTile(
                            title: 'Enable Chat',
                            subtitle: 'Allow members to chat with each other',
                            value: settingsState.enableChat,
                            onChanged: (value) => _updateSetting(
                              enableChat: value,
                            ),
                          ),
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
            activeColor: DesignColors.accent,
          ),
        ],
      ),
    );
  }

  Future<void> _updateSetting(
      {bool? showLobbyMembers, bool? enableChat}) async {
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
              CircularProgressIndicator(
                color: DesignColors.accent,
              ),
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
        .read(lobbySettingsProvider(widget.lobbyId).notifier)
        .updateSettings(
          widget.lobbyId,
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
      ref.invalidate(lobbyDetailsProvider(widget.lobbyId));
    } else {
      CustomSnackBar.show(
        context: context,
        message: "Failed to update settings",
        type: SnackBarType.error,
      );
    }
  }
}
