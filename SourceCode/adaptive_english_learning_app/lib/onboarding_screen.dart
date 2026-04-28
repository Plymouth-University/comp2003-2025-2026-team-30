import 'package:adaptive_english_learning_app/intro_screens/intro_page_1.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'intro_screens/intro_page_2.dart';
import 'intro_screens/intro_page_3.dart';
import 'widgets/app_gate.dart';
import 'widgets/translated_text.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnBoardingScreen> {

  final PageController _controller = PageController();

  // keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            onLastPage = (index == 2);
          });
        },
        children: [
          IntroPage1(),
          IntroPage2(),
          IntroPage3(),
        ],
      ),

      //dot indicators
      Container(
          alignment: const Alignment(0, 0.9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Skip
             GestureDetector(
              onTap: () {
                _controller.jumpToPage(2);
              },
              child: TranslatedText('Skip', style: TextStyle(fontSize: 16, color: Colors.grey[700]))),

            // dot indicators
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: WormEffect(
                dotColor: Colors.grey,
                activeDotColor: Colors.blue,
                dotHeight: 12,
                dotWidth: 12,
              ),
            ),

            // Next or Done
            onLastPage ?
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AppGate()),
                  (route) => false,
                );
               },
              child: TranslatedText('Done', style: TextStyle(fontSize: 16, color: Colors.grey[700]))
              )
              :GestureDetector(
              onTap: () {
                //go to home screen
                _controller.nextPage(duration: Duration(microseconds: 500), curve: Curves.easeIn);
               }  ,
              child: TranslatedText('Next', style: TextStyle(fontSize: 16, color: Colors.grey[700]))
              ),    
          ],
        )
      ),
        ],
      )
    );
  }
}