import 'package:flutter_test/flutter_test.dart';
import 'package:hsum_chaint/main.dart';

void main() {
  testWidgets('auth navigation flows to signup', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
