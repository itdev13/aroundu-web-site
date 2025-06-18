import 'dart:convert';

import 'package:aroundu/views/lobby/widgets/rich_text_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

class RichTextDisplay extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String?)? onChanged;
  final bool isEditing;
  // final double? minHeight;
  final double? maxHeight;
  final int? fontSize;
  const RichTextDisplay({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.isEditing = false,
    this.maxHeight,
    // this.minHeight,
    this.fontSize,
  });

  @override
  State<RichTextDisplay> createState() => _RichTextDisplayState();
}

class _RichTextDisplayState extends State<RichTextDisplay> {
  late QuillController _quillController;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    try {
      if (widget.controller.text.isNotEmpty) {
        // Try to parse as JSON first
        try {
          final delta = jsonDecode(widget.controller.text);
          _quillController = QuillController(
            document: Document.fromJson(delta),
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          );
        } catch (e) {
          // If not valid JSON, treat as plain text
          _quillController = QuillController.basic();
          _quillController.document.insert(0, widget.controller.text);
          _quillController.readOnly = true;
        }
      } else {
        _quillController = QuillController.basic();
        _quillController.document.insert(0, widget.hintText);
         _quillController.formatText(0, widget.hintText.length,
            Attribute.fromKeyValue('color', '#979797'));
        _quillController.readOnly = true;
      }
      setState(() {
        _isLoaded = true;
      });
    } catch (e) {
      // Fallback for any errors
      _quillController = QuillController.basic();
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  void didUpdateWidget(RichTextDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.text != widget.controller.text) {
      _initializeController();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  void _navigateToEditor() async {
    final result = await Get.to<String>(() => RichTextEditorScreen(
          initialContent: widget.controller.text,
          title: widget.hintText,
        ));

    if (result != null) {
      widget.controller.text = result;
      if (widget.onChanged != null) {
        widget.onChanged!(result);
      }
      _initializeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    if (!_isLoaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap:
          widget.isEditing ?
          _navigateToEditor
      : null,
      child: Container(
        padding: (widget.maxHeight!=null)? EdgeInsets.symmetric(vertical: 4) : EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: widget.isEditing
              ? Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                )
              : null,
        ),
        child:
            //  widget.controller.text.isEmpty
            //     ? DesignText(
            //         text: widget.hintText,
            //         fontSize: 14.sp,
            //         color: Colors.grey,
            //       )
            //     :
            QuillEditor.basic(
          controller: _quillController,
          // readOnly: true,
          config: QuillEditorConfig(
            placeholder: widget.hintText,
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: widget.fontSize?.toDouble() ?? 14,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                const HorizontalSpacing(
                    0, 0), // Added missing horizontal spacing
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                null,
              ),
            ),
            padding: EdgeInsets.zero,
            showCursor: false,
            autoFocus: false,
            // readOnly: true,
            expands: false,
            scrollable: true,
            enableInteractiveSelection: false,
            enableSelectionToolbar: false,
            // minHeight: 100.h,
            maxHeight: (widget.maxHeight!=null)? widget.maxHeight : widget.isEditing ? sh(0.4) : sh(0.2),
          ),
        ),
      ),
    );
  }
}
