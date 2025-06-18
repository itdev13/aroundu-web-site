import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:flutter/material.dart';

class WrapperRangeSlider extends StatefulWidget {
  const WrapperRangeSlider({
    super.key,
    required this.min,
    required this.max,
    required this.selectedMin,
    required this.selectedMax,
    required this.handleChange,
  });

  final double min;
  final double max;
  final double selectedMin;
  final double selectedMax;
  final void Function(double, double) handleChange;

  @override
  State<WrapperRangeSlider> createState() => _WrapperRangeSlider();
}

class _WrapperRangeSlider extends State<WrapperRangeSlider> {
  @override
  Widget build(BuildContext context) {
    RangeValues currentRangeValues =
        RangeValues(widget.selectedMin, widget.selectedMax);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: CustomRangeSliderThumbShape(thumbRadius: 3.0),
            activeTrackColor: DesignColors.accent,
            inactiveTrackColor: Colors.grey,
            thumbColor: DesignColors.accent,
          ),
          child: RangeSlider(
            values: currentRangeValues,
            min: widget.min,
            max: widget.max,
            divisions: 100,
            onChanged: (RangeValues values) {
              print("testing field");
              print(widget.max);
              print(values.start+values.end);
              widget.handleChange(values.start, values.end);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DesignText(
              text: '${currentRangeValues.start.round()}',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            DesignText(
              text: '${currentRangeValues.end.round()}',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ],
    );
  }
}

class CustomRangeSliderThumbShape extends RoundSliderThumbShape {
  CustomRangeSliderThumbShape({required this.thumbRadius});
  final double thumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, paint);
  }
}
