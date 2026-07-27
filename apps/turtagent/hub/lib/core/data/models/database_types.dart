import 'package:nitrite/nitrite.dart';

part 'database_types.no2.dart';

@Convertable()
@Entity(name: 'history')
class ConversationItem with _$ConversationItemEntityMixin {
  @Id()
  String id;
  String title;
  List<ChatMessage> history;

  ConversationItem({
    required this.id,
    required this.title,
    required this.history,
  });
}

@Convertable()
class ChatMessage {
  final AssistantMessage assistant;
  final String user;

  ChatMessage({required this.assistant, required this.user});
}

@Convertable()
class AssistantMessage {
  final bool isThinking;
  final String text;

  AssistantMessage({required this.isThinking, required this.text});
}
