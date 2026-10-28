class SmsParseResult {
  SmsParseResult({
    required this.amount,
    required this.place,
    required this.transactionDate,
  });

  final double amount;
  final String place;
  final DateTime transactionDate;
}

class SmsRegexSuggestion {
  SmsRegexSuggestion({
    required this.amountPattern,
    required this.placePattern,
    this.datePattern,
  });

  final String amountPattern;
  final String placePattern;
  final String? datePattern;
}

abstract final class SmsParser {
  /// Global ignore list — applied even if a card rule forgot exclude keywords.
  static const List<String> defaultIgnorePhrases = <String>[
    // Auth / OTP
    'otp',
    'one time password',
    'one-time password',
    'one time pin',
    'one-time pin',
    'verification code',
    'verification pin',
    'auth code',
    'authentication code',
    'passcode',
    'login code',
    'security code',
    'do not share',
    'dont share',
    "don't share",
    // Incoming money / credits (not expenses)
    'received from',
    'has been credited',
    'have been credited',
    'is credited',
    'credited to',
    'credited in',
    'credited with',
    'amount credited',
    'deposit of',
    'deposited',
    'cashback credited',
    'refund credited',
    'refund of',
    'salary credited',
    'has been received',
    'have received',
    'you received',
    'you have received',
    'funds received',
    'money received',
    // Incoming transfers (SCB / bank credit alerts)
    'into your account',
    'made into your',
    'made into your account',
    'transferred into your',
    'transfer into your',
    'has been transferred into',
    'have been transferred into',
    // Advisory / non-spend alerts
    'customer advisory',
    'important advisory',
  ];

  /// Marketing / promo SMS from the same bank sender — skip unless the
  /// message is also a real debit (see [hasExpenseSignal]).
  static const List<String> promoIgnorePhrases = <String>[
    'promotional',
    'promotion',
    'discount',
    '% off',
    'percent off',
    'cashback offer',
    'limited time offer',
    'limited period offer',
    'avail now',
    't&c apply',
    't & c apply',
    'terms and conditions',
    'click here',
    'unsubscribe',
    'offer expires',
    'congratulations',
    'you have won',
    'lucky draw',
    'use code',
    'promo code',
    'voucher',
    'download the app',
    'install now',
    'shop now',
    'flat rs',
    'flat pkr',
    'offer',
    'cashback',
    'save up to',
    'exclusive',
    'mega deal',
    'star deal',
    'win a',
    'you have won',
    'reward points',
    'avail this',
    'avail the',
    't&cs',
    'tnc apply',
  ];

  /// Strong debit wording. Promo copy with only weak phrases like "for rs"
  /// must not create an expense.
  static const List<String> strongExpenseSignalPhrases = <String>[
    'debited',
    'charged at',
    'charged for',
    'been charged',
    'has been charged',
    'amount debited',
    'amt debited',
    'spent at',
    'spent on',
    'paid at',
    'purchase at',
    'purchased at',
    'withdrawn',
    'withdrawal',
    'pos purchase',
    'pos txn',
    'pos transaction',
    'txn at',
    'transaction at',
    'have been paid',
  ];

  /// Phrases that strongly indicate a spend / debit SMS.
  static const List<String> expenseSignalPhrases = <String>[
    'debited',
    'charged at',
    'charged for',
    'been charged',
    'has been charged',
    'spent at',
    'spent on',
    'purchase at',
    'purchased at',
    'paid at',
    'payment at',
    'have been paid',
    'payment made',
    'payment of',
    'payment for',
    'withdrawn',
    'withdrawal',
    'pos purchase',
    'pos txn',
    'pos transaction',
    'txn at',
    'transaction at',
    'for pkr-',
    'for pkr ',
    'for rs',
    'amount debited',
    'amt debited',
  ];

