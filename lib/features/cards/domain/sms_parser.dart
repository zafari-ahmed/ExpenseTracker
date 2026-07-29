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
  /// Flexible amount patterns for common bank SMS styles (incl. HBL `PKR-2,361.00`).
  static const List<String> defaultAmountPatterns = <String>[
    // HBL-style: for PKR-2,361.00 | for PKR 2,361.00
    r'for\s+(?:PKR|Rs\.?|RS\.?)\s*[-:]?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)',
    // PKR-2,361.00 | Rs.1234 | Rs 1,234 | USD:12.00
    r'(?:PKR|Rs\.?|RS\.?|INR|USD|AED|SAR)\s*[-:]?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)',
    // 2,361.00 PKR
    r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)\s*[-:]?\s*(?:PKR|Rs\.?|RS\.?|INR|USD|AED|SAR)',
    // amount/debited/charged ... 1234.50
    r'(?:amount|amt|debited|spent|charged|paid|txn|transaction)[^\d]{0,24}([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)',
  ];

  static const List<String> defaultPlacePatterns = <String>[
    // HBL: charged at BACHAA PARTY for PKR-...
    r'charged\s+at\s+(.+?)\s+for\s+(?:PKR|Rs\.?|RS\.?)',
    // at MERCHANT before for/on/dated
    r'\bat\s+([A-Za-z0-9][A-Za-z0-9 &.\-]{1,60}?)(?=\s+for\b|\s+on\b|\s+dated\b|[.\n]|$)',
    r'merchant\s*[:\-]?\s*([A-Za-z0-9][A-Za-z0-9 &.\-]{1,60})',
    r'(?:purchase|pos|spent|paid)\s+at\s+([A-Za-z0-9][A-Za-z0-9 &.\-]{1,60}?)(?=\s+for\b|\s+on\b|[.\n]|$)',
    r'\bto\s+([A-Za-z][A-Za-z0-9 &.\-]{1,60}?)(?=\s+on\b|[.\n]|$)',
  ];

  /// Supports 28/07/2026 and 28/Jul/2026 and 28 Jul 2026.
  static const String defaultDatePattern =
      r'([0-9]{1,2}[\/\-.](?:[0-9]{1,2}|[A-Za-z]{3,9})[\/\-.][0-9]{2,4}|[0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4})';

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

    String amountPattern = defaultAmountPatterns[1];
    for (final pattern in defaultAmountPatterns) {
      if (_firstAmount(normalized, pattern) != null) {
        amountPattern = pattern;
        break;
      }
    }

    String placePattern = defaultPlacePatterns[1];
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
  }) {
    final body = _normalizeSms(smsBody);
    if (body.isEmpty) {
      return null;
    }

    final amount = _extractAmount(body, amountPattern);
    if (amount == null) {
      return null;
    }

    final place = _cleanPlace(
      _extractPlace(body, placePattern) ?? 'Unknown Merchant',
    );
    final transactionDate = _extractDate(body, datePattern) ?? fallbackDate;

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

  static String? _extractPlace(String body, String preferredPattern) {
    final patterns = <String>[
      // Always prefer precise HBL merchant capture when present.
      defaultPlacePatterns[0],
      if (preferredPattern.trim().isNotEmpty) preferredPattern.trim(),
      ...defaultPlacePatterns.skip(1),
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
