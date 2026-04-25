import 'package:flitpdf/core/services/storage_service.dart';
import 'package:flitpdf/shared/widgets/layouts/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../models/onboarding_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<IntroductionScreenState> _introKey =
      GlobalKey<IntroductionScreenState>();

  void _onDone() async {
    final StorageService storage = StorageService();
    await storage.setHasSeenOnboarding();
    if (mounted) {
      Get.offAll(() => const MainShell());
    }
  }

  void _onSkip() => _onDone();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkInitialRoute(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool showIntro = snapshot.data ?? false;
        if (!showIntro) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => const MainShell());
          });
          return const Scaffold(body: SizedBox());
        }

        return IntroductionScreen(
          key: _introKey,
          pages: getOnboardingPages(onFinish: _onDone),
          showSkipButton: false,
          showNextButton: true,
          showBackButton: true,
          showDoneButton: false,
          back: const Icon(Icons.arrow_back_ios),
          next: const Icon(Icons.arrow_forward_ios),
          done: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          onDone: _onDone,
          onSkip: _onSkip,
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Colors.black,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          globalBackgroundColor: Colors.white,
        );
      },
    );
  }

  /// Check if user should see onboarding or go directly to main shell
  /// Returns true if onboarding should be shown
  Future<bool> _checkInitialRoute() async {
    final StorageService storage = StorageService();

    // Check if user is already logged in
    final bool isLoggedIn = await storage.isLoggedIn();

    // isFirstLaunch returns TRUE if user hasn't seen onboarding yet
    final bool hasNotSeenOnboarding = await storage.isFirstLaunch;

    debugPrint(
      'Onboarding check: isLoggedIn=$isLoggedIn, hasNotSeenOnboarding=$hasNotSeenOnboarding',
    );

    // ALWAYS show onboarding for new users (first launch)
    if (hasNotSeenOnboarding) {
      debugPrint('Showing onboarding: first time user');
      return true;
    }

    // Show onboarding if user is not logged in (logout case)
    if (!isLoggedIn) {
      debugPrint('Showing onboarding: user logged out');
      return true;
    }

    // User is logged in and has seen onboarding - go to main shell
    debugPrint('Skipping onboarding: logged in user who already saw it');
    return false;
  }
}
