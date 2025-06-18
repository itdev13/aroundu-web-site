import 'package:flutter/material.dart';

class DashDivider extends StatelessWidget {
  final Color color;
  final double dashHeight;
  final double dashWidth;
  final double dashSpace;

  const DashDivider({
    super.key,
    this.color = Colors.black,
    this.dashHeight = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Add a safety check to prevent infinity or NaN values
        final width = constraints.constrainWidth();
        if (width <= 0 || !width.isFinite) {
          return Container(); // Return empty container if width is invalid
        }

        final dashCount = (width / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
