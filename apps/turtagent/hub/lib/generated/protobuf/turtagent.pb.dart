// This is a generated file - do not edit.
//
// Generated from turtagent.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class PromptRequest extends $pb.GeneratedMessage {
  factory PromptRequest({
    $core.String? prompt,
  }) {
    final result = create();
    if (prompt != null) result.prompt = prompt;
    return result;
  }

  PromptRequest._();

  factory PromptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turtagent'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'prompt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptRequest copyWith(void Function(PromptRequest) updates) =>
      super.copyWith((message) => updates(message as PromptRequest))
          as PromptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromptRequest create() => PromptRequest._();
  @$core.override
  PromptRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PromptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromptRequest>(create);
  static PromptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prompt => $_getSZ(0);
  @$pb.TagNumber(1)
  set prompt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrompt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrompt() => $_clearField(1);
}

class PromptResponse extends $pb.GeneratedMessage {
  factory PromptResponse({
    $core.String? textChunk,
    $core.bool? isThinking,
    $core.bool? isFinal,
  }) {
    final result = create();
    if (textChunk != null) result.textChunk = textChunk;
    if (isThinking != null) result.isThinking = isThinking;
    if (isFinal != null) result.isFinal = isFinal;
    return result;
  }

  PromptResponse._();

  factory PromptResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromptResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromptResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'turtagent'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'textChunk')
    ..aOB(2, _omitFieldNames ? '' : 'isThinking')
    ..aOB(3, _omitFieldNames ? '' : 'isFinal')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptResponse copyWith(void Function(PromptResponse) updates) =>
      super.copyWith((message) => updates(message as PromptResponse))
          as PromptResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromptResponse create() => PromptResponse._();
  @$core.override
  PromptResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PromptResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromptResponse>(create);
  static PromptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get textChunk => $_getSZ(0);
  @$pb.TagNumber(1)
  set textChunk($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTextChunk() => $_has(0);
  @$pb.TagNumber(1)
  void clearTextChunk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isThinking => $_getBF(1);
  @$pb.TagNumber(2)
  set isThinking($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsThinking() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsThinking() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isFinal => $_getBF(2);
  @$pb.TagNumber(3)
  set isFinal($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsFinal() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsFinal() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
