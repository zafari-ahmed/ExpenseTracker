import 'package:expense_tracker/features/cards/domain/sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildFromFieldValues', () {
    test('SCB paid at KFC sample', () {
      const sample =
          'Dear Client, PKR 1,811.00 have been paid at KFC - JAUHAR KARACHI PAK on 24-07-26 using Credit Card no 8953. Avail Limit PKR1498189.00. SCBPL';
      final suggestion = SmsParser.buildFromFieldValues(
        sampleMessage: sample,
        amountValue: '1,811.00',
        placeValue: 'KFC - JAUHAR KARACHI PAK',
        dateValue: '24-07-26',
      );
      expect(suggestion, isNotNull);
      final parsed = SmsParser.parse(
        smsBody: sample,
        amountPattern: suggestion!.amountPattern,
        placePattern: suggestion.placePattern,
        datePattern: suggestion.datePattern,
        fallbackDate: DateTime(2020),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amount, 1811.0);
      expect(parsed.place, 'KFC - JAUHAR KARACHI PAK');
      expect(parsed.transactionDate, DateTime(2026, 7, 24));
    });

    test('NK COMMUNICATION payment sample', () {
      const sample =
          'Your payment at NK COMMUNICATION has been completed. Transaction ID 43787413536 Till No. 980209272 Amount: Rs. 1020.00 at 23 December 2025.';
      final suggestion = SmsParser.buildFromFieldValues(
        sampleMessage: sample,
        amountValue: '1020.00',
        placeValue: 'NK COMMUNICATION',
        dateValue: '23 December 2025',
      );
      expect(suggestion, isNotNull);
      final parsed = SmsParser.parse(
        smsBody: sample,
        amountPattern: suggestion!.amountPattern,
        placePattern: suggestion.placePattern,
        datePattern: suggestion.datePattern,
        fallbackDate: DateTime(2020),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amount, 1020.0);
      expect(parsed.place, 'NK COMMUNICATION');
      expect(parsed.transactionDate, DateTime(2025, 12, 23));
    });

    test('HBL charged at sample', () {
      const sample =
          'Dear Customer, Your HBL CreditCard (ending with 5950) has been charged at DAS NUMBERI for PKR-1,802.00 on 25/Jul/2026.';
      final suggestion = SmsParser.buildFromFieldValues(
        sampleMessage: sample,
        amountValue: '1,802.00',
        placeValue: 'DAS NUMBERI',
        dateValue: '25/Jul/2026',
      );
      expect(suggestion, isNotNull);
      final parsed = SmsParser.parse(
        smsBody: sample,
        amountPattern: suggestion!.amountPattern,
        placePattern: suggestion.placePattern,
        datePattern: suggestion.datePattern,
        fallbackDate: DateTime(2020),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amount, 1802.0);
      expect(parsed.place, 'DAS NUMBERI');
      expect(parsed.transactionDate, DateTime(2026, 7, 25));
    });

    test('Telenor online payment of amount', () {
      const sample =
          'Dear Customer, your payment made through Online of 535.0000 has been credited against 3491286731. Thank you for using Telenor Postpaid.';
      final suggestion = SmsParser.buildFromFieldValues(
        sampleMessage: sample,
        amountValue: '535.0000',
        placeValue: '3491286731',
      );
      expect(suggestion, isNotNull);
      final parsed = SmsParser.parse(
        smsBody: sample,
        amountPattern: suggestion!.amountPattern,
        placePattern: suggestion.placePattern,
        datePattern: suggestion.datePattern,
        fallbackDate: DateTime(2026, 1, 1),
      );
      expect(parsed, isNotNull);
      expect(parsed!.amount, 535.0);
      expect(parsed.place, '3491286731');
    });
  });

  group('suggestFromSample improvements', () {
    test('auto-suggest works for SCB and HBL', () {
      const scb =
          'Dear Client, PKR 1,811.00 have been paid at KFC - JAUHAR KARACHI PAK on 24-07-26 using Credit Card no 8953. Avail Limit PKR1498189.00. SCBPL';
      final scbSuggestion = SmsParser.suggestFromSample(scb);
      final scbParsed = SmsParser.parse(
        smsBody: scb,
        amountPattern: scbSuggestion.amountPattern,
        placePattern: scbSuggestion.placePattern,
        datePattern: scbSuggestion.datePattern,
        fallbackDate: DateTime(2020),
      );
      expect(scbParsed?.amount, 1811.0);
      expect(scbParsed?.place, contains('KFC'));

      const hbl =
          'Dear Customer, Your HBL CreditCard (ending with 5950) has been charged at DAS NUMBERI for PKR-1,802.00 on 25/Jul/2026.';
      final hblSuggestion = SmsParser.suggestFromSample(hbl);
      final hblParsed = SmsParser.parse(
        smsBody: hbl,
        amountPattern: hblSuggestion.amountPattern,
        placePattern: hblSuggestion.placePattern,
        datePattern: hblSuggestion.datePattern,
        fallbackDate: DateTime(2020),
      );
      expect(hblParsed?.amount, 1802.0);
      expect(hblParsed?.place, 'DAS NUMBERI');
    });
  });
}
