import 'package:flitpdf/features/settings/presentation/pages/legal_content_page.dart';
import 'package:flitpdf/shared/data/app_contents.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = AppContents.privacyPolicy;
    return LegalContentPage(
      title: data['title'] as String,
      lastUpdated: data['lastUpdated'] as String,
      sections: data['sections'] as List<Map<String, dynamic>>,
    );
  }
}
