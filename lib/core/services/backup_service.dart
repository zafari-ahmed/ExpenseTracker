import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/categories/data/models/category_threshold_model.dart';
import '../../features/transactions/data/models/needs_review_item_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../database/seed/default_categories_seed.dart';
import 'app_preferences_service.dart';

class BackupResult {
  const BackupResult({
    required this.transactionCount,
    required this.cardCount,
  });

  final int transactionCount;
  final int cardCount;
}

class BackupService {
  BackupService(this._isar);

  final Isar _isar;
  static const formatVersion = 1;

  Future<File> exportToTempFile() async {
    final payload = await _buildPayload();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/expense_tracker_backup_$stamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  Future<BackupResult> importFromFile(File file) async {
    final raw = jsonDecode(await file.readAsString());
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Backup file is not a JSON object');
    }
    return importPayload(raw);
  }

  Future<BackupResult> importPayload(Map<String, dynamic> raw) async {
    final cards = _asMapList(raw['cards']);
    final rules = _asMapList(raw['rules']);
    final transactions = _asMapList(raw['transactions']);
    final categories = _asMapList(raw['categories']);
    final thresholds = _asMapList(raw['thresholds']);
    final review = _asMapList(raw['needsReview']);
    final prefs = raw['preferences'];
    final photoB64 = raw['profileImageBase64'] as String?;

    await _isar.writeTxn(() async {
      await _isar.clear();
      await _isar.cardModels.putAll(cards.map(_cardFromJson).toList());
      await _isar.smsParsingRuleModels.putAll(rules.map(_ruleFromJson).toList());
      await _isar.transactionModels
          .putAll(transactions.map(_transactionFromJson).toList());
      await _isar.categoryModels
          .putAll(categories.map(_categoryFromJson).toList());
      await _isar.categoryThresholdModels
          .putAll(thresholds.map(_thresholdFromJson).toList());
      await _isar.needsReviewItemModels
          .putAll(review.map(_reviewFromJson).toList());
    });

    await seedDefaultCategories(_isar);
    await _restorePreferences(prefs);
    await _restoreProfilePhoto(photoB64);

    return BackupResult(
      transactionCount: transactions.length,
      cardCount: cards.length,
    );
  }

  Future<void> deleteAllLocalData() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
    await seedDefaultCategories(_isar);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final docs = await getApplicationDocumentsDirectory();
    final avatar = File('${docs.path}/profile_avatar.jpg');
    if (await avatar.exists()) {
      await avatar.delete();
    }
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    final cards = await _isar.cardModels.where().findAll();
    final rules = await _isar.smsParsingRuleModels.where().findAll();
    final transactions = await _isar.transactionModels.where().findAll();
    final categories = await _isar.categoryModels.where().findAll();
    final thresholds = await _isar.categoryThresholdModels.where().findAll();
    final review = await _isar.needsReviewItemModels.where().findAll();
    final prefs = await SharedPreferences.getInstance();
    final preferenceMap = <String, Object?>{};
    for (final key in prefs.getKeys()) {
      preferenceMap[key] = prefs.get(key);
    }

    String? photoB64;
    final photoPath = prefs.getString('profile_image_path');
    if (photoPath != null && photoPath.isNotEmpty) {
      final file = File(photoPath);
      if (await file.exists()) {
        photoB64 = base64Encode(await file.readAsBytes());
      }
    }

