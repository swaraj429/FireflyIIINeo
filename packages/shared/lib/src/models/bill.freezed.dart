// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Bill _$BillFromJson(Map<String, dynamic> json) {
  return _Bill.fromJson(json);
}

/// @nodoc
mixin _$Bill {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amountMin => throw _privateConstructorUsedError;
  double get amountMax => throw _privateConstructorUsedError;
  BillFrequency get frequency => throw _privateConstructorUsedError;
  int get dayOfPeriod => throw _privateConstructorUsedError;
  String get currencyCode => throw _privateConstructorUsedError;
  String? get accountId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  DateTime? get nextDueDate => throw _privateConstructorUsedError;
  DateTime? get lastPaidDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Bill to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillCopyWith<Bill> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillCopyWith<$Res> {
  factory $BillCopyWith(Bill value, $Res Function(Bill) then) =
      _$BillCopyWithImpl<$Res, Bill>;
  @useResult
  $Res call(
      {String id,
      String name,
      double amountMin,
      double amountMax,
      BillFrequency frequency,
      int dayOfPeriod,
      String currencyCode,
      String? accountId,
      String? notes,
      bool active,
      DateTime? nextDueDate,
      DateTime? lastPaidDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$BillCopyWithImpl<$Res, $Val extends Bill>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amountMin = null,
    Object? amountMax = null,
    Object? frequency = null,
    Object? dayOfPeriod = null,
    Object? currencyCode = null,
    Object? accountId = freezed,
    Object? notes = freezed,
    Object? active = null,
    Object? nextDueDate = freezed,
    Object? lastPaidDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amountMin: null == amountMin
          ? _value.amountMin
          : amountMin // ignore: cast_nullable_to_non_nullable
              as double,
      amountMax: null == amountMax
          ? _value.amountMax
          : amountMax // ignore: cast_nullable_to_non_nullable
              as double,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as BillFrequency,
      dayOfPeriod: null == dayOfPeriod
          ? _value.dayOfPeriod
          : dayOfPeriod // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPaidDate: freezed == lastPaidDate
          ? _value.lastPaidDate
          : lastPaidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$BillImplCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$$BillImplCopyWith(
          _$BillImpl value, $Res Function(_$BillImpl) then) =
      __$$BillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double amountMin,
      double amountMax,
      BillFrequency frequency,
      int dayOfPeriod,
      String currencyCode,
      String? accountId,
      String? notes,
      bool active,
      DateTime? nextDueDate,
      DateTime? lastPaidDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$BillImplCopyWithImpl<$Res>
    extends _$BillCopyWithImpl<$Res, _$BillImpl>
    implements _$$BillImplCopyWith<$Res> {
  __$$BillImplCopyWithImpl(_$BillImpl _value, $Res Function(_$BillImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amountMin = null,
    Object? amountMax = null,
    Object? frequency = null,
    Object? dayOfPeriod = null,
    Object? currencyCode = null,
    Object? accountId = freezed,
    Object? notes = freezed,
    Object? active = null,
    Object? nextDueDate = freezed,
    Object? lastPaidDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$BillImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amountMin: null == amountMin
          ? _value.amountMin
          : amountMin // ignore: cast_nullable_to_non_nullable
              as double,
      amountMax: null == amountMax
          ? _value.amountMax
          : amountMax // ignore: cast_nullable_to_non_nullable
              as double,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as BillFrequency,
      dayOfPeriod: null == dayOfPeriod
          ? _value.dayOfPeriod
          : dayOfPeriod // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPaidDate: freezed == lastPaidDate
          ? _value.lastPaidDate
          : lastPaidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$BillImpl implements _Bill {
  const _$BillImpl(
      {required this.id,
      required this.name,
      required this.amountMin,
      required this.amountMax,
      required this.frequency,
      required this.dayOfPeriod,
      this.currencyCode = 'INR',
      this.accountId,
      this.notes,
      this.active = true,
      this.nextDueDate,
      this.lastPaidDate,
      required this.createdAt,
      required this.updatedAt});

  factory _$BillImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double amountMin;
  @override
  final double amountMax;
  @override
  final BillFrequency frequency;
  @override
  final int dayOfPeriod;
  @override
  @JsonKey()
  final String currencyCode;
  @override
  final String? accountId;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool active;
  @override
  final DateTime? nextDueDate;
  @override
  final DateTime? lastPaidDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Bill(id: $id, name: $name, amountMin: $amountMin, amountMax: $amountMax, frequency: $frequency, dayOfPeriod: $dayOfPeriod, currencyCode: $currencyCode, accountId: $accountId, notes: $notes, active: $active, nextDueDate: $nextDueDate, lastPaidDate: $lastPaidDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amountMin, amountMin) ||
                other.amountMin == amountMin) &&
            (identical(other.amountMax, amountMax) ||
                other.amountMax == amountMax) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.dayOfPeriod, dayOfPeriod) ||
                other.dayOfPeriod == dayOfPeriod) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.lastPaidDate, lastPaidDate) ||
                other.lastPaidDate == lastPaidDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      amountMin,
      amountMax,
      frequency,
      dayOfPeriod,
      currencyCode,
      accountId,
      notes,
      active,
      nextDueDate,
      lastPaidDate,
      createdAt,
      updatedAt);

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      __$$BillImplCopyWithImpl<_$BillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillImplToJson(
      this,
    );
  }
}

abstract class _Bill implements Bill {
  const factory _Bill(
      {required final String id,
      required final String name,
      required final double amountMin,
      required final double amountMax,
      required final BillFrequency frequency,
      required final int dayOfPeriod,
      final String currencyCode,
      final String? accountId,
      final String? notes,
      final bool active,
      final DateTime? nextDueDate,
      final DateTime? lastPaidDate,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$BillImpl;

  factory _Bill.fromJson(Map<String, dynamic> json) = _$BillImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get amountMin;
  @override
  double get amountMax;
  @override
  BillFrequency get frequency;
  @override
  int get dayOfPeriod;
  @override
  String get currencyCode;
  @override
  String? get accountId;
  @override
  String? get notes;
  @override
  bool get active;
  @override
  DateTime? get nextDueDate;
  @override
  DateTime? get lastPaidDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Bill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
