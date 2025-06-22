import 'dart:math';

import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuggestionFormWidget extends StatefulWidget {
  const SuggestionFormWidget({super.key});

  @override
  State<SuggestionFormWidget> createState() => _SuggestionFormWidgetState();
}

class _SuggestionFormWidgetState extends State<SuggestionFormWidget> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedTag;
  bool _isSubmitting = false;
  final List<String> tags = [
    "New Subcategory",
    "New Category",
    "House related",
    "New Badges",
    "Lobby Suggestion"
  ];
  
  // Function to handle tag selection/deselection
  void _handleTagSelection(String tag) {
    setState(() {
      // If the tag is already selected, deselect it
      if (_selectedTag == tag) {
        _selectedTag = null;
      } else {
        _selectedTag = tag;
      }
    });
  }

   Future<dynamic> requestFeature(String tag, String message) async {
    try {
      print("$tag $message");
      const postRequestUrl = "user/api/feedback";
      final response = await ApiService().post(
        postRequestUrl,
        body: {
          "tag": tag,
          "message": message,
          // "tag": Tag, "message": message
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Request Feedback submited Succesfully: ${response.data}");
        return response;
      } else {
        print("Error in Request Feedback : ${response.statusCode}");
        return response;
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }


  Future<void> _submitFeedback() async {
     HapticFeedback.selectionClick();
    if (_selectedTag == null) {
      CustomSnackBar.show(
        context: context,
        message: "Please select a tag for your suggestion",
        type: SnackBarType.warning,
      );
      return;
    }
    
    if (_controller.text.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Please provide details about your suggestion",
        type: SnackBarType.warning,
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final response = await requestFeature(_selectedTag!, _controller.text);
          
      if (response.statusCode == 200) {
        // Clear form after successful submission
        setState(() {
          _controller.clear();
          _selectedTag = null;
          _isSubmitting = false;
        });
        
        CustomSnackBar.show(
          context: context,
          message: "Thank you! Your suggestion has been submitted successfully",
          type: SnackBarType.success,
        );
      } else {
        setState(() {
          _isSubmitting = false;
        });
        
        CustomSnackBar.show(
          context: context,
          message: "Failed to submit your suggestion. Please try again later",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      CustomSnackBar.show(
        context: context,
        message: "An error occurred: ${e.toString()}",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),  // Reduced padding
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),  // Reduced border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),  // Lighter shadow
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Title - Simplified
          Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),  // Smaller padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/icons/aroundu.icon.png",
                    height: 40,  // Smaller logo
                  ),
                ),
                SizedBox(height: 10),  // Reduced spacing
                DesignText(
                  text: "Share Your Suggestions with Us!",
                  fontSize: 15,  // Slightly smaller font
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                SizedBox(height: 2),  // Reduced spacing
                DesignText(
                  text: "Help us improve AroundU with your ideas",
                  fontSize: 11,  // Smaller subtitle
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          SizedBox(height: 18),  // Reduced spacing

          // Select Tag Section
          DesignText(
            text: "Select Tag",
            fontSize: 13,  // Smaller label
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          SizedBox(height: 8),  // Reduced spacing

          // Tags - More compact
          Wrap(
            spacing: 8,  // Reduced spacing
            runSpacing: 8,  // Reduced spacing
            children: tags.map((tag) {
              return GestureDetector(
                onTap: () {
                   HapticFeedback.lightImpact();
                  _handleTagSelection(tag);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),  // Smaller padding
                  decoration: BoxDecoration(
                    color: _selectedTag == tag
                        ? DesignColors.accent.withOpacity(0.15)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),  // Consistent radius
                    border: Border.all(
                      color: _selectedTag == tag
                          ? DesignColors.accent
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: DesignText(
                    text: tag,
                    fontSize: 11,  // Smaller text
                    color: _selectedTag == tag ? DesignColors.accent : Colors.black87,
                    fontWeight: _selectedTag == tag ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 18),  // Reduced spacing

          // Suggestion Box
          DesignText(
            text: "Tell us more about it!",
            fontSize: 13,  // Smaller label
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          SizedBox(height: 8),  // Reduced spacing
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),  // Smaller padding
            decoration: BoxDecoration(
              border: Border.all(
                color: _controller.text.isNotEmpty
                    ? DesignColors.accent.withOpacity(0.5)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLength: 400,
                  maxLines: 4,  // Reduced lines
                  decoration: InputDecoration(
                    hintText: "Share your ideas or feedback...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,  // Smaller hint
                    ),
                    border: InputBorder.none,
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(vertical: 8),  // Added padding
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,  // Smaller text
                    fontWeight: FontWeight.w400,
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DesignText(
                    text: "${_controller.text.length}/400",
                    color: _controller.text.length > 350
                        ? DesignColors.accent
                        : Colors.grey.shade600,
                    fontSize: 11,  // Smaller counter
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),  // Reduced spacing

          // Submit Button - More compact
          Center(
            child: SizedBox(
              width: min(250,sw(0.4)),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.accent,
                  disabledBackgroundColor: DesignColors.accent.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),  // Consistent radius
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),  // Smaller padding
                  elevation: 1,  // Reduced elevation
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 18,  // Smaller loader
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : DesignText(
                        text: "Submit Suggestion",
                        fontSize: 14,  // Smaller text
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
