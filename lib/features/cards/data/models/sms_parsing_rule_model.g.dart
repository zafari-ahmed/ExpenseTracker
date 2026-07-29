// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_parsing_rule_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmsParsingRuleModelCollection on Isar {
  IsarCollection<SmsParsingRuleModel> get smsParsingRuleModels =>
      this.collection();
}

const SmsParsingRuleModelSchema = CollectionSchema(
  name: r'SmsParsingRuleModel',
  id: -7752830433571476442,
  properties: {
    r'amountPattern': PropertySchema(
      id: 0,
      name: r'amountPattern',
      type: IsarType.string,
    ),
    r'cardId': PropertySchema(
      id: 1,
      name: r'cardId',
      type: IsarType.string,
    ),
    r'datePattern': PropertySchema(
      id: 2,
      name: r'datePattern',
      type: IsarType.string,
    ),
    r'excludeKeywords': PropertySchema(
      id: 3,
      name: r'excludeKeywords',
      type: IsarType.stringList,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'placePattern': PropertySchema(
      id: 5,
      name: r'placePattern',
      type: IsarType.string,
    ),
    r'sampleMessage': PropertySchema(
      id: 6,
      name: r'sampleMessage',
      type: IsarType.string,
    )
  },
  estimateSize: _smsParsingRuleModelEstimateSize,
  serialize: _smsParsingRuleModelSerialize,
  deserialize: _smsParsingRuleModelDeserialize,
  deserializeProp: _smsParsingRuleModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'cardId': IndexSchema(
      id: -8501089313549364976,
      name: r'cardId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cardId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _smsParsingRuleModelGetId,
  getLinks: _smsParsingRuleModelGetLinks,
  attach: _smsParsingRuleModelAttach,
  version: '3.1.0+1',
);

int _smsParsingRuleModelEstimateSize(
  SmsParsingRuleModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.amountPattern.length * 3;
  bytesCount += 3 + object.cardId.length * 3;
  {
    final value = object.datePattern;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.excludeKeywords.length * 3;
  {
    for (var i = 0; i < object.excludeKeywords.length; i++) {
      final value = object.excludeKeywords[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.placePattern.length * 3;
  bytesCount += 3 + object.sampleMessage.length * 3;
  return bytesCount;
}

void _smsParsingRuleModelSerialize(
  SmsParsingRuleModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.amountPattern);
  writer.writeString(offsets[1], object.cardId);
  writer.writeString(offsets[2], object.datePattern);
  writer.writeStringList(offsets[3], object.excludeKeywords);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.placePattern);
  writer.writeString(offsets[6], object.sampleMessage);
}

SmsParsingRuleModel _smsParsingRuleModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmsParsingRuleModel();
  object.amountPattern = reader.readString(offsets[0]);
  object.cardId = reader.readString(offsets[1]);
  object.datePattern = reader.readStringOrNull(offsets[2]);
  object.excludeKeywords = reader.readStringList(offsets[3]) ?? [];
  object.id = reader.readString(offsets[4]);
  object.isarId = id;
  object.placePattern = reader.readString(offsets[5]);
  object.sampleMessage = reader.readString(offsets[6]);
  return object;
}

P _smsParsingRuleModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smsParsingRuleModelGetId(SmsParsingRuleModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _smsParsingRuleModelGetLinks(
    SmsParsingRuleModel object) {
  return [];
}

void _smsParsingRuleModelAttach(
    IsarCollection<dynamic> col, Id id, SmsParsingRuleModel object) {
  object.isarId = id;
}

extension SmsParsingRuleModelByIndex on IsarCollection<SmsParsingRuleModel> {
  Future<SmsParsingRuleModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  SmsParsingRuleModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<SmsParsingRuleModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<SmsParsingRuleModel?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(SmsParsingRuleModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(SmsParsingRuleModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<SmsParsingRuleModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<SmsParsingRuleModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension SmsParsingRuleModelQueryWhereSort
    on QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QWhere> {
  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmsParsingRuleModelQueryWhere
    on QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QWhereClause> {
  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      cardIdEqualTo(String cardId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cardId',
        value: [cardId],
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterWhereClause>
      cardIdNotEqualTo(String cardId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [],
              upper: [cardId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [cardId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [cardId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardId',
              lower: [],
              upper: [cardId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SmsParsingRuleModelQueryFilter on QueryBuilder<SmsParsingRuleModel,
    SmsParsingRuleModel, QFilterCondition> {
  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountPattern',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'amountPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'amountPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'amountPattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'amountPattern',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountPattern',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      amountPatternIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'amountPattern',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      cardIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'datePattern',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'datePattern',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'datePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'datePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'datePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'datePattern',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'datePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'datePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'datePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'datePattern',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'datePattern',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      datePatternIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'datePattern',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excludeKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'excludeKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'excludeKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'excludeKeywords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'excludeKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'excludeKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'excludeKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'excludeKeywords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excludeKeywords',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'excludeKeywords',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludeKeywords',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludeKeywords',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludeKeywords',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludeKeywords',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludeKeywords',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      excludeKeywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludeKeywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'placePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'placePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'placePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'placePattern',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'placePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'placePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'placePattern',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'placePattern',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'placePattern',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      placePatternIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'placePattern',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sampleMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sampleMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sampleMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sampleMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterFilterCondition>
      sampleMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sampleMessage',
        value: '',
      ));
    });
  }
}

extension SmsParsingRuleModelQueryObject on QueryBuilder<SmsParsingRuleModel,
    SmsParsingRuleModel, QFilterCondition> {}

extension SmsParsingRuleModelQueryLinks on QueryBuilder<SmsParsingRuleModel,
    SmsParsingRuleModel, QFilterCondition> {}

extension SmsParsingRuleModelQuerySortBy
    on QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QSortBy> {
  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByAmountPattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPattern', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByAmountPatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPattern', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByDatePattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePattern', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByDatePatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePattern', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByPlacePattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'placePattern', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortByPlacePatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'placePattern', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortBySampleMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleMessage', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      sortBySampleMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleMessage', Sort.desc);
    });
  }
}

extension SmsParsingRuleModelQuerySortThenBy
    on QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QSortThenBy> {
  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByAmountPattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPattern', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByAmountPatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPattern', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByDatePattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePattern', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByDatePatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePattern', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByPlacePattern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'placePattern', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenByPlacePatternDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'placePattern', Sort.desc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenBySampleMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleMessage', Sort.asc);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QAfterSortBy>
      thenBySampleMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleMessage', Sort.desc);
    });
  }
}

extension SmsParsingRuleModelQueryWhereDistinct
    on QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct> {
  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctByAmountPattern({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountPattern',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctByCardId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctByDatePattern({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'datePattern', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctByExcludeKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'excludeKeywords');
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctByPlacePattern({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'placePattern', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QDistinct>
      distinctBySampleMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleMessage',
          caseSensitive: caseSensitive);
    });
  }
}

extension SmsParsingRuleModelQueryProperty
    on QueryBuilder<SmsParsingRuleModel, SmsParsingRuleModel, QQueryProperty> {
  QueryBuilder<SmsParsingRuleModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SmsParsingRuleModel, String, QQueryOperations>
      amountPatternProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountPattern');
    });
  }

  QueryBuilder<SmsParsingRuleModel, String, QQueryOperations> cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<SmsParsingRuleModel, String?, QQueryOperations>
      datePatternProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'datePattern');
    });
  }

  QueryBuilder<SmsParsingRuleModel, List<String>, QQueryOperations>
      excludeKeywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'excludeKeywords');
    });
  }

  QueryBuilder<SmsParsingRuleModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmsParsingRuleModel, String, QQueryOperations>
      placePatternProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'placePattern');
    });
  }

  QueryBuilder<SmsParsingRuleModel, String, QQueryOperations>
      sampleMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleMessage');
    });
  }
}
