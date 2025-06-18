import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/models/offers_model.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';



final offersProvider =
    FutureProvider.family<List<Offer>, String>((ref, lobbyId) async {
  return await Api.getOffers(entityId: lobbyId, isApplicable: true);
});

class OfferSwiper extends ConsumerWidget {
  final String lobbyId;

  const OfferSwiper({super.key, required this.lobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersProvider(lobbyId));

    return offersAsync.when(
      data: (offers) {
        final offerDescriptions = generateOfferDescriptions(offers);
        return offerDescriptions.isEmpty
            ? SizedBox.shrink() // Hide if no offers
            : Column(
                children: [
                  OfferSwiperContent(offerDescriptions),
                  Space.h(height: 24),
                ],
              );
      },
      loading: () => SizedBox.shrink(),
      error: (error, stack) {
        Fluttertoast.showToast(msg: 'Error loading offers');
        print('$error \n $stack');
        return SizedBox.shrink();
      },
    );
  }

  List<String> generateOfferDescriptions(List<Offer> offers) {
    return offers.map((offer) {
      String discountDisplay =
          (offer.discountType.toUpperCase() == "PERCENTAGE")
              ? "${offer.discountValue}%"
              : "${offer.discountValue} Rs.";

      String eligibilityText = (offer.eligibilityCriteria.contains("ALL"))
          ? "for all users"
          : "for ${offer.eligibilityCriteria.join(", ")}";

      return "${offer.discountType.toUpperCase()} $discountDisplay OFF $eligibilityText";
    }).toList();
  }
}

class OfferSwiperContent extends StatefulWidget {
  final List<String> offerDescriptions;

  const OfferSwiperContent(this.offerDescriptions, {super.key});

  @override
  State<OfferSwiperContent> createState() => _OfferSwiperContentState();
}

class _OfferSwiperContentState extends State<OfferSwiperContent> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_currentIndex == widget.offerDescriptions.length - 1) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _pageController.jumpToPage(0);
            setState(() {
              _currentIndex = 0;
            });
            _startAutoScroll();
          }
        });
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        setState(() {
          _currentIndex++;
        });
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Color(0xFF3E79A1), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.offerDescriptions.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final words = widget.offerDescriptions[index].split(' ');
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          words[0],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          words.length > 1
                              ? " ${widget.offerDescriptions[index].substring(words[0].length)}"
                              : "",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 6,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.offerDescriptions.length,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: _currentIndex == index
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//adminview custom offers
class CustomOfferCard extends StatelessWidget {
  final String boldText;
  final String normalText;
  final IconData icon;

  const CustomOfferCard({
    super.key,
    required this.boldText,
    required this.normalText,
    this.icon = Icons.local_offer_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 370,
      // margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 1.2),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xFFEC4B5D), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC4B5D),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(text: " $normalText"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
