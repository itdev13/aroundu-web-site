import 'package:flutter/material.dart';

import '../fonts.designs.dart';

class DesignText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextStyle? style;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;

  const DesignText({
    super.key,
    required this.text,
    required this.fontSize,
    this.fontWeight,
    this.style,
    this.textAlign,
    this.color,
    this.maxLines,
    this.softWrap,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: softWrap,
      style: DesignFonts.poppins.merge(
        style ??
            TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
      ),
    );
  }
}