  /// Returns true when this SMS should never create an expense transaction.
  ///
  /// [extraIgnorePhrases] comes from Settings → SMS ignore list (full samples
  /// or short phrases). A match means the SMS body contains the phrase.
  /// [enabledDefaultIgnorePhrases] lets users disable selected built-in phrases.
  static bool shouldIgnoreSms(
    String smsBody, {
    List<String> extraIgnorePhrases = const <String>[],
    List<String>? enabledDefaultIgnorePhrases,
  }) {
    final lower = _normalizeSms(smsBody).toLowerCase();
    if (lower.isEmpty) return true;

    final defaults = enabledDefaultIgnorePhrases ?? defaultIgnorePhrases;
    for (final phrase in defaults) {
      if (lower.contains(phrase)) return true;
    }

    for (final raw in extraIgnorePhrases) {
      final phrase = _normalizeSms(raw).toLowerCase();
      if (phrase.isEmpty) continue;
      if (lower.contains(phrase)) return true;
    }

    // "152555 is your otp..." / "your otp is 152555"
    if (RegExp(r'\b(otp|passcode|pin)\b').hasMatch(lower) &&
        RegExp(r'\b\d{4,8}\b').hasMatch(lower)) {
      return true;
    }

    // Pure credit/incoming alerts: amount + received/credited, no spend signal.
    final looksLikeCredit = RegExp(
      r'\b(received|credited|deposited|credit)\b',
    ).hasMatch(lower);
    if (looksLikeCredit && !hasExpenseSignal(lower)) {
      return true;
    }

    // "Funds transfer" / generic transfer wording without a debit verb.
    if (_looksLikeIncomingTransfer(lower) && !hasExpenseSignal(lower)) {
      return true;
    }

    // Promo / discount alerts: skip unless the SMS is clearly a debit.
    if (_hasPromoPhrase(lower) && !hasStrongExpenseSignal(lower)) {
      return true;
    }

    return false;
  }

  /// Incoming transfer / credit transfer wording (no debit verb).
  static bool _looksLikeIncomingTransfer(String lower) {
    if (lower.contains('into your account') ||
        lower.contains('made into your') ||
        lower.contains('transferred into your') ||
        lower.contains('transfer into your')) {
      return true;
    }
    if (lower.contains('funds transfer') ||
        lower.contains('fund transfer') ||
        lower.contains('has been transferred') ||
        lower.contains('have been transferred')) {
      return true;
    }
    return false;
  }

  static bool _hasPromoPhrase(String lower) {
    for (final phrase in promoIgnorePhrases) {
      if (lower.contains(phrase)) return true;
    }
    return false;
  }

  static bool hasStrongExpenseSignal(String lowerBody) {
    for (final phrase in strongExpenseSignalPhrases) {
      if (lowerBody.contains(phrase)) return true;
    }
    return false;
  }

  /// Inbox sender vs the ID saved on the card.
  /// Short numeric IDs must match exactly (or as a suffix), so "80" does
  /// not match every "8080…" bank / promo sender.
  static bool senderMatches(String address, String configured) {
    final addr = normalizeSender(address);
    final conf = normalizeSender(configured);
    if (addr.isEmpty || conf.isEmpty) return false;
    if (addr == conf) return true;

    final shorter = addr.length <= conf.length ? addr : conf;
    final longer = addr.length <= conf.length ? conf : addr;
    if (shorter.length < 3) return false;

    if (RegExp(r'^\d+$').hasMatch(shorter)) {
      if (shorter.length < 4) return false;
      return longer.endsWith(shorter);
    }

    return longer.contains(shorter);
  }

