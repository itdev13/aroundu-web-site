import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/access_request.lobby.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/views/lobby/provider/access_request_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

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
        if (question.questionType == 'text') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 18,
                  top: 12,
                  left: 12,
                  right: 12,
                ),
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
                          TextSpan(
                            text: question.questionText,
                          ),
                          if (question.isMandatory)
                            TextSpan(
                              text: '   *',
                              style: TextStyle(
                                color: Color(0xFFEC4B5D),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Space.h(height: 12),
                    // Non-editable text field that looks like the design
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        question.answer.isEmpty
                            ? "No answer provided"
                            : question.answer,
                        style: TextStyle(
                          fontSize: 12,
                          color: question.answer.isEmpty
                              ? Colors.grey
                              : Color(0xFF444444),
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
        // Multiple choice question with new UI
        else if (question.questionType == 'multiple-choice') {
          return Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Card(
              shadowColor: Color(0x143E79A1),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 18,
                  top: 12,
                  left: 12,
                  right: 12,
                ),
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
                          TextSpan(
                            text: question.questionText,
                          ),
                          if (question.isMandatory)
                            TextSpan(
                              text: '   *',
                              style: TextStyle(
                                color: Color(0xFFEC4B5D),
                              ),
                            ),
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
                                color: isSelected
                                    ? Color(0xFFEC4B5D)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFFEC4B5D)
                                      : Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.w400,
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
