// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sms_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SmsMessage _$SmsMessageFromJson(Map<String, dynamic> json) {
  return _SmsMessage.fromJson(json);
}

/// @nodoc
mixin _$SmsMessage {
  String get id => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get receivedAt => throw _privateConstructorUsedError;
  SmsStatus get status => throw _privateConstructorUsedError;
  SmsParseResult? get parseResult => throw _privateConstructorUsedError;
  String? get parsedTransactionId => throw _privateConstructorUsedError;
  double? get parsedAmount => throw _privateConstructorUsedError;
  String? get parsedMerchant => throw _privateConstructorUsedError;
  String? get parsedAccountLast4 => throw _privateConstructorUsedError;
  String? get parsedType => throw _privateConstructorUsedError;
  String? get parseError => throw _privateConstructorUsedError;
  Map<String, dynamic>? get rawMetadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SmsMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmsMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmsMessageCopyWith<SmsMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmsMessageCopyWith<$Res> {
  factory $SmsMessageCopyWith(
          SmsMessage value, $Res Function(SmsMessage) then) =
      _$SmsMessageCopyWithImpl<$Res, SmsMessage>;
  @useResult
  $Res call(
      {String id,
      String sender,
      String body,
      DateTime receivedAt,
      SmsStatus status,
      SmsParseResult? parseResult,
      String? parsedTransactionId,
      double? parsedAmount,
      String? parsedMerchant,
      String? parsedAccountLast4,
      String? parsedType,
      String? parseError,
      Map<String, dynamic>? rawMetadata,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SmsMessageCopyWithImpl<$Res, $Val extends SmsMessage>
    implements $SmsMessageCopyWith<$Res> {
  _$SmsMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmsMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? body = null,
    Object? receivedAt = null,
    Object? status = null,
    Object? parseResult = freezed,
    Object? parsedTransactionId = freezed,
    Object? parsedAmount = freezed,
    Object? parsedMerchant = freezed,
    Object? parsedAccountLast4 = freezed,
    Object? parsedType = freezed,
    Object? parseError = freezed,
    Object? rawMetadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      receivedAt: null == receivedAt
          ? _value.receivedAt
          : receivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SmsStatus,
      parseResult: freezed == parseResult
          ? _value.parseResult
          : parseResult // ignore: cast_nullable_to_non_nullable
              as SmsParseResult?,
      parsedTransactionId: freezed == parsedTransactionId
          ? _value.parsedTransactionId
          : parsedTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      parsedAmount: freezed == parsedAmount
          ? _value.parsedAmount
          : parsedAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      parsedMerchant: freezed == parsedMerchant
          ? _value.parsedMerchant
          : parsedMerchant // ignore: cast_nullable_to_non_nullable
              as String?,
      parsedAccountLast4: freezed == parsedAccountLast4
          ? _value.parsedAccountLast4
          : parsedAccountLast4 // ignore: cast_nullable_to_non_nullable
              as String?,
      parsedType: freezed == parsedType
          ? _value.parsedType
          : parsedType // ignore: cast_nullable_to_non_nullable
              as String?,
      parseError: freezed == parseError
          ? _value.parseError
          : parseError // ignore: cast_nullable_to_non_nullable
              as String?,
      rawMetadata: freezed == rawMetadata
          ? _value.rawMetadata
          : rawMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
abstract class _$$SmsMessageImplCopyWith<$Res>
    implements $SmsMessageCopyWith<$Res> {
  factory _$$SmsMessageImplCopyWith(
          _$SmsMessageImpl value, $Res Function(_$SmsMessageImpl) then) =
      __$$SmsMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sender,
      String body,
      DateTime receivedAt,
      SmsStatus status,
      SmsParseResult? parseResult,
      String? parsedTransactionId,
      double? parsedAmount,
      String? parsedMerchant,
      String? parsedAccountLast4,
      String? parsedType,
      String? parseError,
      Map<String, dynamic>? rawMetadata,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SmsMessageImplCopyWithImpl<$Res>
    extends _$SmsMessageCopyWithImpl<$Res, _$SmsMessageImpl>
    implements _$$SmsMessageImplCopyWith<$Res> {
  __$$SmsMessageImplCopyWithImpl(
      _$SmsMessageImpl _value, $Res Function(_$SmsMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SmsMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? body = null,
    Object? receivedAt = null,
    Object? status = null,
    Object? parseResult = freezed,
    Object? parsedTransactionId = freezed,
    Object? parsedAmount = freezed,
    Object? parsedMerchant = freezed,
    Object? parsedAccountLast4 = freezed,
    Object? parsedType = freezed,
    Object? parseError = freezed,
    Object? rawMetadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SmsMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      receivedAt: null == receivedAt
          ? _value.receivedAt
          : receivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SmsStatus,
      parseResult: freezed == parseResult
          ? _value.parseResult
          : parseResult // ignore: cast_nullable_to_non_nullable
              as SmsParseResult?,
      parsedTransactionId: freezed == parsedTransactionId
          ? _value.parsedTransactionId
          : parsedTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      parsedAmount: freezed == parsedAmount
          ? _value.parsedAmount
          : parsedAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      parsedMerchant: freezed == parsedMerchant
          ? _value.parsedMerchant
          : parsedMerchant // ignore: cast_nullable_to_non_nullable
              as String?,
      parsedAccountLast4: freezed == parsedAccountLast4
          ? _value.parsedAccountLast4
          : parsedAccountLast4 // ignore: cast_nullable_to_non_nullable
              as String?,
      parsedType: freezed == parsedType
          ? _value.parsedType
          : parsedType // ignore: cast_nullable_to_non_nullable
              as String?,
      parseError: freezed == parseError
          ? _value.parseError
          : parseError // ignore: cast_nullable_to_non_nullable
              as String?,
      rawMetadata: freezed == rawMetadata
          ? _value._rawMetadata
          : rawMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
class _$SmsMessageImpl implements _SmsMessage {
  const _$SmsMessageImpl(
      {required this.id,
      required this.sender,
      required this.body,
      required this.receivedAt,
      required this.status,
      this.parseResult,
      this.parsedTransactionId,
      this.parsedAmount,
      this.parsedMerchant,
      this.parsedAccountLast4,
      this.parsedType,
      this.parseError,
      final Map<String, dynamic>? rawMetadata,
      required this.createdAt,
      required this.updatedAt})
      : _rawMetadata = rawMetadata;

  factory _$SmsMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmsMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String sender;
  @override
  final String body;
  @override
  final DateTime receivedAt;
  @override
  final SmsStatus status;
  @override
  final SmsParseResult? parseResult;
  @override
  final String? parsedTransactionId;
  @override
  final double? parsedAmount;
  @override
  final String? parsedMerchant;
  @override
  final String? parsedAccountLast4;
  @override
  final String? parsedType;
  @override
  final String? parseError;
  final Map<String, dynamic>? _rawMetadata;
  @override
  Map<String, dynamic>? get rawMetadata {
    final value = _rawMetadata;
    if (value == null) return null;
    if (_rawMetadata is EqualUnmodifiableMapView) return _rawMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SmsMessage(id: $id, sender: $sender, body: $body, receivedAt: $receivedAt, status: $status, parseResult: $parseResult, parsedTransactionId: $parsedTransactionId, parsedAmount: $parsedAmount, parsedMerchant: $parsedMerchant, parsedAccountLast4: $parsedAccountLast4, parsedType: $parsedType, parseError: $parseError, rawMetadata: $rawMetadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmsMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.parseResult, parseResult) ||
                other.parseResult == parseResult) &&
            (identical(other.parsedTransactionId, parsedTransactionId) ||
                other.parsedTransactionId == parsedTransactionId) &&
            (identical(other.parsedAmount, parsedAmount) ||
                other.parsedAmount == parsedAmount) &&
            (identical(other.parsedMerchant, parsedMerchant) ||
                other.parsedMerchant == parsedMerchant) &&
            (identical(other.parsedAccountLast4, parsedAccountLast4) ||
                other.parsedAccountLast4 == parsedAccountLast4) &&
            (identical(other.parsedType, parsedType) ||
                other.parsedType == parsedType) &&
            (identical(other.parseError, parseError) ||
                other.parseError == parseError) &&
            const DeepCollectionEquality()
                .equals(other._rawMetadata, _rawMetadata) &&
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
      sender,
      body,
      receivedAt,
      status,
      parseResult,
      parsedTransactionId,
      parsedAmount,
      parsedMerchant,
      parsedAccountLast4,
      parsedType,
      parseError,
      const DeepCollectionEquality().hash(_rawMetadata),
      createdAt,
      updatedAt);

  /// Create a copy of SmsMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmsMessageImplCopyWith<_$SmsMessageImpl> get copyWith =>
      __$$SmsMessageImplCopyWithImpl<_$SmsMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmsMessageImplToJson(
      this,
    );
  }
}

abstract class _SmsMessage implements SmsMessage {
  const factory _SmsMessage(
      {required final String id,
      required final String sender,
      required final String body,
      required final DateTime receivedAt,
      required final SmsStatus status,
      final SmsParseResult? parseResult,
      final String? parsedTransactionId,
      final double? parsedAmount,
      final String? parsedMerchant,
      final String? parsedAccountLast4,
      final String? parsedType,
      final String? parseError,
      final Map<String, dynamic>? rawMetadata,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SmsMessageImpl;

  factory _SmsMessage.fromJson(Map<String, dynamic> json) =
      _$SmsMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get sender;
  @override
  String get body;
  @override
  DateTime get receivedAt;
  @override
  SmsStatus get status;
  @override
  SmsParseResult? get parseResult;
  @override
  String? get parsedTransactionId;
  @override
  double? get parsedAmount;
  @override
  String? get parsedMerchant;
  @override
  String? get parsedAccountLast4;
  @override
  String? get parsedType;
  @override
  String? get parseError;
  @override
  Map<String, dynamic>? get rawMetadata;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SmsMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmsMessageImplCopyWith<_$SmsMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
