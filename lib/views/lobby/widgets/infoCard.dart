import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:flutter/material.dart';

class InfoCard {
  final IconData icon;
  final String title;
  final String subtitle;

  InfoCard({required this.icon, required this.title, required this.subtitle});
}

class ScrollableInfoCards extends StatelessWidget {
  final List<InfoCard> cards;

  const ScrollableInfoCards({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white ,
      height: 132, // Adjusted height for responsiveness
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        // padding: EdgeInsets.only(right: 16.w),
        itemBuilder: (context, index) {
          return _buildCard(cards[index]);
        },
      ),
    );
  }

  Widget _buildCard(InfoCard card) {
    return Container(
      width: 124, // Adjust width based on screen size
      // margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(12.r),
        
        // gradient: LinearGradient(
        //   colors: [Colors.white, Colors.pink.shade50], // Subtle gradient effect
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0x143E79A1),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              card.icon,
              color: Color(0xFFEC4B5D),
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          DesignText(
            text: card.title,
            // fontWeight: FontWeight.bold,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF778899),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          DesignText(
            text: card.subtitle,
            fontSize: 8,
            fontWeight: FontWeight.w400,
            color: Color(0xFFEC4B5D),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
