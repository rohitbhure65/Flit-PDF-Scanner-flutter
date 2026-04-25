import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainShellController extends GetxController {
  final RxBool showStatusBar = false.obs;
  final RxString statusMessage = ''.obs;
  final RxString statusSubMessage = ''.obs;
  final Rxn<VoidCallback> onCancel = Rxn<VoidCallback>();
  final RxnString _pendingFilePath = RxnString();

  final NotchBottomBarController notchController = NotchBottomBarController(
    index: 2,
  );

  @override
  void onInit() {
    super.onInit();
    ever(_currentIndex, (int index) {
      notchController.jumpTo(index);
    });
  }

  final RxInt _currentIndex = 2.obs;

  int get currentIndex => _currentIndex.value;
  RxInt get currentIndexRx => _currentIndex;
  String? get pendingFilePath => _pendingFilePath.value;
  RxnString get pendingFilePathRx => _pendingFilePath;

  void changePage(int index) {
    _currentIndex.value = index;
  }

  void showFileInFilesPage(String filePath) {
    _pendingFilePath.value = filePath;
    changePage(1);
  }

  void clearPendingFilePath() {
    _pendingFilePath.value = null;
  }

  void showStatus(
    String message, {
    String? subMessage,
    VoidCallback? onCancel,
  }) {
    statusMessage.value = message;
    statusSubMessage.value = subMessage ?? '';
    this.onCancel.value = onCancel;
    showStatusBar.value = true;
  }

  void hideStatus() {
    showStatusBar.value = false;
  }
}
