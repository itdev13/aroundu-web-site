import 'package:aroundu/designs/utils.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/views/house/view_all_house_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../designs/widgets/lobby_card.widgets.designs.dart';

class ViewAllLobbiesExplore extends StatefulWidget {
  const ViewAllLobbiesExplore({
    super.key,
    required this.title,
    required this.lobbies,
  });
  final String title;
  final List<Lobby> lobbies;

  @override
  State<ViewAllLobbiesExplore> createState() => _ViewAllLobbiesExploreState();
}

class _ViewAllLobbiesExploreState extends State<ViewAllLobbiesExplore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: DesignText(
          text: widget.title,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF444444),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: ScreenBuilder(
          phoneLayout: _buildGridView(context, 1),
          tabletLayout: _buildGridView(context, 2),
          desktopLayout: _buildGridView(context, 3),
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, int crossAxisCount) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        // childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 231, // Keep the same height as before
      ),
      itemCount: widget.lobbies.length,
      itemBuilder: (context, index) {
        return ConstrainedBox(
          constraints: BoxConstraints(
             maxWidth: 450,
            minWidth: 200,
          ),
          child: DesignLobbyWidget(
            lobby: widget.lobbies[index],
            hasCoverImage: widget.lobbies[index].mediaUrls.isNotEmpty,
          ),
        );
      },
    );
  }
}

class ViewAllHousesExplore extends StatefulWidget {
  const ViewAllHousesExplore({
    super.key,
    required this.title,
    required this.houses,
  });
  final String title;
  final List<House> houses;

  @override
  State<ViewAllHousesExplore> createState() => _ViewAllHousesExploreState();
}

class _ViewAllHousesExploreState extends State<ViewAllHousesExplore> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: DesignText(
          text: widget.title,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF444444),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: ScreenBuilder(
          phoneLayout: _buildGridView(context, 1),
          tabletLayout: _buildGridView(context, 2),
          desktopLayout: _buildGridView(context, 3),
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, int crossAxisCount) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 231, // Keep the same height as before
      ),
      itemCount: widget.houses.length,
      itemBuilder: (context, index) {
        return ConstrainedBox(
          constraints: BoxConstraints(
             maxWidth: 450,
            // maxWidth: min(650, 750),
            minWidth: 200,
          ),
          child: ViewAllHouseCard(
            house: widget.houses[index],
            onHouseDeleted: () {},
          ),
        );
      },
    );
  }
}
