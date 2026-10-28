import 'package:expense_tracker/features/cards/domain/sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores SCB-style into your account transfers', () {
    expect(
      SmsParser.shouldIgnoreSms(
        'Dear Client, PKR 25,000.00 has been transferred into your account. SCBPL',
      ),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        'A funds transfer of PKR 10,000 was made into your account ending 1234.',
      ),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        'Credit: transfer into your account PKR 5,000.00',
      ),
      isTrue,
    );
  });

  test('parses HBL charged-at notification text', () {
    const body =
        'Dear Customer, Your HBL CreditCard (ending with 5950) has been charged at ENERGY PSO for PKR 4,000.00 on 27/Oct/2026.';
    expect(SmsParser.shouldIgnoreSms(body), isFalse);
    expect(SmsParser.hasExpenseSignal(body.toLowerCase()), isTrue);
    expect(SmsParser.hasStrongExpenseSignal(body.toLowerCase()), isTrue);

    final parsed = SmsParser.parse(
      smsBody: body,
      amountPattern: SmsParser.defaultAmountPatterns.first,
      placePattern: SmsParser.defaultPlacePatterns.first,
      datePattern: SmsParser.defaultDatePattern,
      fallbackDate: DateTime(2020),
    );
    expect(parsed, isNotNull);
    expect(parsed!.amount, 4000.0);
    expect(parsed.place, 'ENERGY PSO');
    expect(parsed.transactionDate, DateTime(2026, 10, 27));
  });

  test('ignores advisory and OTP notification wording', () {
    expect(
      SmsParser.shouldIgnoreSms(
        'HBL Customer Advisory: Please update your mobile app for better security.',
      ),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        '152555 is your OTP for online transaction. Do not share.',
      ),
      isTrue,
    );
  });

  test('keeps debit notification and still ignores promo cashback', () {
    expect(
      SmsParser.shouldIgnoreSms(
        'Txn: charged at ENERGY PSO for PKR-4,000.00 on 27/Oct/2026',
      ),
      isFalse,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        'Get PKR 500 cashback on your next spend. Exclusive offer. T&C apply.',
      ),
      isTrue,
    );
  });
}
