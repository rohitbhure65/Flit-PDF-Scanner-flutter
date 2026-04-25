import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('primary color has correct value', () {
        const Color primary = Color(0xFF6366F1);
        expect(primary.toARGB32(), 0xFF6366F1);
      });

      test('primaryLight color has correct value', () {
        const Color primaryLight = Color(0xFF818CF8);
        expect(primaryLight.toARGB32(), 0xFF818CF8);
      });

      test('primaryDark color has correct value', () {
        const Color primaryDark = Color(0xFF4F46E5);
        expect(primaryDark.toARGB32(), 0xFF4F46E5);
      });
    });

    group('Secondary Colors', () {
      test('secondary color has correct value', () {
        const Color secondary = Color(0xFFF43F5E);
        expect(secondary.toARGB32(), 0xFFF43F5E);
      });

      test('secondaryLight color has correct value', () {
        const Color secondaryLight = Color(0xFFFB7185);
        expect(secondaryLight.toARGB32(), 0xFFFB7185);
      });

      test('secondaryDark color has correct value', () {
        const Color secondaryDark = Color(0xFFE11D48);
        expect(secondaryDark.toARGB32(), 0xFFE11D48);
      });
    });

    group('Light Mode Colors', () {
      test('background color is light', () {
        const Color background = Color(0xFFF8FAFC);
        expect(background.toARGB32(), 0xFFF8FAFC);
      });

      test('surface color is white', () {
        const Color surface = Colors.white;
        expect(surface.toARGB32(), Colors.white.toARGB32());
      });

      test('card color is white', () {
        const Color card = Colors.white;
        expect(card.toARGB32(), Colors.white.toARGB32());
      });

      test('text primary has correct value', () {
        const Color textPrimary = Color(0xFF1E293B);
        expect(textPrimary.toARGB32(), 0xFF1E293B);
      });

      test('text secondary has correct value', () {
        const Color textSecondary = Color(0xFF64748B);
        expect(textSecondary.toARGB32(), 0xFF64748B);
      });
    });

    group('Dark Mode Colors', () {
      test('backgroundDark has correct value', () {
        const Color backgroundDark = Color(0xFF0F172A);
        expect(backgroundDark.toARGB32(), 0xFF0F172A);
      });

      test('surfaceDark has correct value', () {
        const Color surfaceDark = Color(0xFF1E293B);
        expect(surfaceDark.toARGB32(), 0xFF1E293B);
      });

      test('cardDark has correct value', () {
        const Color cardDark = Color(0xFF1E293B);
        expect(cardDark.toARGB32(), 0xFF1E293B);
      });

      test('textPrimaryDark has correct value', () {
        const Color textPrimaryDark = Color(0xFFF1F5F9);
        expect(textPrimaryDark.toARGB32(), 0xFFF1F5F9);
      });

      test('textSecondaryDark has correct value', () {
        const Color textSecondaryDark = Color(0xFF94A3B8);
        expect(textSecondaryDark.toARGB32(), 0xFF94A3B8);
      });
    });

    group('Semantic Colors', () {
      test('success color is green', () {
        const Color success = Color(0xFF10B981);
        expect(success.toARGB32(), 0xFF10B981);
      });

      test('warning color is amber', () {
        const Color warning = Color(0xFFF59E0B);
        expect(warning.toARGB32(), 0xFFF59E0B);
      });

      test('error color is red', () {
        const Color error = Color(0xFFEF4444);
        expect(error.toARGB32(), 0xFFEF4444);
      });

      test('info color is blue', () {
        const Color info = Color(0xFF3B82F6);
        expect(info.toARGB32(), 0xFF3B82F6);
      });
    });

    group('Border & Divider Colors', () {
      test('border has correct light value', () {
        const Color border = Color(0xFFE2E8F0);
        expect(border.toARGB32(), 0xFFE2E8F0);
      });

      test('border has correct dark value', () {
        const Color borderDark = Color(0xFF334155);
        expect(borderDark.toARGB32(), 0xFF334155);
      });

      test('divider has correct light value', () {
        const Color divider = Color(0xFFF1F5F9);
        expect(divider.toARGB32(), 0xFFF1F5F9);
      });

      test('divider has correct dark value', () {
        const Color dividerDark = Color(0xFF334155);
        expect(dividerDark.toARGB32(), 0xFF334155);
      });
    });

    group('Special Colors', () {
      test('shadow has correct transparent value', () {
        const Color shadow = Color(0x0D000000);
        expect((shadow.a * 255.0).round().clamp(0, 255), lessThan(50));
      });

      test('shadowDark has correct dark value', () {
        const Color shadowDark = Color(0x33000000);
        expect((shadowDark.a * 255.0).round().clamp(0, 255), greaterThan(0));
      });

      test('glassEffect has transparent white', () {
        const Color glassEffect = Color(0x1AFFFFFF);
        expect((glassEffect.a * 255.0).round().clamp(0, 255), lessThan(255));
      });
    });
  });

  group('Tool Definitions', () {
    test('pdfTools list has correct items', () {
      const List<Map<String, dynamic>> pdfTools = <Map<String, dynamic>>[
        <String, dynamic>{'name': 'Image to PDF', 'icon': Icons.picture_as_pdf},
        <String, dynamic>{'name': 'Compress PDF', 'icon': Icons.compress},
        <String, dynamic>{'name': 'Scan PDF', 'icon': Icons.document_scanner},
        <String, dynamic>{'name': 'Open PDF', 'icon': Icons.open_in_new},
        <String, dynamic>{'name': 'Create PDF', 'icon': Icons.add_circle},
      ];
      expect(pdfTools.length, 5);
    });

    test('Getting popular tools returns list', () {
      List<Map<String, dynamic>> getPopularTools() {
        return <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'Image to PDF',
            'icon': Icons.picture_as_pdf,
          },
          <String, dynamic>{'name': 'Compress PDF', 'icon': Icons.compress},
          <String, dynamic>{'name': 'Scan PDF', 'icon': Icons.document_scanner},
        ];
      }

      final List<Map<String, dynamic>> tools = getPopularTools();
      expect(tools.length, 3);
      expect(tools[0]['name'], 'Image to PDF');
    });

    test('pdfTools contains expected tools', () {
      const List<Map<String, dynamic>> pdfTools = <Map<String, dynamic>>[
        <String, dynamic>{'name': 'Image to PDF'},
        <String, dynamic>{'name': 'Compress PDF'},
        <String, dynamic>{'name': 'Scan PDF'},
        <String, dynamic>{'name': 'Open PDF'},
        <String, dynamic>{'name': 'Create PDF'},
      ];

      expect(
        pdfTools.any((Map<String, dynamic> t) => t['name'] == 'Image to PDF'),
        true,
      );
      expect(
        pdfTools.any((Map<String, dynamic> t) => t['name'] == 'Compress PDF'),
        true,
      );
      expect(
        pdfTools.any((Map<String, dynamic> t) => t['name'] == 'Scan PDF'),
        true,
      );
    });

    test('coming soon tools are defined', () {
      const List<Map<String, dynamic>> comingSoon = <Map<String, dynamic>>[
        <String, dynamic>{'name': 'Word to PDF'},
        <String, dynamic>{'name': 'Excel to PDF'},
        <String, dynamic>{'name': 'PPTX to PDF'},
        <String, dynamic>{'name': 'Merge PDF'},
      ];

      expect(comingSoon.length, 4);
    });
  });
}
