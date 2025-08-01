import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/onboarding_model.dart';
import '../auth/login_screen.dart'; // Update path based on your project

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      imageAsset: 'assets/images/onboarding2.png',
      title: 'Find rides near you',
      subtitle:
          'Discover eco-friendly carpools going your way. Save fuel, time, and the planet — together.',
    ),
    OnboardingModel(
      imageAsset: 'assets/images/onboarding1.png',
      title: 'Connect with commuters',
      subtitle:
          'Join a trusted network of carpoolers. Build community while getting where you need to go.',
    ),
    OnboardingModel(
      imageAsset: 'assets/images/onboarding4.png',
      title: 'Save money every trip',
      subtitle:
          'Share the ride, split the cost. Carpooling has never been this smart — or this simple.',
    ),
    OnboardingModel(
      imageAsset: 'assets/images/onboarding3.png',
      title: 'Ready to ride?',
      subtitle: 'Let’s get you connected.',
    ),
  ];

  void _goToLogin() {
    Get.off(() => const LoginScreen());
  }

  Widget _buildPage(OnboardingModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(model.imageAsset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          Text(
            model.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF255A45), // Dark Green
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            model.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 20 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF255A45)
                : const Color(0xFFA8CABA), // Active & Inactive
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Off-white
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToLogin,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xFF255A45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (_, index) =>
                    _buildPage(onboardingPages[index]),
              ),
            ),
            _buildDots(),
            const SizedBox(height: 20),
                        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    _goToLogin();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  isLast ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            /* if (isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _goToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255A45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ), */
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
