import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/features/auth/data/services/google_sign_in_service.dart';
import 'package:flitpdf/main.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

List<PageViewModel> getOnboardingPages({required VoidCallback? onFinish}) {
  const PageDecoration pageDecoration = PageDecoration(
    titleTextStyle: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyTextStyle: TextStyle(fontSize: 18.0, color: AppColors.textPrimary),
    imageAlignment: Alignment.center,
    bodyAlignment: Alignment.bottomCenter,
    imageFlex: 3,
    bodyFlex: 1,
    imagePadding: EdgeInsets.all(32.0),
  );

  return <PageViewModel>[
    // Page 1: Welcome
    PageViewModel(
      title: "Welcome to FlitPDF",
      body: "Fast & powerful PDF tools right in your pocket",
      image: SizedBox(
        height: 300,
        child: Lottie.asset(
          'assets/animations/Files.json',
          alignment: Alignment.center,
        ),
      ),
      decoration: pageDecoration.copyWith(pageColor: AppColors.background),
    ),
    // Page 2: Features
    PageViewModel(
      title: "All-in-one Suite",
      body: "Scan documents, edit PDFs, convert files, and share instantly",
      image: SizedBox(
        height: 300,
        child: Lottie.asset(
          'assets/animations/filetransfer.json',
          alignment: Alignment.center,
        ),
      ),
      decoration: pageDecoration.copyWith(pageColor: AppColors.background),
    ),
    // Page 3: Scanner
    PageViewModel(
      title: "Smart Scanner",
      body: "Capture documents with camera, auto-detect edges & crop",
      image: SizedBox(
        height: 300,
        child: Lottie.asset(
          'assets/animations/pdfscanner.json',
          alignment: Alignment.center,
        ),
      ),
      decoration: pageDecoration.copyWith(pageColor: AppColors.background),
    ),
    // Page 4: Get Started with Sign in with Google
    PageViewModel(
      title: "Ready to Create?",
      body: "Your perfect PDFs are just a tap away",
      image: const SizedBox(
        height: 300,
        child: RiveAnimation.asset(
          'assets/animations/14616-27585-business-startup-project-launch-successful-idea.riv',
          alignment: Alignment.center,
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          children: <Widget>[
            // Sign in with Google button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Sign in with Google
                  final GoogleSignInService signInService =
                      GoogleSignInService();
                  final BuildContext? context =
                      MyNavigatorKey.navigatorKey.currentContext;
                  bool didSignIn = false;
                  if (context != null) {
                    didSignIn =
                        await signInService.signInWithGoogle(context) != null;
                  }
                  // Navigate to main shell only after a successful sign-in.
                  if (didSignIn && onFinish != null) {
                    onFinish();
                  }
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF333333),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            // Skip for now button
          ],
        ),
      ),
      decoration: pageDecoration.copyWith(pageColor: AppColors.background),
    ),
  ];
}
