import 'dart:convert';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Response;

class NewMarkdownEditorPage extends ConsumerStatefulWidget {
  final String lobbyId;
  final String initialTitle;
  final String initialBody;
  final bool isHost;

  const NewMarkdownEditorPage({
    super.key,
    required this.lobbyId,
    required this.initialTitle,
    required this.initialBody,
    this.isHost = false,
  });

  @override
  ConsumerState<NewMarkdownEditorPage> createState() => _NewMarkdownEditorPageState();
}

class _NewMarkdownEditorPageState extends ConsumerState<NewMarkdownEditorPage> {
  late QuillController _controller;
  late TextEditingController _titleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);

    // Initialize the Quill controller with the initial content
    if (widget.initialBody.isNotEmpty) {
      try {
        // Try to parse the initial body as Delta JSON
        final delta = jsonDecode(widget.initialBody);
        _controller = QuillController(
          document: Document.fromJson(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If parsing fails, create a new document with the text as plain text
        _controller = QuillController.basic();
        _controller.document.insert(0, widget.initialBody);
      }
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<Response?> saveContentApi({
    required String lobbyId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final postRequestUrl =
          'https://api.aroundu.in/match/lobby/content/$lobbyId';

      final response = await ApiService().put(
        postRequestUrl,
        body: payload,
        // (json) => json, // simple passthrough parser
      );

      if (response.data['status'] == 'SUCCESS') {
        print("Form updated successfully: ${response.data['message']}");
      } else {
        print("Failed to update form: ${response.data['message']}");
      }

      return response;
    } catch (e) {
      print("API Error while updating form: $e");
      rethrow;
    }
  }

  Future<void> _saveContent() async {
    if (_titleController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Please enter a title",
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final delta = _controller.document.toDelta();
      final jsonContent = jsonEncode(delta.toJson());

      final payload = {
        "title": _titleController.text.trim(),
        "body": jsonContent.toString(),
      };
      kLogger.info(payload.toString());
      final response = await saveContentApi(lobbyId: widget.lobbyId, payload: payload);
      if (response != null && (response.statusCode == 200 || response.data["status"] == "SUCCESS")) {
       
          CustomSnackBar.show(
            context: context,
            message: "Content saved successfully",
            type: SnackBarType.success,
          );
          ref.read(lobbyDetailsProvider(widget.lobbyId).notifier).reset();
         ref
            .read(lobbyDetailsProvider(widget.lobbyId).notifier)
            .fetchLobbyDetails(widget.lobbyId);
          Get.back();
        
      } else {
        CustomSnackBar.show(
          context: context,
          message: "Failed to save content",
          type: SnackBarType.error,
        );
      }
    } catch (e,s) {
      kLogger.error(e.toString(), error: e, stackTrace: s);
      CustomSnackBar.show(
        context: context,
        message: "An error occurred",
        type: SnackBarType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          text:
              // widget.isHost
              //     ? "Edit Community Guidelines"
              //     :
              "Community Guidelines",
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
          if (widget.isHost) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: DesignTextField(
                controller: _titleController,
                hintText: "add title here",
                minLines: 1,
                maxLines: 10,
              ),
            ),
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
          ],
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
                    // readOnly: !widget.isHost,
                    placeholder: 'Write your community guidelines here...',
                    padding: EdgeInsets.all(16),
                    autoFocus: false,
                  ),
                ),
              ),
            ),
          ),
          if (widget.isHost)
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
                          text: "Save Guidelines",
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
