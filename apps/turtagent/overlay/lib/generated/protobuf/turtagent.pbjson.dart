// This is a generated file - do not edit.
//
// Generated from turtagent.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use promptRequestDescriptor instead')
const PromptRequest$json = {
  '1': 'PromptRequest',
  '2': [
    {'1': 'prompt', '3': 1, '4': 1, '5': 9, '10': 'prompt'},
  ],
};

/// Descriptor for `PromptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promptRequestDescriptor = $convert
    .base64Decode('Cg1Qcm9tcHRSZXF1ZXN0EhYKBnByb21wdBgBIAEoCVIGcHJvbXB0');

@$core.Deprecated('Use promptResponseDescriptor instead')
const PromptResponse$json = {
  '1': 'PromptResponse',
  '2': [
    {'1': 'text_chunk', '3': 1, '4': 1, '5': 9, '10': 'textChunk'},
    {'1': 'is_thinking', '3': 2, '4': 1, '5': 8, '10': 'isThinking'},
    {'1': 'is_final', '3': 3, '4': 1, '5': 8, '10': 'isFinal'},
  ],
};

/// Descriptor for `PromptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promptResponseDescriptor = $convert.base64Decode(
    'Cg5Qcm9tcHRSZXNwb25zZRIdCgp0ZXh0X2NodW5rGAEgASgJUgl0ZXh0Q2h1bmsSHwoLaXNfdG'
    'hpbmtpbmcYAiABKAhSCmlzVGhpbmtpbmcSGQoIaXNfZmluYWwYAyABKAhSB2lzRmluYWw=');
