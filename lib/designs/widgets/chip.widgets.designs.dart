import 'package:flutter/material.dart';

import '../colors.designs.dart';
import 'text.widget.designs.dart';

class DesignChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const DesignChip({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.showCloseAction = false,
    this.textColor = Colors.black,
    this.borderColor = DesignColors.border,
    this.filledColor = const Color(0xFFEAEFF2),
    this.trailingIcon,
    this.onCloseClicked,
  })  : fontSize = 16,
        vPadding = 6,
        hPadding = 10,
        radius = 10,
        isFilled = false;
  const DesignChip.medium({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 12,
    this.showCloseAction = false,
    this.textColor = Colors.black,
    this.borderColor = DesignColors.border,
    this.filledColor = const Color(0xFFEAEFF2),
    this.trailingIcon,
    this.isFilled = false,
    this.onCloseClicked,
  })  : vPadding = 4,
        hPadding = 8,
        radius = 15;

  const DesignChip.large({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.showCloseAction = false,
    this.textColor = Colors.black,
    this.borderColor = DesignColors.border,
    this.fontSize = 16,
    this.filledColor = const Color(0xFFEAEFF2),
    this.trailingIcon,
    this.onCloseClicked,
  })  : vPadding = 6,
        hPadding = 15,
        radius = 20,
        isFilled = false;

  const DesignChip.small({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.showCloseAction = false,
    this.textColor = Colors.black,
    this.borderColor = DesignColors.border,
    this.onCloseClicked,
    this.vPadding = 2,
    this.hPadding = 4,
    this.filledColor = const Color(0xFFEAEFF2),
    this.trailingIcon,
  })  : fontSize = 10,
        radius = 4,
        isFilled = false;

  const DesignChip.filled({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.fontSize = 12,
    this.showCloseAction = false,
    this.textColor = Colors.black,
    this.borderColor = DesignColors.border,
    this.radius = 15,
    this.filledColor = const Color(0xFFEAEFF2),
    this.trailingIcon,
    this.onCloseClicked,
  })  : vPadding = 4,
        hPadding = 8,
        isFilled = true;

  final double fontSize;
  final double vPadding;
  final double hPadding;
  final double radius;
  final Color borderColor;
  final Color textColor;
  final bool isFilled;
  final Color filledColor;
  final bool showCloseAction;
  final Widget? trailingIcon;
  final VoidCallback? onCloseClicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      splashColor: Colors.transparent,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: title,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: vPadding,
            horizontal: hPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignColors.accent.withOpacity(0.15)
                : isFilled
                    ? filledColor
                    : null,
            border: Border.all(
              color: isSelected ? DesignColors.accent : borderColor,
              width: isSelected ? 1 : 1.5,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DesignText(
                text: title,
                fontSize: fontSize,
                color: textColor,
              ),
              if (!showCloseAction && trailingIcon != null) ...[
                SizedBox(width: 4),
                trailingIcon!,
              ],
              if (showCloseAction) ...[
                SizedBox(width: 4),
                GestureDetector(
                  onTap: onCloseClicked,
                  child: const Icon(
                    Icons.close_rounded,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
