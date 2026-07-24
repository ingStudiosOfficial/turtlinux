import 'package:flutter/material.dart';
import 'package:turtagent_hub/features/chat/data/agent_rpc_service.dart';
import 'package:turtagent_hub/features/chat/presentation/response_item.dart';

class InputOverlayController {
  void Function()? onEnd;
}

class ChatContainer extends StatefulWidget {
  const ChatContainer({super.key});

  @override
  State<StatefulWidget> createState() => _ChatContainerState();
}

class _ChatContainerState extends State<ChatContainer> {
  final TextEditingController _promptTextController = TextEditingController();
  final _agentRpcService = AgentRpcService();
  final _inputOverlayController = InputOverlayController();

  final List<
    ({Stream<({bool isThinking, String text})> assistant, String user})
  >
  _chatHistory = [];

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _inputOverlayController.onEnd = _onDone;
  }

  @override
  void dispose() {
    _promptTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _chatHistory.map((el) {
                return FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          el.user,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ResponseItem(responseStream: el.assistant),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Center(child: buildInputWidget(theme)),
      ],
    );
  }

  Widget buildInputWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(120),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(150),
                blurRadius: 16,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(50),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: TextField(
                  controller: _promptTextController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Ask Tutel',
                    border: InputBorder.none,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onSubmitted: (_) => _onSend(),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic),
                color: theme.colorScheme.onSurface,
              ),
              _isGenerating
                  ? IconButton.filledTonal(
                      onPressed: _onStop,
                      icon: const Icon(Icons.stop),
                    )
                  : IconButton.filled(
                      onPressed: _onSend,
                      icon: const Icon(Icons.send),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSend() {
    final text = _promptTextController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    final stream = _agentRpcService.streamPrompt(text).asBroadcastStream();

    setState(() {
      _isGenerating = true;

      _chatHistory.add((assistant: stream, user: text));
    });

    _promptTextController.clear();

    stream.listen(
      (data) {},
      onDone: () => _onDone(),
      onError: (_) => _onDone(),
      cancelOnError: true,
    );
  }

  void _onStop() {
    _agentRpcService.cancelCurrentStream();
    _setGeneratingState(false);
  }

  void _onDone() {
    _setGeneratingState(false);
  }

  void _setGeneratingState(bool state) {
    setState(() {
      _isGenerating = state;
    });
  }
}
