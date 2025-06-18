import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/fonts.designs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



enum WrapperTextFieldSuffixStyle {
  text,
  contained,
  outlined,
}

class WrapperTextField extends StatefulWidget {
  const WrapperTextField(
      {super.key,
      this.text,
      this.onChanged,
      this.suffixOnPressed,
      this.hintText,
      this.suffixIcon,
      this.suffixText,
      this.maxLines,
      this.suffixStyle = WrapperTextFieldSuffixStyle.text,
      this.enabled = true,
      this.inputType = 'STRING'});

  final String? text;
  final void Function(String)? onChanged;
  final void Function()? suffixOnPressed;
  final String? hintText;
  final IconData? suffixIcon;
  final String? suffixText;
  final int? maxLines;
  final WrapperTextFieldSuffixStyle suffixStyle;
  final bool enabled;
  final String? inputType;

  @override
  State<WrapperTextField> createState() => _WrapperTextFieldState();
}

class _WrapperTextFieldState extends State<WrapperTextField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant WrapperTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the text controller if the external text value changes
    if (widget.text != oldWidget.text) {
      _textController.text = widget.text ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When onChanged is null, I want to just enable onTap no keyboard

    return TextField(
      controller: _textController,
      // focusNode: FocusNode(),
      enabled: widget.enabled,
      readOnly: widget.onChanged == null,
      maxLines: widget.maxLines ?? 1,
      onChanged: widget.onChanged,
      onTap: widget.onChanged == null ? widget.suffixOnPressed : null,
      inputFormatters:
          isDigitsOnly ? [FilteringTextInputFormatter.digitsOnly] : [],
      keyboardType: textInputType,
      decoration: InputDecoration(
        filled: true, // Enables background color
        fillColor: Colors.white,
        counterStyle: DesignFonts.poppins.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w300,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: DesignColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: DesignColors.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: DesignColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: DesignColors.accent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        errorStyle: DesignFonts.poppins.copyWith(
          color: DesignColors.accent,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        hintText: widget.hintText,
        hintStyle: DesignFonts.poppins.copyWith(
          color: DesignColors.primary.withOpacity(0.6),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  TextInputType get textInputType => switch (widget.inputType) {
        'STRING' => TextInputType.text,
        'FLOAT' => const TextInputType.numberWithOptions(decimal: true),
        'INTEGER' =>
          const TextInputType.numberWithOptions(decimal: false, signed: false),
        _ => TextInputType.text,
      };

  bool get isDigitsOnly => widget.inputType == 'INTEGER';
}
