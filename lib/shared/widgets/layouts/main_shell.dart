import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/features/files/presentation/pages/files_screen.dart';
import 'package:flitpdf/features/home/presentation/pages/home_screen.dart';
import 'package:flitpdf/features/scanner/presentation/pages/scanner_screen.dart';
import 'package:flitpdf/features/settings/presentation/pages/settings_screen.dart';
import 'package:flitpdf/features/tools/presentation/pages/tools_screen.dart';
import 'package:flitpdf/shared/controllers/main_shell_controller.dart';
import 'package:flitpdf/shared/widgets/layouts/bottom_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final MainShellController controller = Get.put(MainShellController());

    final List<Widget> pages = <Widget>[
      const ScannerScreen(),
      const FilesScreen(),
      const HomeScreen(),
      const ToolsScreen(),
      const SettingsScreen(),
    ];

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: controller.currentIndex, children: pages),
      ),
      extendBody: true,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Obx(
            () => controller.showStatusBar.value
                ? BottomStatusBar(
                    message: controller.statusMessage.value,
                    subMessage: controller.statusSubMessage.value.isEmpty
                        ? null
                        : controller.statusSubMessage.value,
                    onCancel: controller.onCancel.value,
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedNotchBottomBar(
              notchBottomBarController: controller.notchController,
              color: isDark ? AppColors.surfaceDark : Colors.white,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: isDark ? 0 : 10,
              kBottomRadius: 28.0,
              notchColor: AppColors.primary,
              removeMargins: false,
              bottomBarWidth: MediaQuery.of(context).size.width - 32,
              showShadow: !isDark,
              durationInMilliSeconds: 300,
              itemLabelStyle: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              elevation: 1,
              bottomBarItems: <BottomBarItem>[
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.document_scanner_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  activeItem: const Icon(Icons.document_scanner_rounded, color: Colors.white),
                  itemLabel: 'Scanner',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.folder_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  activeItem: const Icon(Icons.folder_rounded, color: Colors.white),
                  itemLabel: 'Files',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.home_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  activeItem: const Icon(Icons.home_rounded, color: Colors.white),
                  itemLabel: 'Home',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.grid_view_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  activeItem: const Icon(Icons.grid_view_rounded, color: Colors.white),
                  itemLabel: 'Tools',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.settings_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  activeItem: const Icon(Icons.settings_rounded, color: Colors.white),
                  itemLabel: 'Settings',
                ),
              ],
              onTap: (int index) {
                controller.changePage(index);
              },
              kIconSize: 24.0,
            ),
          ),
        ],
      ),
    );
  }
}
