import 'package:turtagent_hub/core/data/models/database_types.dart';

typedef ChatStreamHistory = List<ChatMessageStream>;

typedef ChatTextHistory = List<ChatMessage>;

typedef Conversations = List<ConversationItem>;

class ChatMessageStream {
  final Stream<AssistantMessage> assistant;
  final String user;

  ChatMessageStream({required this.assistant, required this.user});
}
