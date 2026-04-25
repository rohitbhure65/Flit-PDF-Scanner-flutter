import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewService {
  InAppReviewService._();

  static final InAppReviewService instance = InAppReviewService._();

  static const String _reviewSubmittedKey = 'review_submitted';
  static const String _reviewRequestedKey = 'review_requested';

  InAppReview get _inAppReview => InAppReview.instance;

  /// Returns true if the user has already submitted a review.
  Future<bool> hasUserSubmittedReview() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reviewSubmittedKey) ?? false;
    } catch (e) {
      debugPrint('Error reading review submission status: $e');
      return false;
    }
  }

  /// Returns true if the in-app review flow has already been triggered.
  Future<bool> hasReviewBeenRequested() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reviewRequestedKey) ?? false;
    } catch (e) {
      debugPrint('Error reading review request status: $e');
      return false;
    }
  }

  /// Checks if the device/app supports in-app reviews.
  Future<bool> isAvailable() async {
    try {
      return await _inAppReview.isAvailable();
    } catch (e) {
      debugPrint('In-app review availability check failed: $e');
      return false;
    }
  }

  /// Marks that the review flow has been triggered.
  Future<void> _markReviewRequested() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reviewRequestedKey, true);
    } catch (e) {
      debugPrint('Error saving review request status: $e');
    }
  }

  /// Marks that the user submitted a review.
  Future<void> markReviewSubmitted() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reviewSubmittedKey, true);
    } catch (e) {
      debugPrint('Error saving review submitted status: $e');
    }
  }

  /// Requests an in-app review if:
  /// - The user hasn't already submitted one
  /// - The device supports in-app reviews
  /// - The review hasn't already been requested this session
  Future<void> checkAndRequestReview() async {
    try {
      if (await hasUserSubmittedReview()) {
        debugPrint('Review already submitted by user, skipping.');
        return;
      }

      if (await hasReviewBeenRequested()) {
        debugPrint('Review already requested this session, skipping.');
        return;
      }

      final bool available = await isAvailable();
      if (!available) {
        debugPrint('In-app review not available on this platform.');
        return;
      }

      await _markReviewRequested();
      await _inAppReview.requestReview();

      debugPrint('In-app review flow completed.');
    } catch (e) {
      debugPrint('Error requesting in-app review: $e');
    }
  }
}
