// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_threshold_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCategoryThresholdModelCollection on Isar {
  IsarCollection<CategoryThresholdModel> get categoryThresholdModels =>
      this.collection();
}

const CategoryThresholdModelSchema = CollectionSchema(
  name: r'CategoryThresholdModel',
  id: -7099827046111871276,
  properties: {
    r'categoryId': PropertySchema(
      id: 0,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'monthlyLimit': PropertySchema(
      id: 2,
      name: r'monthlyLimit',
      type: IsarType.double,
    ),
    r'notifyAtPercent': PropertySchema(
      id: 3,
      name: r'notifyAtPercent',
      type: IsarType.long,
    )
  },
  estimateSize: _categoryThresholdModelEstimateSize,
  serialize: _categoryThresholdModelSerialize,
  deserialize: _categoryThresholdModelDeserialize,
  deserializeProp: _categoryThresholdModelDeserializeProp,
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
    r'categoryId': IndexSchema(
      id: -8798048739239305339,
      name: r'categoryId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _categoryThresholdModelGetId,
  getLinks: _categoryThresholdModelGetLinks,
  attach: _categoryThresholdModelAttach,
  version: '3.1.0+1',
);

int _categoryThresholdModelEstimateSize(
  CategoryThresholdModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categoryId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  return bytesCount;
}

void _categoryThresholdModelSerialize(
  CategoryThresholdModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.categoryId);
  writer.writeString(offsets[1], object.id);
  writer.writeDouble(offsets[2], object.monthlyLimit);
  writer.writeLong(offsets[3], object.notifyAtPercent);
}

CategoryThresholdModel _categoryThresholdModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CategoryThresholdModel();
  object.categoryId = reader.readString(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.isarId = id;
  object.monthlyLimit = reader.readDouble(offsets[2]);
  object.notifyAtPercent = reader.readLong(offsets[3]);
  return object;
}

P _categoryThresholdModelDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _categoryThresholdModelGetId(CategoryThresholdModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _categoryThresholdModelGetLinks(
    CategoryThresholdModel object) {
  return [];
}

void _categoryThresholdModelAttach(
    IsarCollection<dynamic> col, Id id, CategoryThresholdModel object) {
  object.isarId = id;
}

extension CategoryThresholdModelByIndex
    on IsarCollection<CategoryThresholdModel> {
  Future<CategoryThresholdModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  CategoryThresholdModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<CategoryThresholdModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<CategoryThresholdModel?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(CategoryThresholdModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(CategoryThresholdModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<CategoryThresholdModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<CategoryThresholdModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }

  Future<CategoryThresholdModel?> getByCategoryId(String categoryId) {
    return getByIndex(r'categoryId', [categoryId]);
  }

  CategoryThresholdModel? getByCategoryIdSync(String categoryId) {
    return getByIndexSync(r'categoryId', [categoryId]);
  }

  Future<bool> deleteByCategoryId(String categoryId) {
    return deleteByIndex(r'categoryId', [categoryId]);
  }

  bool deleteByCategoryIdSync(String categoryId) {
    return deleteByIndexSync(r'categoryId', [categoryId]);
  }

  Future<List<CategoryThresholdModel?>> getAllByCategoryId(
      List<String> categoryIdValues) {
    final values = categoryIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'categoryId', values);
  }

  List<CategoryThresholdModel?> getAllByCategoryIdSync(
      List<String> categoryIdValues) {
    final values = categoryIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'categoryId', values);
  }

  Future<int> deleteAllByCategoryId(List<String> categoryIdValues) {
    final values = categoryIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'categoryId', values);
  }

  int deleteAllByCategoryIdSync(List<String> categoryIdValues) {
    final values = categoryIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'categoryId', values);
  }

  Future<Id> putByCategoryId(CategoryThresholdModel object) {
    return putByIndex(r'categoryId', object);
  }

  Id putByCategoryIdSync(CategoryThresholdModel object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'categoryId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCategoryId(List<CategoryThresholdModel> objects) {
    return putAllByIndex(r'categoryId', objects);
  }

  List<Id> putAllByCategoryIdSync(List<CategoryThresholdModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'categoryId', objects, saveLinks: saveLinks);
  }
}

extension CategoryThresholdModelQueryWhereSort
    on QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QWhere> {
  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CategoryThresholdModelQueryWhere on QueryBuilder<
    CategoryThresholdModel, CategoryThresholdModel, QWhereClause> {
  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> idNotEqualTo(String id) {
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> categoryIdEqualTo(String categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryId',
        value: [categoryId],
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterWhereClause> categoryIdNotEqualTo(String categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [],
              upper: [categoryId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [categoryId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [categoryId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [],
              upper: [categoryId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CategoryThresholdModelQueryFilter on QueryBuilder<
    CategoryThresholdModel, CategoryThresholdModel, QFilterCondition> {
  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
          QAfterFilterCondition>
      categoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
          QAfterFilterCondition>
      categoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
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

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> monthlyLimitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthlyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> monthlyLimitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthlyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> monthlyLimitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthlyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> monthlyLimitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthlyLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> notifyAtPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifyAtPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> notifyAtPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notifyAtPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> notifyAtPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notifyAtPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel,
      QAfterFilterCondition> notifyAtPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notifyAtPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CategoryThresholdModelQueryObject on QueryBuilder<
    CategoryThresholdModel, CategoryThresholdModel, QFilterCondition> {}

extension CategoryThresholdModelQueryLinks on QueryBuilder<
    CategoryThresholdModel, CategoryThresholdModel, QFilterCondition> {}

extension CategoryThresholdModelQuerySortBy
    on QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QSortBy> {
  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByMonthlyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByNotifyAtPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyAtPercent', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      sortByNotifyAtPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyAtPercent', Sort.desc);
    });
  }
}

extension CategoryThresholdModelQuerySortThenBy on QueryBuilder<
    CategoryThresholdModel, CategoryThresholdModel, QSortThenBy> {
  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByMonthlyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.desc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByNotifyAtPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyAtPercent', Sort.asc);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QAfterSortBy>
      thenByNotifyAtPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyAtPercent', Sort.desc);
    });
  }
}

extension CategoryThresholdModelQueryWhereDistinct
    on QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QDistinct> {
  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QDistinct>
      distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QDistinct>
      distinctByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyLimit');
    });
  }

  QueryBuilder<CategoryThresholdModel, CategoryThresholdModel, QDistinct>
      distinctByNotifyAtPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyAtPercent');
    });
  }
}

extension CategoryThresholdModelQueryProperty on QueryBuilder<
    CategoryThresholdModel, CategoryThresholdModel, QQueryProperty> {
  QueryBuilder<CategoryThresholdModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CategoryThresholdModel, String, QQueryOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<CategoryThresholdModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CategoryThresholdModel, double, QQueryOperations>
      monthlyLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyLimit');
    });
  }

  QueryBuilder<CategoryThresholdModel, int, QQueryOperations>
      notifyAtPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyAtPercent');
    });
  }
}