  static String normalizeSender(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// True when [smsBody] shares the debit wording from the saved sample.
  /// Promo/discount SMS from the same sender fail this check.
  static bool matchesConfiguredSample(String smsBody, String sampleMessage) {
    final sample = _normalizeSms(sampleMessage).toLowerCase();
    final body = _normalizeSms(smsBody).toLowerCase();
    if (sample.isEmpty || body.isEmpty) return false;

    final sampleSignals =
        expenseSignalPhrases.where(sample.contains).toList(growable: false);
    if (sampleSignals.isEmpty) {
      return hasExpenseSignal(body);
    }
    return sampleSignals.every(body.contains);
  }

  static List<String> effectiveDefaultIgnorePhrases({
    List<String> disabledPhrases = const <String>[],
  }) {
    if (disabledPhrases.isEmpty) return List<String>.from(defaultIgnorePhrases);
    final disabled = disabledPhrases
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    return defaultIgnorePhrases
        .where((phrase) => !disabled.contains(phrase.toLowerCase()))
        .toList(growable: false);
  }

  static bool hasExpenseSignal(String lowerBody) {
    for (final phrase in expenseSignalPhrases) {
      if (lowerBody.contains(phrase)) return true;
    }
    return false;
  }

  /// Numeric amount capture: supports 1020.00, 1,811.00, 535.0000
  static const String amountCaptureGroup =
      r'([0-9]+(?:,[0-9]{3})*(?:\.[0-9]{1,4})?)';

  static const String looseAmountToken =
      r'(?:[0-9]+(?:,[0-9]{3})*(?:\.[0-9]+)?|[0-9]+)';

  static const List<String> defaultAmountPatterns = <String>[
    // HBL-style: for PKR-2,361.00 | for PKR 2,361.00
    r'for\s+(?:PKR|Rs\.?|RS\.?)\s*[-:]?\s*' + amountCaptureGroup,
    // Amount: Rs. 1020.00
    r'amount\s*[:\-]?\s*(?:PKR|Rs\.?|RS\.?)?\s*[-:]?\s*' + amountCaptureGroup,
    // PKR-2,361.00 | Rs.1234 | Rs 1,234 | USD:12.00
    r'(?:PKR|Rs\.?|RS\.?|INR|USD|AED|SAR)\s*[-:]?\s*' + amountCaptureGroup,
    // Online of 535.0000 / payment of 535.0000
    r'(?:online|payment|txn|transaction)?\s*of\s+' + amountCaptureGroup,
    // 2,361.00 PKR
    amountCaptureGroup + r'\s*[-:]?\s*(?:PKR|Rs\.?|RS\.?|INR|USD|AED|SAR)',
    // amount/debited/charged/paid ... 1234.50
    r'(?:amount|amt|debited|spent|charged|paid|txn|transaction)[^\d]{0,24}' +
        amountCaptureGroup,
  ];

  static const List<String> defaultPlacePatterns = <String>[
    // HBL: charged at BACHAA PARTY for PKR-...
    r'charged\s+at\s+(.+?)\s+for\s+(?:PKR|Rs\.?|RS\.?)',
    // SCB: paid at KFC - JAUHAR ... on 24-07-26
    r'paid\s+at\s+(.+?)\s+on\s+',
    // JazzCash/easypaisa style: payment at NK COMMUNICATION has been completed
    r'payment\s+at\s+(.+?)\s+has\s+been\s+completed',
    // at MERCHANT before for/on/dated
    r'\bat\s+([A-Za-z0-9][A-Za-z0-9 &.\-]{1,60}?)(?=\s+for\b|\s+on\b|\s+dated\b|\s+has\b|[.\n]|$)',
    r'merchant\s*[:\-]?\s*([A-Za-z0-9][A-Za-z0-9 &.\-]{1,60})',
    r'(?:purchase|pos|spent|paid)\s+at\s+([A-Za-z0-9][A-Za-z0-9 &.\-]{1,60}?)(?=\s+for\b|\s+on\b|[.\n]|$)',
    r'\bto\s+([A-Za-z][A-Za-z0-9 &.\-]{1,60}?)(?=\s+on\b|[.\n]|$)',
  ];

  /// Supports 28/07/2026, 24-07-26, 28/Jul/2026, 23 December 2025.
  static const String defaultDatePattern =
      r'([0-9]{1,2}[\/\-.](?:[0-9]{1,2}|[A-Za-z]{3,9})[\/\-.][0-9]{2,4}|[0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4})';

  /// Build regex from a pasted sample + the exact amount / place / date text
  /// copied from that sample (no regex knowledge required).
  static SmsRegexSuggestion? buildFromFieldValues({
    required String sampleMessage,
    required String amountValue,
    required String placeValue,
    String? dateValue,
  }) {
    final sample = _normalizeSms(sampleMessage);
    final amountText = amountValue.trim();
    final placeText = placeValue.trim();
    final dateText = dateValue?.trim() ?? '';

    if (sample.isEmpty || amountText.isEmpty || placeText.isEmpty) {
      return null;
    }

    final amountNeedle = _amountNeedle(amountText);
    final amountPattern = _patternAroundValue(
      sample: sample,
      value: amountNeedle,
      captureGroup: amountCaptureGroup,
      leftBudget: 28,
      rightBudget: 18,
      flexibleCurrency: true,
    );
    if (amountPattern == null) return null;

    final placePattern = _patternAroundValue(
      sample: sample,
      value: placeText,
      captureGroup: r'(.+?)',
      leftBudget: 24,
      rightBudget: 22,
      caseInsensitiveValue: true,
    );
    if (placePattern == null) return null;

    String? datePattern;
    if (dateText.isNotEmpty) {
      datePattern = _patternAroundValue(
        sample: sample,
        value: dateText,
        captureGroup:
            r'([0-9]{1,2}[\/\-.](?:[0-9]{1,2}|[A-Za-z]{3,9})[\/\-.][0-9]{2,4}|[0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4})',
        leftBudget: 16,
        rightBudget: 12,
        caseInsensitiveValue: true,
      );
    }

    return SmsRegexSuggestion(
      amountPattern: amountPattern,
      placePattern: placePattern,
      datePattern: datePattern,
    );
  }

  /// Strip currency labels so we capture only the numeric amount in SMS.
  static String _amountNeedle(String raw) {
    var value = raw.trim();
    value = value.replaceFirst(
      RegExp(r'^(?:PKR|Rs\.?|RS\.?|INR|USD|AED|SAR)\s*[-:]?\s*', caseSensitive: false),
      '',
    );
    return value.trim();
  }

  static String? _patternAroundValue({
    required String sample,
    required String value,
    required String captureGroup,
    required int leftBudget,
    required int rightBudget,
    bool caseInsensitiveValue = false,
    bool flexibleCurrency = false,
  }) {
    if (value.isEmpty) return null;

    final index = caseInsensitiveValue
        ? sample.toLowerCase().indexOf(value.toLowerCase())
        : sample.indexOf(value);
    if (index < 0) return null;

    final end = index + value.length;
    var leftStart = (index - leftBudget).clamp(0, sample.length);
    // If we clipped mid-word, expand left to the start of that word.
    if (leftStart > 0 &&
        !_isSpace(sample[leftStart]) &&
        !_isSpace(sample[leftStart - 1])) {
      final space = sample.lastIndexOf(' ', leftStart);
      leftStart = space < 0 ? 0 : space + 1;
    }

    var rightEnd = (end + rightBudget).clamp(0, sample.length);
    // If we clipped mid-word on the right, expand to the end of that word.
    if (rightEnd < sample.length &&
        !_isSpace(sample[rightEnd - 1]) &&
        !_isSpace(sample[rightEnd])) {
      final space = sample.indexOf(' ', rightEnd);
      rightEnd = space < 0 ? sample.length : space;
    }

    final leftRaw = sample.substring(leftStart, index);
    final rightRaw = sample.substring(end, rightEnd);
    final left = _escapeContext(
      leftRaw,
      flexibleCurrency: flexibleCurrency,
    );
    final right = _escapeContext(
      rightRaw,
      flexibleCurrency: flexibleCurrency,
    );

    if (left.isEmpty && right.isEmpty) {
      return captureGroup;
    }
    return '$left$captureGroup$right';
  }

  static bool _isSpace(String ch) => ch == ' ' || ch == '\n' || ch == '\t';

  static String _escapeContext(String raw, {bool flexibleCurrency = false}) {
    if (raw.isEmpty) return '';
    var text = raw;

    // Don't lock sibling fields (other amounts/dates) into the pattern.
    // Wrap tokens in spaces so placeholders survive punctuation.
    text = text.replaceAllMapped(
      RegExp(
        r'\d{1,2}[\/\-.](?:\d{1,2}|[A-Za-z]{3,9})[\/\-.][0-9]{2,4}|\d{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4}',
      ),
      (_) => ' «DATE» ',
    );
    text = text.replaceAllMapped(
      RegExp(r'\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+\.\d+|\d{4,}'),
      (_) => ' «NUM» ',
    );

    if (flexibleCurrency) {
      text = text.replaceAllMapped(
        RegExp(r'(PKR|Rs\.?|RS\.?|INR|USD|AED|SAR)\s*[-:]?\s*', caseSensitive: false),
        (_) => ' «CUR» ',
      );
    }

    final parts = text.split(RegExp(r'\s+'));
    final escaped = <String>[];
    for (final part in parts) {
      if (part.isEmpty) continue;
      // Strip trailing punctuation from placeholder tokens.
      final token = part.replaceAll(RegExp(r'^[^\w«]+|[^\w»]+$'), '');
      if (token == '«CUR»' || part.contains('«CUR»')) {
        escaped.add(r'(?:PKR|Rs\.?|RS\.?)\s*[-:]?\s*');
      } else if (token == '«DATE»' || part.contains('«DATE»')) {
        escaped.add(
          r'(?:[0-9]{1,2}[\/\-.](?:[0-9]{1,2}|[A-Za-z]{3,9})[\/\-.][0-9]{2,4}|[0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4})',
        );
      } else if (token == '«NUM»' || part.contains('«NUM»')) {
        escaped.add(looseAmountToken);
      } else {
        escaped.add(RegExp.escape(part));
      }
    }
    if (escaped.isEmpty) return '';

    final leadingSpace =
        raw.isNotEmpty && RegExp(r'^\s').hasMatch(raw) ? r'\s+' : '';
    final trailingSpace =
        raw.isNotEmpty && RegExp(r'\s$').hasMatch(raw) ? r'\s+' : '';
    return '$leadingSpace${escaped.join(r'\s+')}$trailingSpace';
  }

  static SmsRegexSuggestion suggestFromSample(String sample) {
    final normalized = _normalizeSms(sample);
    final lower = normalized.toLowerCase();

    // Prefer HBL-style patterns when sample matches that shape.
    if (lower.contains('charged at') &&
        (lower.contains('pkr-') || lower.contains('pkr ') || lower.contains(' for pkr'))) {
      return SmsRegexSuggestion(
        amountPattern: defaultAmountPatterns[0],
        placePattern: defaultPlacePatterns[0],
        datePattern: r'on\s+([0-9]{1,2}[\/\-.][A-Za-z]{3,9}[\/\-.][0-9]{2,4})',
      );
    }

    if (lower.contains('paid at') && lower.contains('pkr')) {
      return SmsRegexSuggestion(
        amountPattern: defaultAmountPatterns[2],
        placePattern: defaultPlacePatterns[1],
        datePattern: r'on\s+([0-9]{1,2}[\/\-.][0-9]{1,2}[\/\-.][0-9]{2,4})',
      );
    }

    if (lower.contains('payment at') && lower.contains('amount')) {
      return SmsRegexSuggestion(
        amountPattern: defaultAmountPatterns[1],
        placePattern: defaultPlacePatterns[2],
        datePattern: r'at\s+([0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4})',
      );
    }

    String amountPattern = defaultAmountPatterns[2];
    for (final pattern in defaultAmountPatterns) {
      if (_firstAmount(normalized, pattern) != null) {
        amountPattern = pattern;
        break;
      }
    }

    String placePattern = defaultPlacePatterns[3];
    for (final pattern in defaultPlacePatterns) {
      final match = _safeFirstMatch(pattern, normalized);
      if (match != null) {
        final place = _groupOrWhole(match)?.trim() ?? '';
        if (place.isNotEmpty && !_looksLikeDate(place)) {
          placePattern = pattern;
          break;
        }
      }
    }

    final hasDate = _safeFirstMatch(defaultDatePattern, normalized) != null;

    return SmsRegexSuggestion(
      amountPattern: amountPattern,
      placePattern: placePattern,
      datePattern: hasDate ? defaultDatePattern : null,
    );
  }

  static SmsParseResult? parse({
    required String smsBody,
    required String amountPattern,
    required String placePattern,
    String? datePattern,
    required DateTime fallbackDate,
    bool strict = false,
  }) {
    final body = _normalizeSms(smsBody);
    if (body.isEmpty) {
      return null;
    }

    final amount = strict
        ? _firstAmount(body, amountPattern)
        : _extractAmount(body, amountPattern);
    if (amount == null) {
      return null;
    }

    final rawPlace = strict
        ? _extractPlaceStrict(body, placePattern)
        : _extractPlace(body, placePattern);
    final place = _cleanPlace(rawPlace ?? (strict ? '' : 'Unknown Merchant'));
    if (place.isEmpty || _looksLikeDate(place)) {
      return null;
    }

    final extracted = _extractDate(body, datePattern);
    final transactionDate = extracted == null
        ? fallbackDate
        : DateTime(
            extracted.year,
            extracted.month,
            extracted.day,
            fallbackDate.hour,
            fallbackDate.minute,
            fallbackDate.second,
            fallbackDate.millisecond,
          );

    return SmsParseResult(
      amount: amount,
      place: place,
      transactionDate: transactionDate,
    );
  }

  static String explainFailure({
    required String smsBody,
    required String amountPattern,
  }) {
    final body = _normalizeSms(smsBody);
    if (body.isEmpty) {
      return 'Empty SMS body.';
    }

    if (_extractAmount(body, amountPattern) != null) {
      return 'Amount matched, but parsing still failed unexpectedly.';
    }

    final fallbackHit = _extractAmount(body, '');
    if (fallbackHit != null) {
      return 'Current Amount Pattern did not match, but a fallback found amount $fallbackHit.\n'
          'Tap "Auto-suggest Regex from Sample" again, then Save SMS Format.';
    }

    return 'No amount found in this SMS.\n'
        'For HBL cards, amount often looks like: PKR-4,515.00\n'
        'Tap Auto-suggest again (hyphen after PKR must be allowed).\n'
        'Current pattern:\n$amountPattern';
  }

  static String _normalizeSms(String input) {
    return input
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll('/-', '')
        .trim();
  }

  static double? _extractAmount(String body, String preferredPattern) {
    final patterns = <String>[
      if (preferredPattern.trim().isNotEmpty) preferredPattern.trim(),
      ...defaultAmountPatterns,
    ];

    for (final pattern in patterns) {
      final amount = _firstAmount(body, pattern);
      if (amount != null) {
        return amount;
      }
    }
    return null;
  }

  static double? _firstAmount(String body, String pattern) {
    final match = _safeFirstMatch(pattern, body);
    if (match == null) {
      return null;
    }
    final amount = _toAmount(_groupOrWhole(match));
    if (amount != null && amount > 0) {
      return amount;
    }
    return null;
  }

  static String? _extractPlaceStrict(String body, String pattern) {
    if (pattern.trim().isEmpty) return null;
    final match = _safeFirstMatch(pattern.trim(), body);
    if (match == null) return null;
    final place = _cleanPlace(_groupOrWhole(match) ?? '');
    if (place.isEmpty || _looksLikeDate(place)) return null;
    return place;
  }

  static String? _extractPlace(String body, String preferredPattern) {
    final patterns = <String>[
      if (preferredPattern.trim().isNotEmpty) preferredPattern.trim(),
      ...defaultPlacePatterns,
    ];

    for (final pattern in patterns) {
      final match = _safeFirstMatch(pattern, body);
      if (match == null) {
        continue;
      }
      final place = _cleanPlace(_groupOrWhole(match) ?? '');
      if (place.isEmpty || _looksLikeDate(place)) {
        continue;
      }
      return place;
    }
    return null;
  }

  /// Strips trailing junk like "for PKR-4,515.00", "for -2", "on 28/Jul/2026".
  static String _cleanPlace(String place) {
    var cleaned = place.trim().replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\s+for\s+(?:PKR|Rs\.?|RS\.?)?[\s\-:]*.*$',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\s+for\s*-\s*\d+.*$', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\s+on\s+\d.*$', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\s+(?:PKR|Rs\.?|RS\.?).*$', caseSensitive: false),
      '',
    );
    return cleaned.trim();
  }

  static DateTime? _extractDate(String body, String? preferredPattern) {
    final patterns = <String>[
      if (preferredPattern != null && preferredPattern.trim().isNotEmpty)
        preferredPattern.trim(),
      r'on\s+([0-9]{1,2}[\/\-.][A-Za-z]{3,9}[\/\-.][0-9]{2,4})',
      defaultDatePattern,
    ];

    for (final pattern in patterns) {
      final match = _safeFirstMatch(pattern, body);
      if (match == null) {
        continue;
      }
      final raw = _groupOrWhole(match);
      if (raw == null) {
        continue;
      }
      final parsed = _parseLooseDate(raw);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static bool _looksLikeDate(String value) {
    return RegExp(
      r'^\d{1,2}[\/\-.]\d{1,2}|^\d{1,2}[\/\-.][A-Za-z]{3}',
    ).hasMatch(value.trim());
  }

  static RegExpMatch? _safeFirstMatch(String pattern, String input) {
    try {
      return RegExp(pattern, caseSensitive: false).firstMatch(input);
    } catch (_) {
      return null;
    }
  }

  static String? _groupOrWhole(RegExpMatch match) {
    if (match.groupCount > 0) {
      return match.group(1) ?? match.group(0);
    }
    return match.group(0);
  }

  static double? _toAmount(String? raw) {
    if (raw == null) {
      return null;
    }
    final cleaned = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return null;
    }
    return double.tryParse(cleaned);
  }

  static DateTime? _parseLooseDate(String input) {
    final trimmed = input.trim();

    // 28/Jul/2026 or 28-07-2026 or 28.07.2026
    final slashParts = trimmed.split(RegExp(r'[\/\-.]'));
    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]) ?? _monthFromName(slashParts[1]);
      var year = int.tryParse(slashParts[2]);
      if (day != null && month != null && year != null) {
        if (year < 100) {
          year += 2000;
        }
        if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
          return DateTime(year, month, day);
        }
      }
    }

    // 28 Jul 2026
    final monthNameMatch = RegExp(
      r'^([0-9]{1,2})\s+([A-Za-z]{3,9})\s+([0-9]{2,4})$',
    ).firstMatch(trimmed);
    if (monthNameMatch != null) {
      final day = int.tryParse(monthNameMatch.group(1)!);
      final month = _monthFromName(monthNameMatch.group(2)!);
      var year = int.tryParse(monthNameMatch.group(3)!);
      if (day != null && month != null && year != null) {
        if (year < 100) {
          year += 2000;
        }
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  static int? _monthFromName(String name) {
    const months = <String, int>{
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'sept': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return months[name.toLowerCase()];
  }
}
