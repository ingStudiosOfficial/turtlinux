import 'package:nitrite/nitrite.dart';

part 'database_types.no2.dart';

@Convertable()
@Entity(name: 'history')
class ConversationItem with _$ConversationItemEntityMixin {
  @Id()
  String id;
  String title;
  List<ChatMessage> history;
  DateTime lastUpdated;

  ConversationItem({
    required this.id,
    required this.title,
    required this.history,
    required this.lastUpdated,
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
  bool isThinking;
  String text;

  AssistantMessage({required this.isThinking, required this.text});
}
