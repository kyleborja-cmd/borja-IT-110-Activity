import 'package:flutter_test/flutter_test.dart';
import 'package:semester_project/app.dart';

void main() {
  testWidgets('the login screen is the only initial app screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SemesterProjectApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Your cafe is ready to play.'), findsNothing);
    expect(find.text('Back to dashboard'), findsNothing);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
