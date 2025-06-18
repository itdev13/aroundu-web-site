import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/fonts.designs.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color textColor;

  const CustomChip({
    super.key,
    required this.text,
    this.fontSize = 12.0,
    this.color = ColorsPalette.grayColor,
    this.textColor = ColorsPalette.blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.transparent),
      ),
      child: Text(
        text,
        style: DesignFonts.poppins.merge(TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          
        )),
      ),
    );
  }
}
