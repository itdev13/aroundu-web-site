import 'package:flutter/material.dart';


import '../colors.designs.dart';
import 'text.widget.designs.dart';

class DesignButton extends StatelessWidget {
  final Widget? child;
  final String? title;
  final void Function() onPress;
  final Color bgColor;
  final Color? titleColor;
  final double titleSize;
  final EdgeInsets? padding;
  final bool isLoading;
  final bool isEnabled;
  final OutlinedBorder? shape;

  const DesignButton({
    super.key,
    required this.onPress,
    this.child,
    this.title,
    this.titleSize = 18,
    this.isLoading = false,
    this.padding,
    this.bgColor = DesignColors.accent,
    this.titleColor = DesignColors.white,
    this.isEnabled = true,
    this.shape,
  })  : assert(
          child != null || title != null,
          'Either child or title must be provided',
        ),
        assert(
          !(child != null && title != null),
          'Only one of child or title should be provided, not both',
        );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shadowColor: Colors.transparent,
        padding: padding ?? EdgeInsets.symmetric(vertical: 10),
        shape: shape,
      ),

      // debounce if the state is in loading
      onPressed: isEnabled ? (isLoading ? () {} : onPress) : null,
      child: isLoading
          ? Center(
              child: Container(
                margin: EdgeInsets.all(2),
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  color: DesignColors.white,
                  strokeWidth: 3,
                ),
              ),
            )
          : child ??
              DesignText(
                text: title!,
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
    );
  }
}
