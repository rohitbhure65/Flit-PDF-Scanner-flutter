import 'package:flitpdf/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlitPdfApp', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      // Verify app widget is created
      expect(find.byType(FlitPdfApp), findsOneWidget);
    });

    testWidgets('App has GetMaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GetMaterialApp), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.title, 'FlitPDF');
    });

    testWidgets('Debug banner is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.debugShowCheckedModeBanner, false);
    });

    testWidgets('App uses Material 3', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.useMaterial3, true);
      expect(app.darkTheme?.useMaterial3, true);
    });

    testWidgets('App uses system theme mode', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.themeMode, ThemeMode.system);
    });

    testWidgets('Light theme has correct brightness', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.brightness, Brightness.light);
    });

    testWidgets('Dark theme has correct brightness', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.darkTheme?.brightness, Brightness.dark);
    });

    testWidgets('Light theme has app bar theme', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.appBarTheme, isNotNull);
    });

    testWidgets('Light theme app bar is centered', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.appBarTheme.centerTitle, true);
    });

    testWidgets('Dark theme app bar is centered', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.darkTheme?.appBarTheme.centerTitle, true);
    });

    testWidgets('Light theme has card theme with rounded corners', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      final RoundedRectangleBorder? cardShape =
          app.theme?.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape, isNotNull);
    });

    testWidgets('Light theme has elevated button theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.elevatedButtonTheme.style, isNotNull);
    });

    testWidgets('Light theme has outlined button theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.outlinedButtonTheme.style, isNotNull);
    });

    testWidgets('Light theme has input decoration theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.inputDecorationTheme, isNotNull);
    });

    testWidgets('Light theme input decoration is filled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.inputDecorationTheme.filled, true);
    });

    testWidgets('Dark theme has input decoration theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.darkTheme?.inputDecorationTheme, isNotNull);
    });
  });

  group('ThemeColors', () {
    testWidgets('Light theme has scaffold background color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.theme?.scaffoldBackgroundColor, isNotNull);
    });

    testWidgets('Dark theme has scaffold background color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.darkTheme?.scaffoldBackgroundColor, isNotNull);
    });
  });

  group('Navigator', () {
    testWidgets('App has navigator key', (WidgetTester tester) async {
      await tester.pumpWidget(const FlitPdfApp());
      await tester.pump(const Duration(milliseconds: 100));

      final GetMaterialApp app = tester.widget(
        find.byType(GetMaterialApp).first,
      );
      expect(app.navigatorKey, isNotNull);
    });
  });
}
