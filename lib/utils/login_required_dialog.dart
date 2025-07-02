import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final String loginButtonText;
  final String signupButtonText;
  final String? cancelButtonText;
  final VoidCallback? onLogin;
  final VoidCallback? onSignup;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;

  const LoginRequiredDialog({
    Key? key,
    this.title = "Login Required",
    this.message = "You need to login or create an account to join this lobby.",
    this.loginButtonText = "Login",
    this.signupButtonText = "Create Account",
    this.cancelButtonText,
    this.onLogin,
    this.onSignup,
    this.onCancel,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 480,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC6546), Color(0xFFEC4B5D)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFEC4B5D).withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          onClose?.call();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Title with sparkle effect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Message
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(context, isMobile),

                  // Cancel button (optional)
                  if (cancelButtonText != null) ...[  
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          cancelButtonText!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    return Column(
      children: [
        // Login Button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            onLogin?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC6546), Color(0xFFEC4B5D)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.login, color: Colors.white, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    loginButtonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4B5D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFEC4B5D),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12),

        // Signup Button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            onSignup?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC6546), Color(0xFFEC4B5D)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person_add, color: Colors.white, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    signupButtonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4B5D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFEC4B5D),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to show the dialog
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    String? loginButtonText,
    String? signupButtonText,
    String? cancelButtonText,
    VoidCallback? onLogin,
    VoidCallback? onSignup,
    VoidCallback? onCancel,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => LoginRequiredDialog(
        title: title ?? "Login Required",
        message: message ?? "You need to login or create an account to join this lobby.",
        loginButtonText: loginButtonText ?? "Login",
        signupButtonText: signupButtonText ?? "Create Account",
        cancelButtonText: cancelButtonText,
        onLogin: onLogin,
        onSignup: onSignup,
        onCancel: onCancel,
        onClose: onClose,
      ),
    );
  }
}