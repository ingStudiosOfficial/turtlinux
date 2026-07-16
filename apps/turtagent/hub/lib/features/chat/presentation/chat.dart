import 'package:flutter/material.dart';
import 'package:turtagent_hub/features/chat/data/agent_rpc_service.dart';

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
  late Stream<({bool isThinking, String text})> _responseStream;
  final _inputOverlayController = InputOverlayController();

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
      children: [Container(), const Spacer(), buildInputWidget(theme)],
    );
  }

  Widget buildInputWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: Container(
          padding: EdgeInsets.all(12),
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
                  onSubmitted: (value) => _onSend(),
                ),
              ),
              IconButton(
                onPressed: () => {},
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
    _onPrompt(_promptTextController.text);
    _setGeneratingState(true);
    _promptTextController.clear();
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

  void _onPrompt(String prompt) {
    setState(() {
      _responseStream = _agentRpcService
          .streamPrompt(prompt)
          .asBroadcastStream();
      _responseStream.listen(
        (data) {},
        onDone: () {
          _inputOverlayController.onEnd?.call();
        },
      );
    });
  }
}
