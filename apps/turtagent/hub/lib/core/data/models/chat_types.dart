typedef ChatStreamHistory =
    List<({Stream<({bool isThinking, String text})> assistant, String user})>;

typedef ChatTextHistory =
    List<({({bool isThinking, String text}) assistant, String user})>;

typedef ConversationItem = ({String title, ChatTextHistory history});

typedef Conversations = List<ConversationItem>;
