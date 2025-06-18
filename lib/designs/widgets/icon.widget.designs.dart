import 'package:aroundu/designs/icons.designs.dart';
import 'package:aroundu/utils/either.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../colors.designs.dart';

class DesignIcon extends StatelessWidget {
  final Either<DesignIcons, IconData> icon;
  final double size;
  final Color? color;

  const DesignIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
  });

  factory DesignIcon.custom({
    Key? key,
    required DesignIcons icon,
    double size = 24,
    Color? color,
  }) {
    return DesignIcon(
      key: key,
      icon: Either.left(icon),
      size: size,
      color: color,
    );
  }

  factory DesignIcon.icon({
    Key? key,
    required IconData icon,
    double size = 24,
    Color color = DesignColors.primary,
  }) {
    return DesignIcon(
      key: key,
      icon: Either.right(icon),
      size: size,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: icon.isLeft
          ? SvgPicture.asset(
              icon.left!.path,
              fit: BoxFit.fitWidth,
              height: size,
              width: size,
              colorFilter: color != null
                  ? ColorFilter.mode(
                      color!,
                      BlendMode.srcIn,
                    )
                  : null,
            )
          : Icon(
              icon.right!,
              size: size,
              weight: 1.5,
              color: color,
            ),
    );
  }
}
