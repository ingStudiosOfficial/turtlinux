import 'package:grpc/grpc.dart';
import 'package:turtagent/generated/protobuf/turtagent.pbgrpc.dart';

class AgentRpcService {
  late final ClientChannel _channel;
  late final TurtAgentStreamServiceClient _client;
  ResponseStream<PromptResponse>? _currentStream;

  AgentRpcService() {
    _channel = ClientChannel(
      'localhost',
      port: 50707,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _client = TurtAgentStreamServiceClient(_channel);
  }

  Stream<({bool isThinking, String text})> streamPrompt(
    String userPrompt,
  ) async* {
    await cancelCurrentStream();

    final request = PromptRequest()..prompt = userPrompt;

    try {
      _currentStream = _client.generateResponse(request);

      await for (final response in _currentStream!) {
        if (response.textChunk.isNotEmpty) {
          yield (isThinking: response.isThinking, text: response.textChunk);
        }

        if (response.isFinal) break;
      }
    } catch (error) {
      yield (
        isThinking: false,
        text: 'Error: Lost connection to turtagent daemon',
      );
    } finally {
      _currentStream = null;
    }
  }

  Future<void> cancelCurrentStream() async {
    if (_currentStream != null) {
      await _currentStream!.cancel();
      _currentStream = null;
    }
  }

  Future<void> shutdown() async {
    await cancelCurrentStream();
    await _channel.shutdown();
  }
}
