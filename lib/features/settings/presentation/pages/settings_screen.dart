import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flitpdf/core/constants/app_colors.dart';
import 'package:flitpdf/core/services/storage_service.dart';
import 'package:flitpdf/features/auth/data/services/google_sign_in_service.dart';
import 'package:flitpdf/features/settings/presentation/pages/about_us_page.dart';
import 'package:flitpdf/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:flitpdf/features/settings/presentation/pages/terms_and_conditions_page.dart';
import 'package:flitpdf/features/splash/presentation/pages/splash_screen.dart';
import 'package:flitpdf/shared/widgets/typography/modern_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggedIn = false;
  String _userName = 'Guest User';
  String _userEmail = '';
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final StorageService storage = StorageService();
    final bool isLoggedIn = await storage.isLoggedIn();

    if (isLoggedIn) {
      final Map<String, String?> userData = await storage.getUserData();
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _userName = userData['name'] ?? 'User';
          _userEmail = userData['email'] ?? '';
          _userPhotoUrl = userData['photoUrl'];
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userName = 'Guest User';
          _userEmail = '';
          _userPhotoUrl = null;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final GoogleSignInService signInService = GoogleSignInService();
              await signInService.signOut();
              await _loadUserData();
              // Redirect to onboarding screen after logout
              if (mounted) {
                Get.offAll(() => const SplashScreen());
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            // Header
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                centerTitle: false,
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 32),

                  // App Settings Group
                  const ModernSectionHeader(title: 'App Preferences'),
                  _buildSettingsGroup(<Widget>[
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.storage_rounded,
                      title: 'Clear Cache',
                      subtitle: 'Free up local storage',
                      onTap: () => _showClearCacheDialog(context),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Legal & About Group
                  const ModernSectionHeader(title: 'Legal & About'),
                  _buildSettingsGroup(<Widget>[
                    _buildSettingsTile(
                      icon: Icons.description_rounded,
                      title: 'Terms & Conditions',
                      subtitle: 'Usage policy and terms',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const TermsAndConditionsPage(),
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_rounded,
                      title: 'About Us',
                      subtitle: 'Version 1.0.0',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutUsPage(),
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.share_rounded,
                      title: 'Share FlitPDF',
                      subtitle: 'Invite friends and colleagues',
                      onTap: _shareApp,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Account Group
                  if (_isLoggedIn) ...<Widget>[
                    const ModernSectionHeader(title: 'Account'),
                    _buildSettingsGroup(<Widget>[
                      _buildSettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: _handleLogout,
                        isDestructive: true,
                      ),
                    ]),
                  ],

                  const SizedBox(height: 64),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'FlitPDF',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium PDF Suite',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileSection() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[AppColors.primary, AppColors.primaryDark]
              : <Color>[
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Profile Image
          _buildProfileImage(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn ? _userEmail : 'Sync your data across devices',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(width: 12),
          // _buildAuthButton(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: ClipOval(
        child: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: _userPhotoUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (BuildContext context, String url, Object error) =>
                    _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.white.withValues(alpha: 0.2),
      child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.primary : AppColors.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDestructive
                            ? AppColors.error
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Clear Cache',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          'This will delete all cached files and free up storage space. Your original documents will remain safe.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Clear Cache',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final Directory cacheDir = Directory('${directory.parent.path}/cache');

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cache cleared successfully',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to clear cache: $e',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
        );
      }
    }
  }

  void _shareApp() {
    Share.share(
      'Download FlitPDF - The ultimate premium PDF scanner and tool suite. Get it now on the App Store and Google Play!',
      subject: 'Check out FlitPDF!',
    );
  }
}
