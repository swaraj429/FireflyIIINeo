// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RuleTrigger _$RuleTriggerFromJson(Map<String, dynamic> json) {
  return _RuleTrigger.fromJson(json);
}

/// @nodoc
mixin _$RuleTrigger {
  String get id => throw _privateConstructorUsedError;
  RuleTriggerCondition get condition => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  bool get stopProcessing => throw _privateConstructorUsedError;
  bool get negate => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this RuleTrigger to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleTriggerCopyWith<RuleTrigger> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleTriggerCopyWith<$Res> {
  factory $RuleTriggerCopyWith(
          RuleTrigger value, $Res Function(RuleTrigger) then) =
      _$RuleTriggerCopyWithImpl<$Res, RuleTrigger>;
  @useResult
  $Res call(
      {String id,
      RuleTriggerCondition condition,
      String value,
      bool stopProcessing,
      bool negate,
      int order});
}

/// @nodoc
class _$RuleTriggerCopyWithImpl<$Res, $Val extends RuleTrigger>
    implements $RuleTriggerCopyWith<$Res> {
  _$RuleTriggerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? condition = null,
    Object? value = null,
    Object? stopProcessing = null,
    Object? negate = null,
    Object? order = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as RuleTriggerCondition,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      stopProcessing: null == stopProcessing
          ? _value.stopProcessing
          : stopProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      negate: null == negate
          ? _value.negate
          : negate // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RuleTriggerImplCopyWith<$Res>
    implements $RuleTriggerCopyWith<$Res> {
  factory _$$RuleTriggerImplCopyWith(
          _$RuleTriggerImpl value, $Res Function(_$RuleTriggerImpl) then) =
      __$$RuleTriggerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      RuleTriggerCondition condition,
      String value,
      bool stopProcessing,
      bool negate,
      int order});
}

/// @nodoc
class __$$RuleTriggerImplCopyWithImpl<$Res>
    extends _$RuleTriggerCopyWithImpl<$Res, _$RuleTriggerImpl>
    implements _$$RuleTriggerImplCopyWith<$Res> {
  __$$RuleTriggerImplCopyWithImpl(
      _$RuleTriggerImpl _value, $Res Function(_$RuleTriggerImpl) _then)
      : super(_value, _then);

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? condition = null,
    Object? value = null,
    Object? stopProcessing = null,
    Object? negate = null,
    Object? order = null,
  }) {
    return _then(_$RuleTriggerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as RuleTriggerCondition,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      stopProcessing: null == stopProcessing
          ? _value.stopProcessing
          : stopProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      negate: null == negate
          ? _value.negate
          : negate // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RuleTriggerImpl implements _RuleTrigger {
  const _$RuleTriggerImpl(
      {required this.id,
      required this.condition,
      required this.value,
      this.stopProcessing = false,
      this.negate = false,
      this.order = 0});

  factory _$RuleTriggerImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleTriggerImplFromJson(json);

  @override
  final String id;
  @override
  final RuleTriggerCondition condition;
  @override
  final String value;
  @override
  @JsonKey()
  final bool stopProcessing;
  @override
  @JsonKey()
  final bool negate;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'RuleTrigger(id: $id, condition: $condition, value: $value, stopProcessing: $stopProcessing, negate: $negate, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleTriggerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.stopProcessing, stopProcessing) ||
                other.stopProcessing == stopProcessing) &&
            (identical(other.negate, negate) || other.negate == negate) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, condition, value, stopProcessing, negate, order);

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleTriggerImplCopyWith<_$RuleTriggerImpl> get copyWith =>
      __$$RuleTriggerImplCopyWithImpl<_$RuleTriggerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleTriggerImplToJson(
      this,
    );
  }
}

abstract class _RuleTrigger implements RuleTrigger {
  const factory _RuleTrigger(
      {required final String id,
      required final RuleTriggerCondition condition,
      required final String value,
      final bool stopProcessing,
      final bool negate,
      final int order}) = _$RuleTriggerImpl;

  factory _RuleTrigger.fromJson(Map<String, dynamic> json) =
      _$RuleTriggerImpl.fromJson;

