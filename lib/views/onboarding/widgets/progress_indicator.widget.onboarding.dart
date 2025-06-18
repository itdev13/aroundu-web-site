import 'package:flutter/material.dart';

import '../../../designs/colors.designs.dart';

class OnboardingProgressIndicatorWidget extends StatelessWidget {
  final bool isCompleted;
  final double thickness;

  const OnboardingProgressIndicatorWidget({
    super.key,
    required this.isCompleted,
    this.thickness = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        color: isCompleted ? DesignColors.accent : DesignColors.onBg,
        thickness: thickness,
      ),
    );
  }
}
