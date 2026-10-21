import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cards/presentation/providers/cards_provider.dart';
import '../../features/categories/presentation/providers/categories_provider.dart';
import '../../features/dashboard/presentation/providers/threshold_status_provider.dart';
import '../../features/settings/presentation/providers/preferences_provider.dart';
import '../../features/settings/presentation/providers/profile_provider.dart';
import '../../features/settings/presentation/providers/sms_ignore_provider.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import 'sms_listener_service.dart';

void invalidateLocalDataProviders(WidgetRef ref) {
  ref.invalidate(cardsListProvider);
  ref.invalidate(activeCardsProvider);
  ref.invalidate(transactionsListProvider);
  ref.invalidate(thisMonthTotalProvider);
  ref.invalidate(needsReviewProvider);
  ref.invalidate(categoriesProvider);
  ref.invalidate(thresholdsProvider);
  ref.invalidate(categoryThresholdStatusesProvider);
  ref.invalidate(notificationPrefsProvider);
  ref.invalidate(spendPeriodModeProvider);
  ref.invalidate(profileNameProvider);
  ref.invalidate(profileImagePathProvider);
  ref.invalidate(smsIgnoreListProvider);
  ref.invalidate(disabledDefaultSmsIgnoreListProvider);
  ref.invalidate(activeDefaultSmsIgnoreListProvider);
  ref.read(smsSyncTickProvider.notifier).state++;
}