  @override
  String get id;
  @override
  RuleTriggerCondition get condition;
  @override
  String get value;
  @override
  bool get stopProcessing;
  @override
  bool get negate;
  @override
  int get order;

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleTriggerImplCopyWith<_$RuleTriggerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RuleAction _$RuleActionFromJson(Map<String, dynamic> json) {
  return _RuleAction.fromJson(json);
}

/// @nodoc
mixin _$RuleAction {
  String get id => throw _privateConstructorUsedError;
  RuleActionType get action => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  bool get stopProcessing => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this RuleAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RuleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleActionCopyWith<RuleAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleActionCopyWith<$Res> {
  factory $RuleActionCopyWith(
          RuleAction value, $Res Function(RuleAction) then) =
      _$RuleActionCopyWithImpl<$Res, RuleAction>;
  @useResult
  $Res call(
      {String id,
      RuleActionType action,
      String value,
      bool stopProcessing,
      int order});
}

/// @nodoc
class _$RuleActionCopyWithImpl<$Res, $Val extends RuleAction>
    implements $RuleActionCopyWith<$Res> {
  _$RuleActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuleAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? value = null,
    Object? stopProcessing = null,
    Object? order = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as RuleActionType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      stopProcessing: null == stopProcessing
          ? _value.stopProcessing
          : stopProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RuleActionImplCopyWith<$Res>
    implements $RuleActionCopyWith<$Res> {
  factory _$$RuleActionImplCopyWith(
          _$RuleActionImpl value, $Res Function(_$RuleActionImpl) then) =
      __$$RuleActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      RuleActionType action,
      String value,
      bool stopProcessing,
      int order});
}

/// @nodoc
class __$$RuleActionImplCopyWithImpl<$Res>
    extends _$RuleActionCopyWithImpl<$Res, _$RuleActionImpl>
    implements _$$RuleActionImplCopyWith<$Res> {
  __$$RuleActionImplCopyWithImpl(
      _$RuleActionImpl _value, $Res Function(_$RuleActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of RuleAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? value = null,
    Object? stopProcessing = null,
    Object? order = null,
  }) {
    return _then(_$RuleActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as RuleActionType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      stopProcessing: null == stopProcessing
          ? _value.stopProcessing
          : stopProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RuleActionImpl implements _RuleAction {
  const _$RuleActionImpl(
      {required this.id,
      required this.action,
      required this.value,
      this.stopProcessing = false,
      this.order = 0});

  factory _$RuleActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleActionImplFromJson(json);

  @override
  final String id;
  @override
  final RuleActionType action;
  @override
  final String value;
  @override
  @JsonKey()
  final bool stopProcessing;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'RuleAction(id: $id, action: $action, value: $value, stopProcessing: $stopProcessing, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.stopProcessing, stopProcessing) ||
                other.stopProcessing == stopProcessing) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, action, value, stopProcessing, order);

  /// Create a copy of RuleAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleActionImplCopyWith<_$RuleActionImpl> get copyWith =>
      __$$RuleActionImplCopyWithImpl<_$RuleActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleActionImplToJson(
      this,
    );
  }
}

abstract class _RuleAction implements RuleAction {
  const factory _RuleAction(
      {required final String id,
      required final RuleActionType action,
      required final String value,
      final bool stopProcessing,
      final int order}) = _$RuleActionImpl;

  factory _RuleAction.fromJson(Map<String, dynamic> json) =
      _$RuleActionImpl.fromJson;

  @override
  String get id;
  @override
  RuleActionType get action;
  @override
  String get value;
  @override
  bool get stopProcessing;
  @override
  int get order;

