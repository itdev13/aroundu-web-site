import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FeedbackWidget extends StatefulWidget {
  final String lobbyId;
  final Function(String, String) onSubmit;

  const FeedbackWidget(
      {Key? key, required this.onSubmit, required this.lobbyId})
      : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  String selectedEmoji = "";
  String selectedRating = "";

  final List<Map<String, String>> emojiOptions = [
    {"emoji": "😟", "text": "Hmm"},
    {"emoji": "😐", "text": "Well"},
    {"emoji": "😑", "text": "Okay"},
    {"emoji": "😊", "text": "Good"},
    {"emoji": "😃", "text": "Great"},
  ];

  final List<String> ratingOptions = [
    "Not Good",
    "Can be Better",
    "Very Good",
    "Best Host Ever"
  ];

  Future<Response?> saveLobbyRating(
    String lobbyId,
    String lobbyRating,
    String hostRating,
  ) async {
    try {
      // print("$userId $action");
      const postRequestUrl = "match/rating/create";
      //  https://api.aroundu.in/user/api/v1/updateUserRating
      final response = await ApiService().post(
        postRequestUrl,
        body: {
          "lobbyId": lobbyId,
          "lobbyRating": lobbyRating,
          "hostRating": hostRating,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("User Rating Updated Succesfully: ${response.data}");
        return response;
      } else {
        print("Error in updating rating: ${response.statusCode}");
        return response;
      }
    } catch (e, stack) {
      print("API Error: $e \n $stack");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: DesignText(
                          text: "How was your experience ?",
                          fontSize: 18,
                          maxLines: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 24, color: Color(0xFF3E79A1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const DesignText(
                    text: "Had a great time? Let the host know!",
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 15),

                  // Emoji Selection
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: emojiOptions.map((option) {
                      bool isSelected = selectedEmoji == option["text"];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedEmoji = option["text"]!),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                  )
                                ],
                              ),
                              child: Text(
                                option["emoji"]!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 5),
                            DesignText(
                              text: option["text"]!,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.red : Colors.black87,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Rating Options
                  const DesignText(
                    text:
                        "Help us highlight the best hosts! Rate your experience",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 25,
                    runSpacing: 10,
                    children: ratingOptions.map((text) {
                      bool isSelected = selectedRating == text;
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = text),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.pink.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFEC4B5D)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: DesignText(
                            text: text,
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFFEC4B5D)
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  OutlinedButton(
                    onPressed: selectedEmoji.isNotEmpty &&
                            selectedRating.isNotEmpty
                        ? () async {
                            final success = await saveLobbyRating(widget.lobbyId, selectedEmoji,
                                    selectedRating);

                            if (success != null && success.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Feedback submitted successfully'),
                                    backgroundColor: Colors.green),
                              );
                              widget.onSubmit(selectedEmoji, selectedRating);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Feedback submission failed'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3E79A1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 40),
                    ),
                    child: const DesignText(
                      text: "Submit",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E79A1),
                    ),
                  ),

                  // OutlinedButton(
                  //   onPressed:
                  //       selectedEmoji.isNotEmpty && selectedRating.isNotEmpty
                  //           ? () {
                  //               widget.onSubmit(selectedEmoji, selectedRating);
                  //               Navigator.pop(context);
                  //             }
                  //           : null,
                  //   style: OutlinedButton.styleFrom(
                  //     side: const BorderSide(color: Color(0xFF3E79A1)),
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(25)),
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 12, horizontal: 40),
                  //   ),
                  //   child: const DesignText(
                  //     text: "Submit",
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w600,
                  //     color: Color(0xFF3E79A1),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
