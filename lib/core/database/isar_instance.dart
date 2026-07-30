import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/categories/data/models/category_threshold_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/models/needs_review_item_model.dart';
import 'seed/default_categories_seed.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    <CollectionSchema<dynamic>>[
      CardModelSchema,
      SmsParsingRuleModelSchema,
      TransactionModelSchema,
      NeedsReviewItemModelSchema,
      CategoryModelSchema,
      CategoryThresholdModelSchema,
    ],
    directory: dir.path,
    name: 'expense_tracker_db',
  );

  await seedDefaultCategories(isar);

  ref.onDispose(() {
    isar.close();
  });

  return isar;
});
