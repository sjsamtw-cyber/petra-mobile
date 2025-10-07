import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petrasoft_school_management_solutions/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Integration Tests', () {
    testWidgets('SchoolCodeScreen loads and displays all key widgets', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Check for presence of SchoolCodeScreen widgets by key
      expect(find.byKey(const Key('schoolCodeInput')), findsOneWidget);
      expect(find.byKey(const Key('submitSchoolCodeButton')), findsOneWidget);
      expect(find.byKey(const Key('joinUsButton')), findsOneWidget);
      expect(find.byKey(const Key('petrasoftLogo')), findsOneWidget);
    });

    // Add more integration tests for auth flows here (e.g., successful login, error states, etc.)
  });
}
