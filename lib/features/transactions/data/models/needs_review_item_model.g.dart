// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'needs_review_item_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNeedsReviewItemModelCollection on Isar {
  IsarCollection<NeedsReviewItemModel> get needsReviewItemModels =>
      this.collection();
}

const NeedsReviewItemModelSchema = CollectionSchema(
  name: r'NeedsReviewItemModel',
  id: 9067315999153284276,
  properties: {
    r'cardId': PropertySchema(
      id: 0,
      name: r'cardId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'parseError': PropertySchema(
      id: 2,
      name: r'parseError',
      type: IsarType.string,
    ),
    r'rawSmsBody': PropertySchema(
      id: 3,
      name: r'rawSmsBody',
      type: IsarType.string,
    ),
    r'receivedAt': PropertySchema(
      id: 4,
      name: r'receivedAt',
      type: IsarType.dateTime,
    ),
    r'senderId': PropertySchema(
      id: 5,
      name: r'senderId',
      type: IsarType.string,
    )
  },
  estimateSize: _needsReviewItemModelEstimateSize,
  serialize: _needsReviewItemModelSerialize,
  deserialize: _needsReviewItemModelDeserialize,
  deserializeProp: _needsReviewItemModelDeserializeProp,
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
  getId: _needsReviewItemModelGetId,
  getLinks: _needsReviewItemModelGetLinks,
  attach: _needsReviewItemModelAttach,
  version: '3.1.0+1',
);

int _needsReviewItemModelEstimateSize(
  NeedsReviewItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cardId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.parseError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawSmsBody.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  return bytesCount;
}

void _needsReviewItemModelSerialize(
  NeedsReviewItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardId);
  writer.writeString(offsets[1], object.id);
  writer.writeString(offsets[2], object.parseError);
  writer.writeString(offsets[3], object.rawSmsBody);
  writer.writeDateTime(offsets[4], object.receivedAt);
  writer.writeString(offsets[5], object.senderId);
}

NeedsReviewItemModel _needsReviewItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NeedsReviewItemModel();
  object.cardId = reader.readString(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.isarId = id;
  object.parseError = reader.readStringOrNull(offsets[2]);
  object.rawSmsBody = reader.readString(offsets[3]);
  object.receivedAt = reader.readDateTime(offsets[4]);
  object.senderId = reader.readString(offsets[5]);
  return object;
}

P _needsReviewItemModelDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _needsReviewItemModelGetId(NeedsReviewItemModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _needsReviewItemModelGetLinks(
    NeedsReviewItemModel object) {
  return [];
}

void _needsReviewItemModelAttach(
    IsarCollection<dynamic> col, Id id, NeedsReviewItemModel object) {
  object.isarId = id;
}

extension NeedsReviewItemModelByIndex on IsarCollection<NeedsReviewItemModel> {
  Future<NeedsReviewItemModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  NeedsReviewItemModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<NeedsReviewItemModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<NeedsReviewItemModel?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(NeedsReviewItemModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(NeedsReviewItemModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<NeedsReviewItemModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<NeedsReviewItemModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension NeedsReviewItemModelQueryWhereSort
    on QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QWhere> {
  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NeedsReviewItemModelQueryWhere
    on QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QWhereClause> {
  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
      cardIdEqualTo(String cardId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cardId',
        value: [cardId],
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterWhereClause>
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

extension NeedsReviewItemModelQueryFilter on QueryBuilder<NeedsReviewItemModel,
    NeedsReviewItemModel, QFilterCondition> {
  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdEqualTo(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdGreaterThan(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdLessThan(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdBetween(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdStartsWith(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdEndsWith(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      cardIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      cardIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> cardIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardId',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parseError',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parseError',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parseError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parseError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parseError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parseError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parseError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parseError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      parseErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parseError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      parseErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parseError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parseError',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> parseErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parseError',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawSmsBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      rawSmsBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawSmsBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      rawSmsBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawSmsBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawSmsBody',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> rawSmsBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawSmsBody',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> receivedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> receivedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> receivedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> receivedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
          QAfterFilterCondition>
      senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel,
      QAfterFilterCondition> senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }
}

extension NeedsReviewItemModelQueryObject on QueryBuilder<NeedsReviewItemModel,
    NeedsReviewItemModel, QFilterCondition> {}

extension NeedsReviewItemModelQueryLinks on QueryBuilder<NeedsReviewItemModel,
    NeedsReviewItemModel, QFilterCondition> {}

extension NeedsReviewItemModelQuerySortBy
    on QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QSortBy> {
  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByParseError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parseError', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByParseErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parseError', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByRawSmsBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsBody', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByRawSmsBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsBody', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByReceivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortByReceivedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }
}

extension NeedsReviewItemModelQuerySortThenBy
    on QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QSortThenBy> {
  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByParseError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parseError', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByParseErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parseError', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByRawSmsBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsBody', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByRawSmsBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawSmsBody', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByReceivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenByReceivedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedAt', Sort.desc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QAfterSortBy>
      thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }
}

extension NeedsReviewItemModelQueryWhereDistinct
    on QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct> {
  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct>
      distinctByCardId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct>
      distinctByParseError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parseError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct>
      distinctByRawSmsBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawSmsBody', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct>
      distinctByReceivedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedAt');
    });
  }

  QueryBuilder<NeedsReviewItemModel, NeedsReviewItemModel, QDistinct>
      distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }
}

extension NeedsReviewItemModelQueryProperty on QueryBuilder<
    NeedsReviewItemModel, NeedsReviewItemModel, QQueryProperty> {
  QueryBuilder<NeedsReviewItemModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<NeedsReviewItemModel, String, QQueryOperations>
      cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<NeedsReviewItemModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NeedsReviewItemModel, String?, QQueryOperations>
      parseErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parseError');
    });
  }

  QueryBuilder<NeedsReviewItemModel, String, QQueryOperations>
      rawSmsBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawSmsBody');
    });
  }

  QueryBuilder<NeedsReviewItemModel, DateTime, QQueryOperations>
      receivedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedAt');
    });
  }

  QueryBuilder<NeedsReviewItemModel, String, QQueryOperations>
      senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }
}
