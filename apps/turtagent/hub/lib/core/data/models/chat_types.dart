import 'package:turtagent_hub/core/data/models/database_types.dart';

typedef ChatStreamHistory =
    List<({Stream<({bool isThinking, String text})> assistant, String user})>;

typedef ChatTextHistory =
    List<({({bool isThinking, String text}) assistant, String user})>;

typedef Conversations = List<ConversationItem>;
