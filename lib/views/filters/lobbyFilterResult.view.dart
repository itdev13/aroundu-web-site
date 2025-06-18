import 'dart:math';

import 'package:aroundu/designs/widgets/lobby_card.widgets.designs.dart';
import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/views/house/view_all_house_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';

import '../../models/lobby.dart';
import 'package:aroundu/designs/colors.designs.dart';

class LobbyFilterResultView extends StatefulWidget {
  const LobbyFilterResultView({super.key, required this.results});
  final FilterResponse results;
  @override
  State<LobbyFilterResultView> createState() => _LobbyFilterResultViewState();
}

class _LobbyFilterResultViewState extends State<LobbyFilterResultView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalResults =
        widget.results.lobbies.length +
        widget.results.houses.length +
        widget.results.users.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: DesignText(
          text: "Results",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF444444),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignColors.accent,
          unselectedLabelColor: DesignColors.secondary,
          indicatorColor: DesignColors.accent,
          indicatorWeight: 3,
          isScrollable: false, // Make tabs scrollable to prevent cropping
          labelPadding: EdgeInsets.symmetric(
            horizontal: 8,
          ), // Add padding for better spacing
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(text: "All ($totalResults)"),
            Tab(text: "Lobbies (${widget.results.lobbies.length})"),
            Tab(text: "Houses (${widget.results.houses.length})"),
            Tab(text: "Users (${widget.results.users.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(),
          _buildLobbiesTab(),
          _buildHousesTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.results.lobbies.isNotEmpty) ...[
            _buildSectionHeader("Lobbies", widget.results.lobbies.length, () {
              _tabController.animateTo(1);
            }),
            _buildLobbiesSection(limit: 5),
            Space.h(height: 24),
          ],
          if (widget.results.houses.isNotEmpty) ...[
            _buildSectionHeader("Houses", widget.results.houses.length, () {
              _tabController.animateTo(2);
            }),
            _buildHousesSection(limit: 5),
            Space.h(height: 24),
          ],
          if (widget.results.users.isNotEmpty) ...[
            _buildSectionHeader("Users", widget.results.users.length, () {
              _tabController.animateTo(3);
            }),
            _buildUsersSection(),
            Space.h(height: 24),
          ],
          if (widget.results.lobbies.isEmpty &&
              widget.results.houses.isEmpty &&
              widget.results.users.isEmpty)
            SizedBox(
              height: 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: const Color(0xFF989898),
                    ),
                    Space.h(height: 16),
                    DesignText(
                      text: "No results found",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF444444),
                    ),
                    Space.h(height: 8),
                    DesignText(
                      text: "Try adjusting your search criteria",
                      fontSize: 14,
                      color: const Color(0xFF989898),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLobbiesTab() {
    if (widget.results.lobbies.isEmpty) {
      return _buildEmptyState('No lobbies found', CupertinoIcons.group);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignText(
            text: 'Lobbies (${widget.results.lobbies.length})',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16),
          _buildLobbiesVerticalSection(),
        ],
      ),
    );
  }

  Widget _buildHousesTab() {
    if (widget.results.houses.isEmpty) {
      return _buildEmptyState('No houses found', CupertinoIcons.house);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignText(
            text: 'Houses (${widget.results.houses.length})',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16),
          _buildHousesVerticalSection(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (widget.results.users.isEmpty) {
      return _buildEmptyState('No users found', CupertinoIcons.person);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: DesignText(
              text: 'Users (${widget.results.users.length})',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildUsersVerticalSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, VoidCallback onViewAll) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DesignText(text: title, fontSize: 18, fontWeight: FontWeight.w600),
          if (count > 3)
            TextButton(
              onPressed: onViewAll,
              child: DesignText(
                text: "View All",
                fontSize: 12,
                color: const Color(0xFF3E79A1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLobbiesSection({int? limit}) {
    final lobbies =
        limit != null
            ? widget.results.lobbies.take(limit).toList()
            : widget.results.lobbies;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    final scrollController = ScrollController();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: min(231, constraints.maxHeight * 0.6),
          child: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: lobbies.length,
                padding: EdgeInsets.symmetric(horizontal: 12),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final lobby = lobbies[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == lobbies.length - 1 ? sw(0.01) : 16,
                      left: index == 0 ? sw(0.01) : 0,
                      bottom: 8,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 450,
                        // maxWidth: min(650, 750),
                        minWidth: 200,
                      ),
                      child: DesignLobbyWidget(
                        lobby: lobby,
                        hasCoverImage: lobby.mediaUrls.isNotEmpty,
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                right: 0,
                bottom: (min(231, constraints.maxHeight * 0.6)) / 2,
                child: GestureDetector(
                  onTap: () {
                    try {
                      if (scrollController.position.pixels <
                          scrollController.position.maxScrollExtent) {
                        scrollController.animateTo(
                          scrollController.position.pixels + min(650, 750),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                      }
                    } catch (e, s) {
                      print("$e \n $s");
                    }
                  },
                  child: Container(
                    width: min(sw(0.08), 40),
                    height: min(sw(0.08), 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(124),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                bottom: (min(231, constraints.maxHeight * 0.6)) / 2,
                child: GestureDetector(
                  onTap: () {
                    try {
                      if (scrollController.position.pixels > 0) {
                        scrollController.animateTo(
                          scrollController.position.pixels - min(650, 750),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                      }
                    } catch (e, s) {
                      print("$e \n $s");
                    }
                  },
                  child: Container(
                    width: min(sw(0.08), 40),
                    height: min(sw(0.08), 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(124),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHousesSection({int? limit}) {
    final houses =
        limit != null
            ? widget.results.houses.take(limit).toList()
            : widget.results.houses;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    final scrollController = ScrollController();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: min(231, constraints.maxHeight * 0.6),
          child: Stack(
            children: [
              ListView.builder(
                // scrollDirection: Axis.horizontal,
                // options: CarouselOptions(
                //   height: 0.24.sh,
                //   viewportFraction: 0.8,
                //   enlargeCenterPage: true,
                //   enlargeFactor: 0,
                // ),
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: houses.length,
                padding: EdgeInsets.symmetric(horizontal: 12),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final house = houses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == houses.length - 1 ? sw(0.01) : 16,
                      left: index == 0 ? sw(0.01) : 0,
                      bottom: 8,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 450,
                        // maxWidth: min(650, 750),
                        minWidth: 200,
                      ),
                      child: ViewAllHouseCard(
                        house: house,
                        onHouseDeleted: () {},
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 0,
                bottom: (min(231, constraints.maxHeight * 0.6)) / 2,
                child: GestureDetector(
                  onTap: () {
                    try {
                      if (scrollController.position.pixels <
                          scrollController.position.maxScrollExtent) {
                        scrollController.animateTo(
                          scrollController.position.pixels + min(650, 750),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                      }
                    } catch (e, s) {
                      print("$e \n $s");
                    }
                  },
                  child: Container(
                    width: min(sw(0.08), 40),
                    height: min(sw(0.08), 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(124),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                bottom: (min(231, constraints.maxHeight * 0.6)) / 2,
                child: GestureDetector(
                  onTap: () {
                    try {
                      if (scrollController.position.pixels > 0) {
                        scrollController.animateTo(
                          scrollController.position.pixels - min(650, 750),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                      }
                    } catch (e, s) {
                      print("$e \n $s");
                    }
                  },
                  child: Container(
                    width: min(sw(0.08), 40),
                    height: min(sw(0.08), 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(124),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersSection({int? limit}) {
    final users =
        limit != null
            ? widget.results.users.take(limit).toList()
            : widget.results.users;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 800 ? 5 : screenWidth > 600 ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0, // Perfect square ratio
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(FilterSearchUsersCompactModel user) {
    return GestureDetector(
      onTap: () {
        // Navigate to user profile or show more details
        // Get.to(() => ProfileDetailsScreen(userId: user.id));
        //  Get.to(() => ProfileView());
        //TODO : add profilescreen
      },
      child: Container(
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 0.3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section - Square shape
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DesignColors.accent.withOpacity(0.05),
                    DesignColors.accent.withOpacity(0.02),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child:
                    user.profilePictureUrl.isNotEmpty
                        ? Image.network(
                          user.profilePictureUrl,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildProfilePlaceholder();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: DesignColors.accent,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        )
                        : _buildProfilePlaceholder(),
              ),
            ),
            // User Info Section - Compact
            Space.h(height: 8), // Add some space between the image and text
            DesignText(
              text: user.name,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            DesignText(
              text: "@${user.userName}",
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (user.address['city'] != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 10,
                    color: DesignColors.accent.withOpacity(0.7),
                  ),
                  Space.w(width: 1),
                  Flexible(
                    child: DesignText(
                      text: user.address['city'],
                      fontSize: 10,
                      color: DesignColors.secondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      color: DesignColors.bg,
      height: 75,
      child: Center(
        child: Icon(
          Icons.person,
          size: 30,
          color: DesignColors.secondary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildLobbiesVerticalSection() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.results.lobbies.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lobby = widget.results.lobbies[index];
        return DesignLobbyWidget(
          lobby: lobby,
          hasCoverImage: lobby.mediaUrls.isNotEmpty,
        );
      },
    );
  }

  Widget _buildHousesVerticalSection() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.results.houses.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final house = widget.results.houses[index];
        return ViewAllHouseCard(house: house, onHouseDeleted: () {});
      },
    );
  }

  Widget _buildUsersVerticalSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: widget.results.users.length,
        itemBuilder: (context, index) {
          final user = widget.results.users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFF989898)),
          SizedBox(height: 16),
          DesignText(
            text: message,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF989898),
          ),
        ],
      ),
    );
  }
}

class FilterResponse {
  final int lobbiesCount;
  final int housesCount;
  final int usersCount;
  final List<Lobby> lobbies;
  final List<House> houses;
  final List<FilterSearchUsersCompactModel> users;

  FilterResponse({
    this.lobbiesCount = 0,
    this.housesCount = 0,
    this.usersCount = 0,
    List<Lobby>? lobbies,
    List<House>? houses,
    List<FilterSearchUsersCompactModel>? users,
  }) : lobbies = lobbies ?? [],
       houses = houses ?? [],
       users = users ?? [];

  factory FilterResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FilterResponse();
    }

    return FilterResponse(
      lobbiesCount: json['lobbiesCount'] as int? ?? 0,
      housesCount: json['housesCount'] as int? ?? 0,
      lobbies:
          (json['lobbies'] as List<dynamic>?)
              ?.map((e) => Lobby.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      houses:
          (json['houses'] as List<dynamic>?)
              ?.map((e) => House.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      users:
          (json['users'] as List<dynamic>?)
              ?.map(
                (e) => FilterSearchUsersCompactModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  // Map<String, dynamic> toJson() => {
  //       'lobbiesCount': lobbiesCount,
  //       'housesCount': housesCount,
  //       'lobbies': lobbies.map((e) => e.toJson()).toList(),
  //       'houses': houses.map((e) => e.toJson()).toList(),
  //     };

  FilterResponse copyWith({
    int? lobbiesCount,
    int? housesCount,
    List<Lobby>? lobbies,
    List<House>? houses,
  }) {
    return FilterResponse(
      lobbiesCount: lobbiesCount ?? this.lobbiesCount,
      housesCount: housesCount ?? this.housesCount,
      lobbies: lobbies ?? this.lobbies,
      houses: houses ?? this.houses,
    );
  }
}

class FilterSearchUsersCompactModel {
  final String id;
  final String name;
  final String userName;
  final String profilePictureUrl;
  final Map<String, dynamic> address;

  FilterSearchUsersCompactModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.profilePictureUrl,
    required this.address,
  });

  factory FilterSearchUsersCompactModel.fromJson(Map<String, dynamic> json) {
    return FilterSearchUsersCompactModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      userName: json['userName'] ?? "",
      profilePictureUrl: json['profilePictureUrl'] ?? "",
      address: json['address'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userName': userName,
    'profilePictureUrl': profilePictureUrl,
    'address': {
      'country': address['country'],
      'state': address['state'],
      'city': address['city'],
      'zipCode': address['zipCode'],
      'streetName': address['streetName'],
      'buildingNumber': address['buildingNumber'],
    },
  };
}
