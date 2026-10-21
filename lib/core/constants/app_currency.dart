class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;

  String get settingsLabel => '$code · $symbol'.trim();

  static const pkr = AppCurrency(
    code: 'PKR',
    symbol: 'Rs ',
    name: 'Pakistani Rupee',
  );
  static const bdt = AppCurrency(
    code: 'BDT',
    symbol: '৳',
    name: 'Bangladeshi Taka',
  );
  static const lkr = AppCurrency(
    code: 'LKR',
    symbol: 'Rs ',
    name: 'Sri Lankan Rupee',
  );
  static const myr = AppCurrency(
    code: 'MYR',
    symbol: 'RM ',
    name: 'Malaysian Ringgit',
  );
  static const usd = AppCurrency(
    code: 'USD',
    symbol: r'$',
    name: 'US Dollar',
  );
  static const eur = AppCurrency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
  );
  static const gbp = AppCurrency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
  );
  static const aed = AppCurrency(
    code: 'AED',
    symbol: 'AED ',
    name: 'UAE Dirham',
  );
  static const sar = AppCurrency(
    code: 'SAR',
    symbol: 'SAR ',
    name: 'Saudi Riyal',
  );
  static const inr = AppCurrency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
  );
  static const tryLira = AppCurrency(
    code: 'TRY',
    symbol: '₺',
    name: 'Turkish Lira',
  );
  static const cad = AppCurrency(
    code: 'CAD',
    symbol: r'CA$',
    name: 'Canadian Dollar',
  );
  static const aud = AppCurrency(
    code: 'AUD',
    symbol: r'A$',
    name: 'Australian Dollar',
  );

  static const List<AppCurrency> all = [
    pkr,
    bdt,
    lkr,
    myr,
    usd,
    eur,
    gbp,
    aed,
    sar,
    inr,
    tryLira,
    cad,
    aud,
  ];

  static AppCurrency byCode(String? code) {
    final key = (code ?? 'PKR').toUpperCase();
    for (final item in all) {
      if (item.code == key) return item;
    }
    return pkr;
  }
}

abstract final class CurrencyStore {
  static AppCurrency current = AppCurrency.pkr;
}