  /// Create a copy of RuleAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleActionImplCopyWith<_$RuleActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Rule _$RuleFromJson(Map<String, dynamic> json) {
  return _Rule.fromJson(json);
}

/// @nodoc
mixin _$Rule {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  RuleTriggerType get trigger => throw _privateConstructorUsedError;
  List<RuleTrigger> get conditions => throw _privateConstructorUsedError;
  List<RuleAction> get actions => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  bool get strict => throw _privateConstructorUsedError;
  bool get stopProcessing => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Rule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleCopyWith<Rule> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleCopyWith<$Res> {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) then) =
      _$RuleCopyWithImpl<$Res, Rule>;
  @useResult
  $Res call(
      {String id,
      String title,
      RuleTriggerType trigger,
      List<RuleTrigger> conditions,
      List<RuleAction> actions,
      bool active,
      bool strict,
      bool stopProcessing,
      int order,
      String? description,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$RuleCopyWithImpl<$Res, $Val extends Rule>
    implements $RuleCopyWith<$Res> {
  _$RuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? trigger = null,
    Object? conditions = null,
    Object? actions = null,
    Object? active = null,
    Object? strict = null,
    Object? stopProcessing = null,
    Object? order = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      trigger: null == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as RuleTriggerType,
      conditions: null == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<RuleTrigger>,
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<RuleAction>,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      strict: null == strict
          ? _value.strict
          : strict // ignore: cast_nullable_to_non_nullable
              as bool,
      stopProcessing: null == stopProcessing
          ? _value.stopProcessing
          : stopProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$RuleImplCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$$RuleImplCopyWith(
          _$RuleImpl value, $Res Function(_$RuleImpl) then) =
      __$$RuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      RuleTriggerType trigger,
      List<RuleTrigger> conditions,
      List<RuleAction> actions,
      bool active,
      bool strict,
      bool stopProcessing,
      int order,
      String? description,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$RuleImplCopyWithImpl<$Res>
    extends _$RuleCopyWithImpl<$Res, _$RuleImpl>
    implements _$$RuleImplCopyWith<$Res> {
  __$$RuleImplCopyWithImpl(_$RuleImpl _value, $Res Function(_$RuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? trigger = null,
    Object? conditions = null,
    Object? actions = null,
    Object? active = null,
    Object? strict = null,
    Object? stopProcessing = null,
    Object? order = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      trigger: null == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as RuleTriggerType,
      conditions: null == conditions
          ? _value._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<RuleTrigger>,
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<RuleAction>,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      strict: null == strict
          ? _value.strict
          : strict // ignore: cast_nullable_to_non_nullable
              as bool,
      stopProcessing: null == stopProcessing
          ? _value.stopProcessing
          : stopProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
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
class _$RuleImpl implements _Rule {
  const _$RuleImpl(
      {required this.id,
      required this.title,
      required this.trigger,
      required final List<RuleTrigger> conditions,
      required final List<RuleAction> actions,
      this.active = true,
      this.strict = false,
      this.stopProcessing = false,
      this.order = 0,
      this.description,
      required this.createdAt,
      required this.updatedAt})
      : _conditions = conditions,
        _actions = actions;

  factory _$RuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final RuleTriggerType trigger;
  final List<RuleTrigger> _conditions;
  @override
  List<RuleTrigger> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  final List<RuleAction> _actions;
  @override
  List<RuleAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey()
  final bool strict;
  @override
  @JsonKey()
  final bool stopProcessing;
  @override
  @JsonKey()
  final int order;
  @override
  final String? description;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Rule(id: $id, title: $title, trigger: $trigger, conditions: $conditions, actions: $actions, active: $active, strict: $strict, stopProcessing: $stopProcessing, order: $order, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.trigger, trigger) || other.trigger == trigger) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.strict, strict) || other.strict == strict) &&
            (identical(other.stopProcessing, stopProcessing) ||
                other.stopProcessing == stopProcessing) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.description, description) ||
                other.description == description) &&
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
      title,
      trigger,
      const DeepCollectionEquality().hash(_conditions),
      const DeepCollectionEquality().hash(_actions),
      active,
      strict,
      stopProcessing,
      order,
      description,
      createdAt,
      updatedAt);

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleImplCopyWith<_$RuleImpl> get copyWith =>
      __$$RuleImplCopyWithImpl<_$RuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleImplToJson(
      this,
    );
  }
}

abstract class _Rule implements Rule {
  const factory _Rule(
      {required final String id,
      required final String title,
      required final RuleTriggerType trigger,
      required final List<RuleTrigger> conditions,
      required final List<RuleAction> actions,
      final bool active,
      final bool strict,
      final bool stopProcessing,
      final int order,
      final String? description,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$RuleImpl;

  factory _Rule.fromJson(Map<String, dynamic> json) = _$RuleImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  RuleTriggerType get trigger;
  @override
  List<RuleTrigger> get conditions;
  @override
  List<RuleAction> get actions;
  @override
  bool get active;
  @override
  bool get strict;
  @override
  bool get stopProcessing;
  @override
  int get order;
  @override
  String? get description;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Rule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleImplCopyWith<_$RuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
