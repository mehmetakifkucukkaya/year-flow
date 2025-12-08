import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:year_flow/features/auth/presentation/login_page.dart';
import 'package:year_flow/features/auth/presentation/register_page.dart';

void main() {
  group('Auth Pages Widget Tests', () {
    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      // Build the login page with ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Verify that the page structure exists
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Register page renders correctly', (WidgetTester tester) async {
      // Build the register page with ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );

      // Verify that the page structure exists
      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

