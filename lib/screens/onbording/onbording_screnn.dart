import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/dot_indicators.dart';
import 'package:shop/constants.dart';
import 'package:shop/routes/route_constants.dart';

import 'components/onbording_content.dart';

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  final List<Onbord> _onbordData = [
    Onbord(
      image: "assets/Illustration/Illustration-0.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_0.png",
      title: "Find the item you’ve \nbeen looking for",
      description:
          "Here you’ll see rich varieties of goods, carefully classified for seamless browsing experience.",
    ),
    Onbord(
      image: "assets/Illustration/Illustration-1.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_1.png",
      title: "Get those shopping \nbags filled",
      description:
          "Add any item you want to your cart, or save it on your wishlist, so you don’t miss it in your future purchases.",
    ),
    Onbord(
      image: "assets/Illustration/Illustration-2.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_2.png",
      title: "Fast & secure \npayment",
      description: "There are many payment options available for your ease.",
    ),
    Onbord(
      image: "assets/Illustration/Illustration-3.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_3.png",
      title: "Package tracking",
      description:
          "In particular, Shoplon can pack your orders, and help you seamlessly manage your shipments.",
    ),
    Onbord(
      image: "assets/Illustration/Illustration-4.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_4.png",
      title: "Nearby stores",
      description:
          "Easily track nearby shops, browse through their items and get information about their products.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              _buildSkipButton(context),
              _buildPageView(context),
              _buildBottomNavigation(context),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// --- Skip Button ---
  Widget _buildSkipButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, loginScreenRoute);
        },
        child: Text(
          "Skip",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ),
    );
  }

  /// --- PageView ---
  Widget _buildPageView(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _onbordData.length,
        onPageChanged: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        itemBuilder: (context, index) => OnbordingContent(
          title: _onbordData[index].title,
          description: _onbordData[index].description,
          image: (Theme.of(context).brightness == Brightness.dark &&
                  _onbordData[index].imageDarkTheme != null)
              ? _onbordData[index].imageDarkTheme!
              : _onbordData[index].image,
          isTextOnTop: index.isOdd,
        ),
      ),
    );
  }

  /// --- Bottom Navigation ---
  Widget _buildBottomNavigation(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          _onbordData.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: defaultPadding / 4),
            child: DotIndicator(isActive: index == _pageIndex),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 60,
          width: 60,
          child: ElevatedButton(
            onPressed: () {
              if (_pageIndex < _onbordData.length - 1) {
                _pageController.nextPage(
                  curve: Curves.ease,
                  duration: defaultDuration,
                );
              } else {
                Navigator.pushNamed(context, loginScreenRoute);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
            ),
            child: SvgPicture.asset(
              "assets/icons/Arrow - Right.svg",
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// --- Onbord model class ---
class Onbord {
  final String image;
  final String title;
  final String description;
  final String? imageDarkTheme;

  Onbord({
    required this.image,
    required this.title,
    required this.description,
    this.imageDarkTheme,
  });
}
