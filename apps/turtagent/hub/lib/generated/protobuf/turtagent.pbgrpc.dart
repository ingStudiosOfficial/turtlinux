// This is a generated file - do not edit.
//
// Generated from turtagent.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'turtagent.pb.dart' as $0;

export 'turtagent.pb.dart';

@$pb.GrpcServiceName('turtagent.TurtAgentStreamService')
class TurtAgentStreamServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TurtAgentStreamServiceClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseStream<$0.PromptResponse> generateResponse(
    $0.PromptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$generateResponse, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$generateResponse =
      $grpc.ClientMethod<$0.PromptRequest, $0.PromptResponse>(
          '/turtagent.TurtAgentStreamService/GenerateResponse',
          ($0.PromptRequest value) => value.writeToBuffer(),
          $0.PromptResponse.fromBuffer);
}

@$pb.GrpcServiceName('turtagent.TurtAgentStreamService')
abstract class TurtAgentStreamServiceBase extends $grpc.Service {
  $core.String get $name => 'turtagent.TurtAgentStreamService';

  TurtAgentStreamServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PromptRequest, $0.PromptResponse>(
        'GenerateResponse',
        generateResponse_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.PromptRequest.fromBuffer(value),
        ($0.PromptResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.PromptResponse> generateResponse_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PromptRequest> $request) async* {
    yield* generateResponse($call, await $request);
  }

  $async.Stream<$0.PromptResponse> generateResponse(
      $grpc.ServiceCall call, $0.PromptRequest request);
}
