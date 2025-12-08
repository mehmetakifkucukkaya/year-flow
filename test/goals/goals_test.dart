import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:year_flow/features/goals/presentation/goal_create_page.dart';
import 'package:year_flow/features/goals/presentation/goals_page.dart';

void main() {
  group('Goals Pages Widget Tests', () {
    testWidgets('Goals page renders correctly', (WidgetTester tester) async {
      // Build the goals page with ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GoalsPage(),
          ),
        ),
      );

      // Verify that the page structure exists
      expect(find.byType(GoalsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Goal create page renders correctly', (WidgetTester tester) async {
      // Build the goal create page with ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GoalCreatePage(),
          ),
        ),
      );

      // Verify that the page structure exists
      expect(find.byType(GoalCreatePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

