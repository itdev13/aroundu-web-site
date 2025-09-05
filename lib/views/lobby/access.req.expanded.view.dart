import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/access_request.lobby.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/file_view_helpers/image_viewer.dart';
import 'package:aroundu/views/file_view_helpers/pdf_viewer.dart';
import 'package:aroundu/views/file_view_helpers/video_viewer.dart';
import 'package:aroundu/views/lobby/provider/access_request_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../designs/colors.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import 'access_request.view.dart';

class AccessRequestPage extends StatelessWidget {
  const AccessRequestPage({
    super.key,
    required this.request,
    required this.lobbyId,
    required this.isGroup,
  });
  final Request request;
  final String lobbyId;
  final bool isGroup;
  @override
  Widget build(BuildContext context) {
    kLogger.trace('AccessRequestPage build');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const DesignText(
            text: 'Access Request',
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black)),
      ),
      body: isGroup
          ? ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                const SectionHeader(title: 'Admin details'),
                ...?request.groupData?.userInfos
                    .where((user) => user.isAdmin == true)
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AccessCard(
                          user: user,
                          isGroup: true,
                          request: request,
                          groupData: request.groupData,
                          lobbyId: lobbyId,
                        ),
                      ),
                    ),
                const SectionHeader(title: 'Guest details'),
                ...?request.groupData?.userInfos
                    .where((user) => user.isAdmin != true)
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AccessCard(
                          user: user,
                          isGroup: true,
                          request: request,
                          groupData: request.groupData,
                          lobbyId: lobbyId,
                        ),
                      ),
                    ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                const SectionHeader(title: 'Guest details'),
                AccessCard(
                  request: request,
                  lobbyId: lobbyId,
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return DesignText(
      text: title,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }
}

final expandedCardProvider =
    StateProvider.family<bool, String>((ref, id) => false);

class AccessCard extends ConsumerWidget {
  const AccessCard({
    super.key,
    this.user,
    required this.request,
    this.groupData,
    required this.lobbyId,
    this.isGroup = false,
  });
  final UserInfo? user;
  final Request request;
  final GroupData? groupData;
  final bool isGroup;
  final String lobbyId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate a unique ID for this card
    final String cardId =
        isGroup ? user?.userId ?? "" : request?.accessRequestId ?? "";

    // Watch the expanded state for this specific card
    final isExpanded = ref.watch(expandedCardProvider(cardId));

