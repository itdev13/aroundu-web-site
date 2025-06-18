import 'package:flutter/material.dart';

class RoundedRectangleTabIndicator extends Decoration {
  final BoxPainter _painter;
  final double paddingH;
  final double paddingV;

  RoundedRectangleTabIndicator({
    required Color color,
    required double radius,
    required this.paddingH,
    required this.paddingV,
  }) : _painter = _RoundedRectanglePainter(
         color: color,
         radius: radius,
         paddingH: paddingH,
         paddingV: paddingV,
       );

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _RoundedRectanglePainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double paddingH;
  final double paddingV;

  _RoundedRectanglePainter({
    required Color color,
    required this.radius,
    required this.paddingH,
    required this.paddingV,
  }) : _paint =
           Paint()
             ..color = color
             ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;

    final insetRect = Rect.fromLTRB(
      rect.left - paddingH,
      rect.top - paddingV,
      rect.right + paddingH,
      rect.bottom + paddingV,
    );

    final RRect roundedRect = RRect.fromRectAndRadius(
      insetRect,
      Radius.circular(radius),
    );

    canvas.drawRRect(roundedRect, _paint);
  }
}