    return <String, dynamic>{
      'formatVersion': formatVersion,
      'app': 'expense_tracker',
      'exportedAt': DateTime.now().toIso8601String(),
      'cards': cards.map(_cardToJson).toList(),
      'rules': rules.map(_ruleToJson).toList(),
      'transactions': transactions.map(_transactionToJson).toList(),
      'categories': categories.map(_categoryToJson).toList(),
      'thresholds': thresholds.map(_thresholdToJson).toList(),
      'needsReview': review.map(_reviewToJson).toList(),
      'preferences': preferenceMap,
      'profileImageBase64': photoB64,
    };
  }

  Map<String, dynamic> _cardToJson(CardModel card) => <String, dynamic>{
        'id': card.id,
        'bankName': card.bankName,
        'cardName': card.cardName,
        'cardIcon': card.cardIcon,
        'lastFourDigits': card.lastFourDigits,
        'smsSenderId': card.smsSenderId,
        'billDate': card.billDate,
        'isActive': card.isActive,
        'createdAt': card.createdAt.toIso8601String(),
      };

  CardModel _cardFromJson(Map<String, dynamic> json) {
    return CardModel()
      ..id = json['id'] as String? ?? ''
      ..bankName = json['bankName'] as String? ?? ''
      ..cardName = json['cardName'] as String? ?? ''
      ..cardIcon = json['cardIcon'] as String? ?? ''
      ..lastFourDigits = json['lastFourDigits'] as String?
      ..smsSenderId = json['smsSenderId'] as String? ?? ''
      ..billDate = json['billDate'] as int? ?? 1
      ..isActive = json['isActive'] as bool? ?? true
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now();
  }

  Map<String, dynamic> _ruleToJson(SmsParsingRuleModel rule) => <String, dynamic>{
        'id': rule.id,
        'cardId': rule.cardId,
        'sampleMessage': rule.sampleMessage,
        'amountPattern': rule.amountPattern,
        'placePattern': rule.placePattern,
        'datePattern': rule.datePattern,
        'excludeKeywords': rule.excludeKeywords,
      };

  SmsParsingRuleModel _ruleFromJson(Map<String, dynamic> json) {
    return SmsParsingRuleModel()
      ..id = json['id'] as String? ?? ''
      ..cardId = json['cardId'] as String? ?? ''
      ..sampleMessage = json['sampleMessage'] as String? ?? ''
      ..amountPattern = json['amountPattern'] as String? ?? ''
      ..placePattern = json['placePattern'] as String? ?? ''
      ..datePattern = json['datePattern'] as String?
      ..excludeKeywords = _asStringList(json['excludeKeywords']);
  }

  Map<String, dynamic> _transactionToJson(TransactionModel tx) =>
      <String, dynamic>{
        'id': tx.id,
        'cardId': tx.cardId,
        'amount': tx.amount,
        'place': tx.place,
        'description': tx.description,
        'category': tx.category,
        'rawSmsBody': tx.rawSmsBody,
        'transactionDate': tx.transactionDate.toIso8601String(),
        'createdAt': tx.createdAt.toIso8601String(),
        'source': tx.source.name,
      };

  TransactionModel _transactionFromJson(Map<String, dynamic> json) {
    return TransactionModel()
      ..id = json['id'] as String? ?? ''
      ..cardId = json['cardId'] as String? ?? ''
      ..amount = (json['amount'] as num?)?.toDouble() ?? 0
      ..place = json['place'] as String? ?? ''
      ..description = json['description'] as String? ?? ''
      ..category = json['category'] as String? ?? 'Uncategorized'
      ..rawSmsBody = json['rawSmsBody'] as String? ?? ''
      ..transactionDate =
          DateTime.tryParse(json['transactionDate'] as String? ?? '') ??
              DateTime.now()
      ..createdAt =
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()
      ..source = TransactionSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => TransactionSource.sms,
      );
  }

  Map<String, dynamic> _categoryToJson(CategoryModel category) =>
      <String, dynamic>{
        'id': category.id,
        'name': category.name,
        'icon': category.icon,
        'keywords': category.keywords,
        'color': category.color,
      };

  CategoryModel _categoryFromJson(Map<String, dynamic> json) {
    return CategoryModel()
      ..id = json['id'] as String? ?? ''
      ..name = json['name'] as String? ?? ''
      ..icon = json['icon'] as String? ?? ''
      ..keywords = _asStringList(json['keywords'])
      ..color = json['color'] as String? ?? '#90A4AE';
  }

  Map<String, dynamic> _thresholdToJson(CategoryThresholdModel row) =>
      <String, dynamic>{
        'id': row.id,
        'categoryId': row.categoryId,
        'monthlyLimit': row.monthlyLimit,
        'notifyAtPercent': row.notifyAtPercent,
      };

  CategoryThresholdModel _thresholdFromJson(Map<String, dynamic> json) {
    return CategoryThresholdModel()
      ..id = json['id'] as String? ?? ''
      ..categoryId = json['categoryId'] as String? ?? ''
      ..monthlyLimit = (json['monthlyLimit'] as num?)?.toDouble() ?? 0
      ..notifyAtPercent = json['notifyAtPercent'] as int? ?? 80;
  }

  Map<String, dynamic> _reviewToJson(NeedsReviewItemModel row) =>
      <String, dynamic>{
        'id': row.id,
        'cardId': row.cardId,
        'senderId': row.senderId,
        'rawSmsBody': row.rawSmsBody,
        'receivedAt': row.receivedAt.toIso8601String(),
        'parseError': row.parseError,
      };

  NeedsReviewItemModel _reviewFromJson(Map<String, dynamic> json) {
    return NeedsReviewItemModel()
      ..id = json['id'] as String? ?? ''
      ..cardId = json['cardId'] as String? ?? ''
      ..senderId = json['senderId'] as String? ?? ''
      ..rawSmsBody = json['rawSmsBody'] as String? ?? ''
      ..receivedAt =
          DateTime.tryParse(json['receivedAt'] as String? ?? '') ?? DateTime.now()
      ..parseError = json['parseError'] as String?;
  }

  Future<void> _restorePreferences(Object? raw) async {
    if (raw is! Map) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List) {
        await prefs.setStringList(
          key,
          value.map((e) => e.toString()).toList(),
        );
      }
    }
  }

  Future<void> _restoreProfilePhoto(String? photoB64) async {
    if (photoB64 == null || photoB64.isEmpty) return;
    final docs = await getApplicationDocumentsDirectory();
    final dest = File('${docs.path}/profile_avatar.jpg');
    await dest.writeAsBytes(base64Decode(photoB64));
    await AppPreferencesService().setProfileImagePath(dest.path);
  }

  List<Map<String, dynamic>> _asMapList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  List<String> _asStringList(Object? raw) {
    if (raw is! List) return <String>[];
    return raw.map((e) => e.toString()).toList();
  }
}
