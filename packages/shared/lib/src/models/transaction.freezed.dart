// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currencyCode => throw _privateConstructorUsedError;
  double? get foreignAmount => throw _privateConstructorUsedError;
  String? get foreignCurrency => throw _privateConstructorUsedError;
  String get sourceAccountId => throw _privateConstructorUsedError;
  String? get destAccountId => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get budgetId => throw _privateConstructorUsedError;
  String? get merchantName => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  bool get reconciled => throw _privateConstructorUsedError;
  String? get smsSource => throw _privateConstructorUsedError;
  String? get smsSender => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      TransactionType type,
      String description,
      DateTime date,
      double amount,
      String currencyCode,
      double? foreignAmount,
      String? foreignCurrency,
      String sourceAccountId,
      String? destAccountId,
      String? categoryId,
      String? budgetId,
      String? merchantName,
      String? notes,
      List<String> tags,
      bool reconciled,
      String? smsSource,
      String? smsSender,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? date = null,
    Object? amount = null,
    Object? currencyCode = null,
    Object? foreignAmount = freezed,
    Object? foreignCurrency = freezed,
    Object? sourceAccountId = null,
    Object? destAccountId = freezed,
    Object? categoryId = freezed,
    Object? budgetId = freezed,
    Object? merchantName = freezed,
    Object? notes = freezed,
    Object? tags = null,
    Object? reconciled = null,
    Object? smsSource = freezed,
    Object? smsSender = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currencyCode: null == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      foreignAmount: freezed == foreignAmount
          ? _value.foreignAmount
          : foreignAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      foreignCurrency: freezed == foreignCurrency
          ? _value.foreignCurrency
          : foreignCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceAccountId: null == sourceAccountId
          ? _value.sourceAccountId
          : sourceAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      destAccountId: freezed == destAccountId
          ? _value.destAccountId
          : destAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetId: freezed == budgetId
          ? _value.budgetId
          : budgetId // ignore: cast_nullable_to_non_nullable
              as String?,
      merchantName: freezed == merchantName
          ? _value.merchantName
          : merchantName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reconciled: null == reconciled
          ? _value.reconciled
          : reconciled // ignore: cast_nullable_to_non_nullable
              as bool,
      smsSource: freezed == smsSource
          ? _value.smsSource
          : smsSource // ignore: cast_nullable_to_non_nullable
              as String?,
      smsSender: freezed == smsSender
          ? _value.smsSender
          : smsSender // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TransactionType type,
      String description,
      DateTime date,
      double amount,
      String currencyCode,
      double? foreignAmount,
      String? foreignCurrency,
      String sourceAccountId,
      String? destAccountId,
      String? categoryId,
      String? budgetId,
      String? merchantName,
      String? notes,
      List<String> tags,
      bool reconciled,
      String? smsSource,
      String? smsSender,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? date = null,
    Object? amount = null,
    Object? currencyCode = null,
    Object? foreignAmount = freezed,
    Object? foreignCurrency = freezed,
    Object? sourceAccountId = null,
    Object? destAccountId = freezed,
    Object? categoryId = freezed,
    Object? budgetId = freezed,
    Object? merchantName = freezed,
    Object? notes = freezed,
    Object? tags = null,
    Object? reconciled = null,
    Object? smsSource = freezed,
    Object? smsSender = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currencyCode: null == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      foreignAmount: freezed == foreignAmount
          ? _value.foreignAmount
          : foreignAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      foreignCurrency: freezed == foreignCurrency
          ? _value.foreignCurrency
          : foreignCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceAccountId: null == sourceAccountId
          ? _value.sourceAccountId
          : sourceAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      destAccountId: freezed == destAccountId
          ? _value.destAccountId
          : destAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetId: freezed == budgetId
          ? _value.budgetId
          : budgetId // ignore: cast_nullable_to_non_nullable
              as String?,
      merchantName: freezed == merchantName
          ? _value.merchantName
          : merchantName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reconciled: null == reconciled
          ? _value.reconciled
          : reconciled // ignore: cast_nullable_to_non_nullable
              as bool,
      smsSource: freezed == smsSource
          ? _value.smsSource
          : smsSource // ignore: cast_nullable_to_non_nullable
              as String?,
      smsSender: freezed == smsSender
          ? _value.smsSender
          : smsSender // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.type,
      required this.description,
      required this.date,
      required this.amount,
      this.currencyCode = 'INR',
      this.foreignAmount,
      this.foreignCurrency,
      required this.sourceAccountId,
      this.destAccountId,
      this.categoryId,
      this.budgetId,
      this.merchantName,
      this.notes,
      final List<String> tags = const [],
      this.reconciled = false,
      this.smsSource,
      this.smsSender,
      required this.createdAt,
      required this.updatedAt})
      : _tags = tags;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final TransactionType type;
  @override
  final String description;
  @override
  final DateTime date;
  @override
  final double amount;
  @override
  @JsonKey()
  final String currencyCode;
  @override
  final double? foreignAmount;
  @override
  final String? foreignCurrency;
  @override
  final String sourceAccountId;
  @override
  final String? destAccountId;
  @override
  final String? categoryId;
  @override
  final String? budgetId;
  @override
  final String? merchantName;
  @override
  final String? notes;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final bool reconciled;
  @override
  final String? smsSource;
  @override
  final String? smsSender;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, description: $description, date: $date, amount: $amount, currencyCode: $currencyCode, foreignAmount: $foreignAmount, foreignCurrency: $foreignCurrency, sourceAccountId: $sourceAccountId, destAccountId: $destAccountId, categoryId: $categoryId, budgetId: $budgetId, merchantName: $merchantName, notes: $notes, tags: $tags, reconciled: $reconciled, smsSource: $smsSource, smsSender: $smsSender, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.foreignAmount, foreignAmount) ||
                other.foreignAmount == foreignAmount) &&
            (identical(other.foreignCurrency, foreignCurrency) ||
                other.foreignCurrency == foreignCurrency) &&
            (identical(other.sourceAccountId, sourceAccountId) ||
                other.sourceAccountId == sourceAccountId) &&
            (identical(other.destAccountId, destAccountId) ||
                other.destAccountId == destAccountId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.budgetId, budgetId) ||
                other.budgetId == budgetId) &&
            (identical(other.merchantName, merchantName) ||
                other.merchantName == merchantName) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.reconciled, reconciled) ||
                other.reconciled == reconciled) &&
            (identical(other.smsSource, smsSource) ||
                other.smsSource == smsSource) &&
            (identical(other.smsSender, smsSender) ||
                other.smsSender == smsSender) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        description,
        date,
        amount,
        currencyCode,
        foreignAmount,
        foreignCurrency,
        sourceAccountId,
        destAccountId,
        categoryId,
        budgetId,
        merchantName,
        notes,
        const DeepCollectionEquality().hash(_tags),
        reconciled,
        smsSource,
        smsSender,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      required final TransactionType type,
      required final String description,
      required final DateTime date,
      required final double amount,
      final String currencyCode,
      final double? foreignAmount,
      final String? foreignCurrency,
      required final String sourceAccountId,
      final String? destAccountId,
      final String? categoryId,
      final String? budgetId,
      final String? merchantName,
      final String? notes,
      final List<String> tags,
      final bool reconciled,
      final String? smsSource,
      final String? smsSender,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  TransactionType get type;
  @override
  String get description;
  @override
  DateTime get date;
  @override
  double get amount;
  @override
  String get currencyCode;
  @override
  double? get foreignAmount;
  @override
  String? get foreignCurrency;
  @override
  String get sourceAccountId;
  @override
  String? get destAccountId;
  @override
  String? get categoryId;
  @override
  String? get budgetId;
  @override
  String? get merchantName;
  @override
  String? get notes;
  @override
  List<String> get tags;
  @override
  bool get reconciled;
  @override
  String? get smsSource;
  @override
  String? get smsSender;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
