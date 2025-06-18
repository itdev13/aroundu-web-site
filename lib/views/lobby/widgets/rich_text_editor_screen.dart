import 'dart:convert';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

class RichTextEditorScreen extends StatefulWidget {
  final String initialContent;
  final String title;

  const RichTextEditorScreen({
    super.key,
    required this.initialContent,
    required this.title,
  });

  @override
  State<RichTextEditorScreen> createState() => _RichTextEditorScreenState();
}

class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
  late QuillController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize the Quill controller with the initial content
    if (widget.initialContent.isNotEmpty) {
      try {
        // Try to parse the initial content as Delta JSON
        final delta = jsonDecode(widget.initialContent);
        _controller = QuillController(
          document: Document.fromJson(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If parsing fails, create a new document with the text as plain text
        _controller = QuillController.basic();
        _controller.document.insert(0, widget.initialContent);
      }
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveContent() {
    final delta = _controller.document.toDelta();
    final jsonContent = jsonEncode(delta.toJson());
    Get.back(result: jsonContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DesignText(
          text: widget.title,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: DesignIcon.icon(
            icon: Icons.arrow_back_ios_sharp,
            size: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              multiRowsDisplay: true,
              showDividers: false,
              showFontFamily: false,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: true,
              showUnderLineButton: true,
              showLineHeightButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: true,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: true,
              showLeftAlignment: true,
              showCenterAlignment: true,
              showRightAlignment: true,
              showJustifyAlignment: true,
              showHeaderStyle: true,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: true,
              showLink: true,
              showUndo: false,
              showRedo: false,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
              toolbarIconAlignment: WrapAlignment.start,
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  iconTheme: QuillIconTheme(
                    iconButtonSelectedData: IconButtonData(
                      color: DesignColors.accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: QuillEditor.basic(
                  controller: _controller,
                  config: QuillEditorConfig(
                    placeholder: 'Write your description here...',
                    padding: EdgeInsets.all(16),
                    autoFocus: false,
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        const HorizontalSpacing(
                            0, 0), // Added missing horizontal spacing
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: DesignButton(
              onPress: () {
                if (!_isLoading) _saveContent();
              },
              bgColor: DesignColors.accent,
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : DesignText(
                        text: "Save",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
