import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:not_a_writing_app/features/onboarding/presentation/pages/onboarding_screen.dart';

final Uint8List _k1x1TransparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final key = utf8.decode(message!.buffer.asUint8List());

      // Manifests must be valid
      if (key == 'AssetManifest.bin') {
        return const StandardMessageCodec().encodeMessage(<String, dynamic>{});
      }
      if (key == 'AssetManifest.json') {
        final bytes = utf8.encode('{}');
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }

      // Any image asset -> return a valid tiny PNG
      if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
        return ByteData.view(_k1x1TransparentPng.buffer);
      }

      // Fallback for other assets
      return ByteData.view(Uint8List(0).buffer);
    });
  });

  testWidgets('renders first onboarding page and "Next" button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const OnboardingScreen(),
        routes: {
          '/login': (_) => const _DummyPage('login'),
        },
      ),
    );

    expect(find.text('Write Freely'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsNothing);
  });

  testWidgets('tapping Skip navigates to /login', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const OnboardingScreen(),
        routes: {
          '/login': (_) => const _DummyPage('login'),
        },
      ),
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('tapping Next twice then Get Started navigates to /login', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const OnboardingScreen(),
        routes: {
          '/login': (_) => const _DummyPage('login'),
        },
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Connect Creatively'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Start Your Journey'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('swiping updates the button label to Get Started on last page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
  });
}

class _DummyPage extends StatelessWidget {
  final String label;
  const _DummyPage(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(label)));
}