import 'package:flutter/material.dart';


class Space extends StatelessWidget {
  final double? width;
  final double? height;

  const Space.h({super.key, required this.height, this.width = 0});

  const Space.w({super.key, required this.width, this.height = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
