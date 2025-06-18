
import 'package:aroundu/designs/utils.designs.dart';
import 'package:aroundu/designs/widgets/rounded.rectangle.tab.indicator.dart';
import 'package:aroundu/models/notifications.model.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/dashboard/controller.dashboard.dart';
import 'package:aroundu/views/notifications/notification_card.dart';
import 'package:aroundu/views/notifications/notifications_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';

final tabIndexNotificationsViewProvider = StateProvider<int>((ref) => 0);

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key, this.notificationPageType});
  final NotificationType? notificationPageType;

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _notificationsViewTabController;
  final DashboardController dashboardController =  Get.put(DashboardController());

  final ScrollController _scrollController = ScrollController();
  // final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    int currentIndex = 0;
    switch (widget.notificationPageType) {
      case NotificationType.generic:
        currentIndex = 0;
        break;
      case NotificationType.access:
        currentIndex = 1;
        break;
      case NotificationType.invitation:
        currentIndex = 2;
        break;
      default:
        currentIndex = 0;
    }

    _notificationsViewTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: currentIndex,
    );

    // Initialize local notifications
    // _initLocalNotifications();

    // _notificationsViewTabController = TabController(length: 3, vsync: this);

    _notificationsViewTabController.addListener(() {
      ref.read(tabIndexNotificationsViewProvider.notifier).state =
          _notificationsViewTabController.index;

      // Change notification type when tab changes
      final userId = dashboardController.userId.value;
      final index = _notificationsViewTabController.index;

      NotificationType type;
      switch (index) {
        case 0:
          type = NotificationType.generic;
          break;
        case 1:
          type = NotificationType.access;
          break;
        case 2:
          type = NotificationType.invitation;
          break;
        default:
          type = NotificationType.all;
      }

      ref.read(notificationsProvider.notifier).changeType(userId, type);
    });

    // Initial data fetch
    Future.microtask(() async {
      final userId = dashboardController.userId.value;
      ref.invalidate(notificationsProvider);

      // Clear notifications badge when notifications view is opened
      // await ref.read(notification_service.notificationApiProvider.notifier).markNotificationsAsRead();
      // await BadgeManager.clearBadge();
      ref.read(tabIndexNotificationsViewProvider.notifier).state = currentIndex;
      ref.read(notificationsProvider.notifier).fetchNotifications(userId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notificationsViewTabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final userId = dashboardController.userId.value;
    await ref.read(notificationsProvider.notifier).refresh(userId);
  }

  // Function to load more notifications
  Future<void> _loadMore() async {
    final userId = dashboardController.userId.value;
    await ref.read(notificationsProvider.notifier).loadMore(userId);

    // Show toast if no more notifications
    final state = ref.read(notificationsProvider);
    _checkAndShowNoMoreNotificationsToast(state);
  }

  // Show toast message
  void _showToast(String message) {
    CustomSnackBar.show(
      context: context,
      message: message,
      type: SnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch notifications state
    final notificationsState = ref.watch(notificationsProvider);
    final deviceType = DesignUtils.getDeviceType(context);

    return ScreenBuilder(
      phoneLayout: _buildPhoneLayout(notificationsState),
      tabletLayout: _buildTabletLayout(notificationsState),
      desktopLayout: _buildDesktopLayout(notificationsState),
    );
  }

  // Phone layout - single column list view
  Widget _buildPhoneLayout(NotificationsState notificationsState) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _notificationsViewTabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _generalTab(notificationsState),
                  _requestsTab(notificationsState),
                  _invitationTab(notificationsState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tablet layout - grid view with 2 columns
  Widget _buildTabletLayout(NotificationsState notificationsState) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _notificationsViewTabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _generalTabGrid(notificationsState, 2),
                  _requestsTabGrid(notificationsState, 2),
                  _invitationTabGrid(notificationsState, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop layout - grid view with 3 columns
  Widget _buildDesktopLayout(NotificationsState notificationsState) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _notificationsViewTabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _generalTabGrid(notificationsState, 3),
                  _requestsTabGrid(notificationsState, 3),
                  _invitationTabGrid(notificationsState, 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted header widget for reuse across layouts
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 56, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: DesignIcon.icon(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 18,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: DesignText(
                  text: "Notification",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
            ],
          ),
          Space.h(height: 34),
          TabBar(
            controller: _notificationsViewTabController,
            onTap: (index) {
              ref.read(tabIndexNotificationsViewProvider.notifier).state =
                  index;
            },
            tabs: [
              Tab(
                child: DesignText(
                  text: "General",
                  fontSize: 14,
                  color:
                      ref.watch(tabIndexNotificationsViewProvider) == 0
                          ? const Color(0xFF323232)
                          : const Color(0xFF989898),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Tab(
                child: DesignText(
                  text: "Requests",
                  fontSize: 14,
                  color:
                      ref.watch(tabIndexNotificationsViewProvider) == 1
                          ? const Color(0xFF323232)
                          : const Color(0xFF989898),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Tab(
                child: DesignText(
                  text: "Invitation",
                  fontSize: 14,
                  color:
                      ref.watch(tabIndexNotificationsViewProvider) == 2
                          ? const Color(0xFF323232)
                          : const Color(0xFF989898),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            labelColor: const Color(0xFF323232),
            unselectedLabelColor: const Color(0xFF989898),
            labelStyle: DesignFonts.poppins.merge(
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF323232),
              ),
            ),
            unselectedLabelStyle: DesignFonts.poppins.merge(
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF989898),
              ),
            ),
            indicator: RoundedRectangleTabIndicator(
              color: const Color(0xFFEAEFF2),
              radius: 24,
              paddingV: 2,
              paddingH: 40,
            ),
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.symmetric(horizontal: 8),
            indicatorColor: const Color(0xFF323232),
            indicatorWeight: 2,
          ),
          Space.h(height: 16),
        ],
      ),
    );
  }

  // Add this method to show a toast when there are no more notifications
  void _checkAndShowNoMoreNotificationsToast(NotificationsState state) {
    if (!state.hasMore && !state.isLoading && !state.isLoadingMore) {
      _showToast("No more notifications to load");
    }
  }

  // Original list view implementations
  Widget _requestsTab(NotificationsState notificationsState) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          notificationsState.isLoading && notificationsState.data == null
              ? const Center(child: CircularProgressIndicator())
              : notificationsState.error != null &&
                  notificationsState.data == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: "Error loading notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: notificationsState.error!,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    DesignButton(title: "Retry", onPress: _onRefresh),
                  ],
                ),
              )
              : (notificationsState.data?.accessNotifications.isEmpty ?? true)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_disabled_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    DesignText(
                      text: "No pending requests",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: "Access requests will appear here",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                itemCount:
                    (notificationsState.data?.accessNotifications.length ?? 0) +
                    ((notificationsState.hasMore ||
                            notificationsState.isLoadingMore)
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  // If we're at the last index and hasMore is true or isLoadingMore is true, show the load more button or loading indicator
                  if (index ==
                      notificationsState.data!.accessNotifications.length) {
                    if (notificationsState.isLoadingMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (notificationsState.hasMore) {
                      return TextButton(
                        onPressed: _loadMore,
                        child: Center(
                          child: DesignText(
                            text: "Show more",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DesignColors.accent,
                          ),
                        ),
                      );
                    }
                  }

                  // Otherwise show the notification item
                  final notification =
                      notificationsState.data!.accessNotifications[index];
                  return NotificationCard(notification: notification);
                },
              ),
    );
  }

  Widget _invitationTab(NotificationsState notificationsState) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          notificationsState.isLoading && notificationsState.data == null
              ? const Center(child: CircularProgressIndicator())
              : notificationsState.error != null &&
                  notificationsState.data == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: "Error loading notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: notificationsState.error!,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    DesignButton(title: "Retry", onPress: _onRefresh),
                  ],
                ),
              )
              : (notificationsState.data?.invitationNotifications.isEmpty ??
                  true)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    DesignText(
                      text: "No invitations yet",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: "When someone invites you, it will show up here",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                itemCount:
                    (notificationsState.data?.invitationNotifications.length ??
                        0) +
                    ((notificationsState.hasMore ||
                            notificationsState.isLoadingMore)
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  // If we're at the last index and hasMore is true or isLoadingMore is true, show the load more button or loading indicator
                  if (index ==
                      notificationsState.data!.invitationNotifications.length) {
                    if (notificationsState.isLoadingMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (notificationsState.hasMore) {
                      return TextButton(
                        onPressed: _loadMore,
                        child: Center(
                          child: DesignText(
                            text: "Show more",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DesignColors.accent,
                          ),
                        ),
                      );
                    }
                  }

                  // Otherwise show the notification item
                  final notification =
                      notificationsState.data!.invitationNotifications[index];
                  return NotificationCard(notification: notification);
                },
              ),
    );
  }

  Widget _generalTab(NotificationsState notificationsState) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          notificationsState.isLoading && notificationsState.data == null
              ? const Center(child: CircularProgressIndicator())
              : notificationsState.error != null &&
                  notificationsState.data == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: "Error loading notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: notificationsState.error!,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    DesignButton(title: "Retry", onPress: _onRefresh),
                  ],
                ),
              )
              : (notificationsState.data?.genericNotifications.isEmpty ?? true)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    DesignText(
                      text: "No general notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: "You'll see updates and announcements here",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                itemCount:
                    (notificationsState.data?.genericNotifications.length ??
                        0) +
                    ((notificationsState.hasMore ||
                            notificationsState.isLoadingMore)
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  // If we're at the last index and hasMore is true or isLoadingMore is true, show the load more button or loading indicator
                  if (index ==
                      notificationsState.data!.genericNotifications.length) {
                    if (notificationsState.isLoadingMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (notificationsState.hasMore) {
                      return TextButton(
                        onPressed: _loadMore,
                        child: Center(
                          child: DesignText(
                            text: "Show more",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DesignColors.accent,
                          ),
                        ),
                      );
                    }
                  }

                  // Otherwise show the notification item
                  final notification =
                      notificationsState.data!.genericNotifications[index];
                  return NotificationCard(notification: notification);
                },
              ),
    );
  }

  // Grid view implementations for tablet and desktop
  Widget _generalTabGrid(
    NotificationsState notificationsState,
    int crossAxisCount,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          notificationsState.isLoading && notificationsState.data == null
              ? const Center(child: CircularProgressIndicator())
              : notificationsState.error != null &&
                  notificationsState.data == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: "Error loading notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: notificationsState.error!,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    DesignButton(title: "Retry", onPress: _onRefresh),
                  ],
                ),
              )
              : (notificationsState.data?.genericNotifications.isEmpty ?? true)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    DesignText(
                      text: "No general notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: "You'll see updates and announcements here",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification =
                              notificationsState
                                  .data!
                                  .genericNotifications[index];
                          return NotificationCard(notification: notification);
                        },
                        childCount:
                            notificationsState
                                .data!
                                .genericNotifications
                                .length,
                      ),
                    ),
                  ),
                  if (notificationsState.hasMore ||
                      notificationsState.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child:
                            notificationsState.isLoadingMore
                                ? Center(child: CircularProgressIndicator())
                                : TextButton(
                                  onPressed: _loadMore,
                                  child: Center(
                                    child: DesignText(
                                      text: "Show more",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: DesignColors.accent,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _requestsTabGrid(
    NotificationsState notificationsState,
    int crossAxisCount,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          notificationsState.isLoading && notificationsState.data == null
              ? const Center(child: CircularProgressIndicator())
              : notificationsState.error != null &&
                  notificationsState.data == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: "Error loading notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: notificationsState.error!,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    DesignButton(title: "Retry", onPress: _onRefresh),
                  ],
                ),
              )
              : (notificationsState.data?.accessNotifications.isEmpty ?? true)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_disabled_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    DesignText(
                      text: "No pending requests",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: "Access requests will appear here",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification =
                              notificationsState
                                  .data!
                                  .accessNotifications[index];
                          return NotificationCard(notification: notification);
                        },
                        childCount:
                            notificationsState.data!.accessNotifications.length,
                      ),
                    ),
                  ),
                  if (notificationsState.hasMore ||
                      notificationsState.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child:
                            notificationsState.isLoadingMore
                                ? Center(child: CircularProgressIndicator())
                                : TextButton(
                                  onPressed: _loadMore,
                                  child: Center(
                                    child: DesignText(
                                      text: "Show more",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: DesignColors.accent,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _invitationTabGrid(
    NotificationsState notificationsState,
    int crossAxisCount,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          notificationsState.isLoading && notificationsState.data == null
              ? const Center(child: CircularProgressIndicator())
              : notificationsState.error != null &&
                  notificationsState.data == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: "Error loading notifications",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: notificationsState.error!,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    DesignButton(title: "Retry", onPress: _onRefresh),
                  ],
                ),
              )
              : (notificationsState.data?.invitationNotifications.isEmpty ??
                  true)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    DesignText(
                      text: "No invitations yet",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 8),
                    DesignText(
                      text: "When someone invites you, it will show up here",
                      fontSize: 14,
                      color: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification =
                              notificationsState
                                  .data!
                                  .invitationNotifications[index];
                          return NotificationCard(notification: notification);
                        },
                        childCount:
                            notificationsState
                                .data!
                                .invitationNotifications
                                .length,
                      ),
                    ),
                  ),
                  if (notificationsState.hasMore ||
                      notificationsState.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child:
                            notificationsState.isLoadingMore
                                ? Center(child: CircularProgressIndicator())
                                : TextButton(
                                  onPressed: _loadMore,
                                  child: Center(
                                    child: DesignText(
                                      text: "Show more",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: DesignColors.accent,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                ],
              ),
    );
  }

  String formatDate(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    // If less than a minute
    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    // If less than an hour
    else if (difference.inMinutes < 60) {
      final int minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    // If less than a day
    else if (difference.inHours < 24) {
      final int hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    // If less than a week
    else if (difference.inDays < 7) {
      final int days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    // If in the same year
    else if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime); // e.g., "Jun 15"
    }
    // Otherwise show full date
    else {
      return DateFormat('MMM d, yyyy').format(dateTime); // e.g., "Jun 15, 2023"
    }
  }
}

// Add NotificationItem widget
class NotificationItem extends StatelessWidget {
  final NotificationBaseModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: DesignText(
        text: notification.title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      subtitle: DesignText(
        text: notification.body,
        fontSize: 12,
        color: Colors.grey,
      ),
      // Add more UI elements based on notification type
    );
  }
}
