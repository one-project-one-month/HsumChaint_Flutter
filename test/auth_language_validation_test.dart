import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hsum_chaint/presentation/widgets/custom_text_field.dart';

void main() {
  testWidgets('Phone input strictly blocks Myanmar numerals and non-English characters', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomInputTextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '၀၉၁၂၃၄၅၆၇၈');
    await tester.pump();
    expect(controller.text, isEmpty);

    await tester.enterText(find.byType(TextFormField), 'ဆွမ်းချိုင့်');
    await tester.pump();
    expect(controller.text, isEmpty);

    await tester.enterText(find.byType(TextFormField), '+95912345678');
    await tester.pump();
    expect(controller.text, '+95912345678');

    await tester.enterText(find.byType(TextFormField), '0912345678');
    await tester.pump();
    expect(controller.text, '0912345678');
  });

  test('English-only password regex validation strictly blocks Burmese characters', () {
    final passwordRegex = RegExp(r'^[\x21-\x7E]+$');

    expect(passwordRegex.hasMatch('Pass123!'), isTrue);
    expect(passwordRegex.hasMatch('P@ssw0rd_99#'), isTrue);
    expect(passwordRegex.hasMatch('စကားဝှက်၁၂၃'), isFalse);
    expect(passwordRegex.hasMatch('Pass 123'), isFalse);
    expect(passwordRegex.hasMatch('Password၁၂၃'), isFalse);
  });

  test('English phone regex validation strictly blocks Myanmar numerals', () {
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

    expect(phoneRegex.hasMatch('0912345678'), isTrue);
    expect(phoneRegex.hasMatch('+95912345678'), isTrue);
    expect(phoneRegex.hasMatch('၀၉၁၂၃၄၅၆၇၈'), isFalse);
    expect(phoneRegex.hasMatch('0912345၆၇၈'), isFalse);
    expect(phoneRegex.hasMatch('phone123'), isFalse);
  });
}