    // Get the form questions based on user or request
    final formQuestions =
        isGroup ? user?.form?.questions ?? [] : request?.form?.questions ?? [];

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding for the dotted border
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DottedBorder(
              color: Colors.grey, // Border color
              strokeWidth: 1, // Border width
              dashPattern: const [4, 4], // Dash length and spacing
              borderType: BorderType.RRect, // Rounded rectangle border
              radius: const Radius.circular(28), // Rounded corner radius
              padding: const EdgeInsets.all(
                  16), // Inner padding of the dotted border
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFFEAEFF2),
                            child: ClipOval(
                              child: Image.network(
                                isGroup
                                    ? user?.profilePictureUrl ?? ""
                                    : request?.profilePictureUrl ?? "",
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.person,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    loadingProgress == null
                                        ? child
                                        : const Center(
                                            child: CircularProgressIndicator(
                                                color: DesignColors.accent),
                                          ),
                              ),
                            ),
                          ),
                          if (isGroup && user!.checkedIn)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGroup ? user?.name ?? "" : request?.name ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            isGroup
                                ? user?.userName ?? ""
                                : request?.userName ?? "",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (request.lobbyType == 'PRIVATE')
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEC4B5D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              onPressed: () async {
                                final body = {
                                  "lobbyId": lobbyId,
                                  "requestAccessDTOList": [
                                    {
                                      "responses": "",
                                      // isGroup
                                      //     ? request?.groupData?.text
                                      //     : request?.text,
                                      "accessRequestId":
                                          request?.accessRequestId,
                                      "isAccepted": true
                                    }
                                  ]
                                };
                                await ref.read(
                                    permissionAccessRequestProvider(body)
                                        .future);

                                ref
                                    .read(
                                        accessRequestsNotifierProvider(lobbyId)
                                            .notifier)
                                    .refresh(lobbyId);
                                Get.back();
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            OutlinedButton(
                              onPressed: () async {
                                await showCustomBottomSheet(context);
                                final body = {
                                  "lobbyId": lobbyId,
                                  "requestAccessDTOList": [
                                    {
                                      "responses":
                                          ref.read(textControllerProvider).text,
                                      "accessRequestId":
                                          request?.accessRequestId,
                                      "isAccepted": false
                                    }
                                  ]
                                };
                                await ref.read(
                                    permissionAccessRequestProvider(body)
                                        .future);
                                ref
                                    .read(
                                        accessRequestsNotifierProvider(lobbyId)
                                            .notifier)
                                    .refresh(lobbyId);
                                Get.back();
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF3E79A1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF3E79A1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGroup ? groupData?.text ?? "" : request?.text ?? "",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                ref.read(expandedCardProvider(cardId).notifier).state =
                    !isExpanded;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  children: [
                    const Text(
                      'View form response',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_outlined,
                        size: 20,
                        color: Colors.grey),
                  ],
                ),
              ),
            ),

            // Expanded content
            // Expanded content with updated UI
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Color(0xFFE0E0E0)),
                    formQuestions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(
                              "No responses available",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : FormViewerBuilder(formQuestions: formQuestions),

                    if(request.forms!=null && request.forms!.isNotEmpty)
                    ...[
                      Space.h(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          "External Forms",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Space.h(height: 4),
                      ...List.generate(
                        request.forms!.length,
                        (index) => Column(
                          children: [
                             Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                "Response of Slot ${index+1}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Space.h(height: 4),
                            FormViewerBuilder(
                              formQuestions: request.forms![index].questions!,
                            ),
                            if(index == request.forms!.length-1)
                            Space.h(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FormViewerBuilder extends StatelessWidget {
  const FormViewerBuilder({
    super.key,
    required this.formQuestions,
  });

  final List<Question> formQuestions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: formQuestions.length,
      itemBuilder: (context, index) {
        final question = formQuestions[index];

        // Text question with new UI
        // Text question with new UI
        if (question.questionType == 'text' || question.questionType == 'number' || question.questionType == 'email') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF323232),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: question.questionText),
                          if (question.isMandatory) TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                        ],
                      ),
                    ),
                    Space.h(height: 12),
                    // Non-editable text field that looks like the design
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        question.answer.isEmpty ? "No answer provided" : question.answer,
                        style: TextStyle(
                          fontSize: 12,
                          color: question.answer.isEmpty ? Colors.grey : Color(0xFF444444),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Date question
        else if (question.questionType == 'date') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF323232),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: question.questionText),
                          if (question.isMandatory) TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                        ],
                      ),
                    ),
                    Space.h(height: 12),
                    // Non-editable date display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            question.answer.isNotEmpty ? _formatDate(question.answer) : "No date provided",
                            style: TextStyle(
                              fontSize: 12,
                              color: question.answer.isEmpty ? Colors.grey : Color(0xFF444444),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // URL question with clickable link
        else if (question.questionType == 'url') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF323232),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: question.questionText),
                          if (question.isMandatory) TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                        ],
                      ),
                    ),
                    Space.h(height: 12),
                    // Clickable URL field
                    InkWell(
                      onTap: () async {
                        if (question.answer.isNotEmpty) {
                          _launchUrlInBrowser(question.answer, context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.answer.isEmpty ? "No URL provided" : question.answer,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: question.answer.isEmpty ? Colors.grey : Colors.blue,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (question.answer.isNotEmpty) Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // File question with view/download options
        else if (question.questionType == 'file') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF323232),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: question.questionText),
                          if (question.isMandatory) TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                        ],
                      ),
                    ),
                    Space.h(height: 12),

                    // File display with options
                    if (question.answer.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                              child: Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No file uploaded",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // File Preview Section
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Stack(
                                children: [
                                  // File Content
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      child: _buildFilePreview(question.answer),
                                    ),
                                  ),

                                  // File Type Badge
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getFileExtension(question.answer).toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getFileColor(question.answer).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getFileIcon(question.answer),
                                              size: 20,
                                              color: _getFileColor(question.answer),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _getFileNameFromUrl(question.answer),
                                                  style: TextStyle(
                                                    color: const Color(0xFF1A1A1A),
                                                    fontSize: 14,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  _getFileTypeDescription(question.answer),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // File Info & Actions Section
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  // File Name

                                  // SizedBox(height: 16.h),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      // View Button
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _openFileInApp(question.answer, context),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getFileColor(question.answer),
                                                    _getFileColor(question.answer).withOpacity(0.8),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _getFileColor(question.answer).withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.visibility_rounded, color: Colors.white, size: 18),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "View",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 12),

                                      // More Options Button
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _showFileOptions(question.answer, context),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey[200]!),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.more_horiz_rounded, color: Colors.grey[700], size: 18),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Options",
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        // Multiple choice question with new UI
        else if (question.questionType == 'multiple-choice') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF323232),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: question.questionText),
                          if (question.isMandatory) TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                        ],
                      ),
                    ),
                    Space.h(height: 12),
                    // Non-editable checkboxes
                    ...question.options.map((option) {
                      final isSelected = question.answer == option;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            // Non-interactive checkbox that matches the design
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isSelected ? Color(0xFFEC4B5D) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: isSelected ? Color(0xFFEC4B5D) : Colors.grey, width: 1),
                              ),
                              child:
                                  isSelected
                                      ? Center(child: Icon(Icons.check, size: 12, color: Colors.white))
                                      : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  color: Color(0xFF444444),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }
        // Default fallback for unsupported question types
        return Container();
      },
    );
  }
   Widget _buildFilePreview(String url) {
    if (_isImageFile(url)) {
      return Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[100],
              child: Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400])),
            ),
      );
    } else {
      return Container(
        color: _getFileColor(url).withOpacity(0.1),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
            ),
            child: Icon(_getFileIcon(url), size: 40, color: _getFileColor(url)),
          ),
        ),
      );
    }
  }

  IconData _getFileIcon(String url) {
    if (_isImageFile(url)) return Icons.image_rounded;
    if (_isPdfFile(url)) return Icons.picture_as_pdf_rounded;
    if (_isVideoFile(url)) return Icons.play_circle_filled_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _getFileColor(String url) {
    if (_isImageFile(url)) return const Color(0xFF4CAF50);
    if (_isPdfFile(url)) return const Color(0xFFFF5722);
    if (_isVideoFile(url)) return const Color(0xFF2196F3);
    return Colors.grey;
  }

  String _getFileExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final extension = path.split('.').last;
    return extension.isNotEmpty ? extension : 'file';
  }

  String _getFileTypeDescription(String url) {
    if (_isImageFile(url)) return "Image file";
    if (_isPdfFile(url)) return "PDF document";
    if (_isVideoFile(url)) return "Video file";
    return "File";
  }

  void _openFileInApp(String url, BuildContext context) {
    // Add your in-app file opening logic here
    // For images: show in image viewer
    // For videos: show in video player
    // For PDFs: show in PDF viewer

    if (_isImageFile(url)) {
      // Open image viewer
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewerPage(imageUrl: url)));
    } else if (_isVideoFile(url)) {
      // Open video player
      Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerPage(videoUrl: url)));
    } else if (_isPdfFile(url)) {
      // Open PDF viewer
      Navigator.push(context, MaterialPageRoute(builder: (context) => PDFViewerPage(pdfUrl: url)));
    }
  }

  // Helper method to format date for display
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoString; // Return original string if parsing fails
    }
  }

  // Helper method to extract file name from URL
  String _getFileNameFromUrl(String url) {
    try {
      return url.split('/').last;
    } catch (e) {
      return url; // Return original URL if extraction fails
    }
  }

  // Helper functions to check file types
  bool _isImageFile(String url) {
    final ext = url.toLowerCase().split('.').last;
    return ['png', 'jpg', 'jpeg'].contains(ext);
  }

  bool _isPdfFile(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isVideoFile(String url) {
    return url.toLowerCase().endsWith('.mp4');
  }

  // Method to launch URL in browser
  void _launchUrlInBrowser(String url, BuildContext context) async {
    try {
      // Normalize the URL by adding https:// if no protocol is specified
      String normalizedUrl = url.trim();
      if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
        normalizedUrl = 'https://$normalizedUrl';
      }

      // Remove any extra spaces
      normalizedUrl = normalizedUrl.replaceAll(RegExp(r'\s+'), '');

      // Handle www. prefix if missing
      if (!normalizedUrl.contains('www.') &&
          (normalizedUrl.startsWith('http://') || normalizedUrl.startsWith('https://'))) {
        final urlParts = normalizedUrl.split('://');
        normalizedUrl = '${urlParts[0]}://www.${urlParts[1]}';
      }

      final Uri uri = Uri.parse(normalizedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not launch URL'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid URL format. Please check the URL and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show options for file handling
  void _showFileOptions(String fileUrl, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Container(
                      width: 36,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E79A1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.file_present_rounded, color: const Color(0xFF3E79A1), size: 24),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "File Options",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Choose how to handle this file",
                                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Action Buttons
                    _buildModernButton(
                      context: context,
                      icon: Icons.open_in_browser_rounded,
                      title: "Open in Browser",
                      subtitle: "View file in web browser",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3E79A1), Color(0xFF2C5A7A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _launchUrlInBrowser(fileUrl, context);
                      },
                    ),

                    SizedBox(height: 16),

                    _buildModernButton(
                      context: context,
                      icon: Icons.download_rounded,
                      title: "Download File",
                      subtitle: "Save to your device",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _downloadFile(fileUrl, context);
                      },
                    ),

                    SizedBox(height: 16),

                    _buildModernButton(
                      context: context,
                      icon: Icons.content_copy_rounded,
                      title: "Copy URL",
                      subtitle: "Copy link to clipboard",
                      backgroundColor: Colors.grey[50],
                      textColor: const Color(0xFF1A1A1A),
                      iconColor: const Color(0xFF1A1A1A),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: fileUrl));
                        Navigator.of(context).pop();
                        _showSuccessSnackBar(context);
                      },
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildModernButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Gradient? gradient,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: gradient == null ? Border.all(color: Colors.grey[200]!, width: 1) : null,
            boxShadow:
                gradient != null
                    ? [
                      BoxShadow(
                        color: (gradient.colors.first).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gradient != null ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: (textColor ?? Colors.white).withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: (textColor ?? Colors.white).withOpacity(0.7), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for success snack bar
  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            const Text('URL copied to clipboard', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Method to download file
  void _downloadFile(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not download file'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading file: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class DottedBorderExample extends StatelessWidget {
  const DottedBorderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dotted Border Example'),
      ),
      body: Center(
        child: DottedBorder(
          color: Colors.grey, // Border color
          strokeWidth: 1, // Border width
          dashPattern: [4, 4], // Dash length and spacing
          borderType: BorderType.RRect, // Border type: Rect, RRect, Circle
          radius: const Radius.circular(12), // Rounded corners
          child: Container(
            width: 300,
            height: 150,
            alignment: Alignment.center,
            child: const Text(
              'Dotted Border',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
