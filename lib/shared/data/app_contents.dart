/// Dummy content data for legal and about pages
/// This file contains sample data for Terms & Conditions, Privacy Policy, About Us, and Credits
library;

class AppContents {
  // Terms & Conditions
  static const Map<String, dynamic> termsAndConditions = <String, dynamic>{
    'title': 'Terms & Conditions',
    'lastUpdated': 'April 20, 2026',
    'sections': <Map<String, String>>[
      <String, String>{
        'heading': 'Acceptance of Terms',
        'content':
            '''By downloading, installing, or using FlitPDF, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the app.''',
      },
      <String, String>{
        'heading': 'Description of Service',
        'content':
            '''FlitPDF is an open-source mobile application that provides PDF processing and document management tools. The app allows users to scan documents, convert images to PDF, compress files, and perform other document-related operations locally on their device.''',
      },
      <String, String>{
        'heading': 'User Responsibilities',
        'content': '''You are responsible for:

• Ensuring you have the legal right to process and modify the documents you work with
• Maintaining the security of your device and app access
• Using the app in compliance with applicable laws and regulations
• Not using the app for any illegal or unauthorized purposes''',
      },
      <String, String>{
        'heading': 'Data Processing',
        'content':
            '''FlitPDF processes documents locally on your device. We do not upload, store, or transmit your documents to our servers. However, when you choose to share documents through integrated sharing features, those actions are subject to the terms of the respective sharing services.''',
      },
      <String, String>{
        'heading': 'Open Source License',
        'content':
            '''The FlitPDF source code and repository documentation are made available under the MIT License unless otherwise noted. The FlitPDF name, logo, app icon, and branding are reserved and may not be used to imply endorsement or official status for a modified build.''',
      },
      <String, String>{
        'heading': 'Prohibited Uses',
        'content': '''You may not use FlitPDF to:

• Process illegal, harmful, or copyrighted content without authorization
• Use the app in any way that violates applicable laws or regulations
• Distribute malware or engage in any harmful activities
• Misrepresent a fork or modified version as the official FlitPDF project''',
      },
      <String, String>{
        'heading': 'Disclaimer of Warranties',
        'content':
            '''FlitPDF is provided "as is" without warranties of any kind. We do not guarantee that the app will be error-free, uninterrupted, or meet your specific requirements. Use of the app is at your own risk.''',
      },
      <String, String>{
        'heading': 'Limitation of Liability',
        'content':
            '''To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of FlitPDF, including but not limited to loss of data, profits, or business interruption.''',
      },
      <String, String>{
        'heading': 'App Updates and Termination',
        'content':
            '''We reserve the right to modify, suspend, or discontinue the app at any time. We may also update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.''',
      },
      <String, String>{
        'heading': 'Governing Law',
        'content':
            '''These terms are governed by and construed in accordance with applicable laws. Any disputes arising from these terms shall be resolved through appropriate legal channels.''',
      },
      <String, String>{
        'heading': 'Contact Information',
        'content':
            '''For questions about these Terms and Conditions, please contact us at rohitbhure.cse@gmail.com.''',
      },
    ],
  };

  // Privacy Policy
  static const Map<String, dynamic> privacyPolicy = <String, dynamic>{
    'title': 'Privacy Policy',
    'lastUpdated': 'April 20, 2026',
    'sections': <Map<String, String>>[
      <String, String>{
        'heading': 'Information We Collect',
        'content':
            '''FlitPDF collects minimal personal information necessary for app functionality:

• Recent Files: File names and paths of recently accessed documents (stored locally on your device)
• App Usage Data: Information about which tools you use most frequently (stored locally)
• Device Information: Basic device information for app performance and compatibility

We do not collect, store, or transmit your actual document contents or personal files to our servers.''',
      },
      <String, String>{
        'heading': 'How We Use Your Information',
        'content': '''The information we collect is used solely to:

• Provide app functionality and improve user experience
• Remember your recently used files for quick access
• Track app usage patterns to prioritize feature development
• Ensure app compatibility and performance on your device

All processing occurs locally on your device.''',
      },
      <String, String>{
        'heading': 'Data Storage and Security',
        'content':
            '''• All user data is stored locally on your device using secure storage mechanisms
• We do not upload, transmit, or share your documents or personal information with third parties
• Recent files and usage data can be cleared at any time through app settings
• Your documents remain private and are never accessed by us''',
      },
      <String, String>{
        'heading': 'Permissions',
        'content':
            '''FlitPDF requests the following permissions to provide core functionality:

• Camera: For document scanning features
• Storage: To read and save PDF files and images
• Internet: For app updates and optional sharing features

All permissions are optional and can be denied without affecting basic app functionality.''',
      },
      <String, String>{
        'heading': 'Third-Party Services',
        'content':
            '''FlitPDF may integrate with third-party services for specific features:

• File sharing services (when you choose to share documents)
• Google Sign-In and Firebase services (only when those optional features are configured and used)
• Cloud storage services (when you choose to save files to cloud)

We do not control these third-party services and encourage you to review their privacy policies.''',
      },
      <String, String>{
        'heading': 'Data Retention',
        'content':
            '''• Recent files data is retained until you clear it or uninstall the app
• Usage statistics are stored locally and can be reset through app settings
• No data is retained on our servers''',
      },
      <String, String>{
        'heading': 'Your Rights',
        'content': '''You have the right to:

• Access and review all data stored by the app
• Delete recent files history and usage data
• Uninstall the app to remove all locally stored data
• Contact us with privacy concerns''',
      },
      <String, String>{
        'heading': 'Changes to This Policy',
        'content':
            '''We may update this Privacy Policy from time to time. We will notify users of any material changes through app updates or in-app notifications.''',
      },
      <String, String>{
        'heading': 'Contact Us',
        'content':
            '''For privacy-related questions or concerns, please contact us at rohitbhure.cse@gmail.com or through the app's support features.''',
      },
    ],
  };

  // About Us
  static const Map<String, dynamic> aboutUs = <String, dynamic>{
    'title': 'About Us',
    'lastUpdated': 'April 20, 2026',
    'sections': <Map<String, String>>[
      <String, String>{
        'heading': 'About FlitPDF',
        'content':
            '''FlitPDF is an open-source mobile application designed to simplify PDF document management and processing. It provides tools to scan, create, convert, compress, and manipulate PDF files directly on mobile devices.''',
      },
      <String, String>{
        'heading': 'Our Features',
        'content': '''• PDF Scanner - Scan documents and convert them to PDF
• Image to PDF Converter - Convert images to PDF format
• PDF Compressor - Reduce PDF file sizes
• Image Compressor - Compress image files
• Document Merger - Combine multiple PDFs into one
• And many more PDF processing tools''',
      },
      <String, String>{
        'heading': 'Our Mission',
        'content':
            '''Our mission is to make document management accessible and efficient for everyone. We believe that powerful PDF tools should be available to all users, and that open collaboration helps the app improve faster and more responsibly.''',
      },
      <String, String>{
        'heading': 'Privacy & Security',
        'content':
            '''We prioritize your privacy and security. FlitPDF processes your documents locally on your device whenever possible, and we never upload your files to our servers without your explicit consent. Your documents remain private and secure.''',
      },
      <String, String>{
        'heading': 'Contact Us',
        'content':
            '''If you have questions, feedback, or want to contribute, please contact us through the app or email rohitbhure.cse@gmail.com. We welcome responsible community contributions and thoughtful feedback.''',
      },
    ],
  };
}
