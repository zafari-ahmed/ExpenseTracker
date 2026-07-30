import 'package:expense_tracker/features/cards/domain/sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores OTP and credit SMS, keeps expense SMS', () {
    expect(
      SmsParser.shouldIgnoreSms('PKR 130,000 received from Asad'),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms('152555 is your OTP for online transaction'),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms('Rs.500 has been credited to your account'),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        'Txn: charged at BACHAA PARTY for PKR-2,361.00 on 28/Jul/2026',
      ),
      isFalse,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        'Amount PKR 500 debited for purchase at FOODLAND',
      ),
      isFalse,
    );
  });

  test('custom ignore phrases match full SMS samples', () {
    const sample =
        'Dear customer, your bill payment of Rs.200 to KE was successful. Ref 99881';
    expect(
      SmsParser.shouldIgnoreSms(
        'Dear customer, your bill payment of Rs.200 to KE was successful. Ref 99881 Thank you',
        extraIgnorePhrases: const [sample],
      ),
      isTrue,
    );
    expect(
      SmsParser.shouldIgnoreSms(
        'Txn: charged at STORE for PKR-100.00',
        extraIgnorePhrases: const [sample],
      ),
      isFalse,
    );
  });
}
