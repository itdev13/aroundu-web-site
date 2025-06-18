import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:flutter/material.dart';

class CustomSettingsCardWithoutImage extends StatelessWidget {
  // final String imagePath;
  final String text;
  // final String nextPageName;

  const CustomSettingsCardWithoutImage({
    Key? key,
    // required this.imagePath,
    required this.text,
    // required this.nextPageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Row(
          children: [
            // Image.asset(
            //   imagePath,
            //   scale: 3.5,
            // ),
            // const SizedBox(width: 10),
            Expanded(
              child: DesignText(
                text:text,
              fontSize: 14, fontWeight: FontWeight.w500
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
