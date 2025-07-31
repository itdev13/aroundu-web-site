import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:flutter/material.dart';

class CustomTabBarView extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final ScrollController? mainScrollController;

  const CustomTabBarView({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.mainScrollController,
  }) : assert(
            tabs.length == tabViews.length, 'Tabs and Views count must match');

  @override
  _CustomTabBarViewState createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              widget.tabs.length,
              (index) => GestureDetector(
                onTap: () {
                  if (widget.mainScrollController != null) {
                    widget.mainScrollController?.animateTo(
                      widget.mainScrollController!.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutSine,
                    );
                  }
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? ColorsPalette.lightGrayColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    widget.tabs[index],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: _currentIndex == index
                          ? DesignColors.secondary
                          : ColorsPalette.grayColor,
                      fontSize: _currentIndex == index ? 15 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: widget.tabViews[_currentIndex],
        ),
      ],
    );
  }
}
