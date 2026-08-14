import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turtagent_hub/core/data/models/chat_types.dart';
import 'package:turtagent_hub/core/data/models/database_types.dart';
import 'package:turtagent_hub/features/chat/data/agent_rpc_service.dart';
import 'package:turtagent_hub/features/chat/presentation/response_item.dart';
import 'package:turtagent_hub/features/conversations/providers/conversations_notifier.dart';
import 'package:uuid/uuid.dart';

class ChatContainerController {
  VoidCallback? onEnd;
  ValueChanged<ConversationItem?>? _onSetChat;

  void setChat(ConversationItem? chat) {
    debugPrint('In controller setChat.');
    if (_onSetChat != null) {
      _onSetChat!(chat);
    }
  }
}

class ChatContainer extends ConsumerStatefulWidget {
  final ChatContainerController controller;

  const ChatContainer({super.key, required this.controller});

  @override
  ConsumerState<ChatContainer> createState() => _ChatContainerState();
}

class _ChatContainerState extends ConsumerState<ChatContainer> {
  final TextEditingController _promptTextController = TextEditingController();
  final _agentRpcService = AgentRpcService();
  final ChatStreamHistory _chatHistory = [];
  late ConversationItem _currentChat;
  bool _isGenerating = false;
  bool _isNewChat = true;
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _createNewChat();
    _initControllerListeners();
  }

  @override
  void didUpdateWidget(covariant ChatContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._onSetChat = null;
      oldWidget.controller.onEnd = null;
      _initControllerListeners();
      _createNewChat();
    }
  }

  void _initControllerListeners() {
    widget.controller.onEnd = _onDone;
    widget.controller._onSetChat = (ConversationItem? chat) {
      debugPrint('Setting chat...');

      setState(() {
        if (chat != null) {
          _isNewChat = false;
          _currentChat = chat;
          _chatHistory.clear();

          for (final item in chat.history) {
            final assistantStream = Stream.value(item.assistant);
            final messageStream = ChatMessageStream(
              assistant: assistantStream,
              user: item.user,
            );
            _chatHistory.add(messageStream);
          }
        } else {
          _createNewChat();
        }
      });
    };
  }

  @override
  void dispose() {
    widget.controller._onSetChat = null;
    widget.controller.onEnd = null;
    _promptTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsProvider);

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
                          style: const TextStyle(fontSize: 18),
                          el.user,
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
        Center(child: _buildInputWidget(theme)),
      ],
    );
  }

  Widget _buildInputWidget(ThemeData theme) {
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

  void _createNewChat() {
    _isNewChat = true;
    _currentChat = ConversationItem(
      id: uuid.v4(),
      title: 'Untitled Chat',
      history: [],
    );
    _chatHistory.clear();
  }

  Future<void> _onSend() async {
    final text = _promptTextController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    if (_isNewChat) {
      _currentChat.title = text;
      await ref.read(conversationsProvider.notifier).addHistory(_currentChat);
      _isNewChat = false;
    }

    final stream = _agentRpcService.streamPrompt(text).asBroadcastStream();

    setState(() {
      _isGenerating = true;

      _chatHistory.add(ChatMessageStream(assistant: stream, user: text));
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
