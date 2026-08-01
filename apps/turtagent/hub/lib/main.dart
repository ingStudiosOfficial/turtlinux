import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:turtagent_hub/core/data/db/database.dart';
import 'package:turtagent_hub/core/data/models/database_types.dart';
import 'package:turtagent_hub/features/chat/presentation/chat.dart';
import 'package:turtagent_hub/features/conversations/presentation/conversations_sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConversationsDb().init();

  final initialChat = ConversationItem(
    id: 'coolid',
    title: 'Cool Title',
    history: [
      ChatMessage(
        assistant: AssistantMessage(isThinking: false, text: 'hi'),
        user: 'hi',
      ),
    ],
  );

  runApp(MyApp(initialChat: initialChat));
}

class MyApp extends StatefulWidget {
  final ConversationItem? initialChat;
  const MyApp({super.key, this.initialChat});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _chatContainerController = ChatContainerController();

  @override
  void initState() {
    super.initState();
    if (widget.initialChat != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatContainerController.setChat(widget.initialChat!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatContainer = ChatContainer(controller: _chatContainerController);

    return DynamicColorBuilder(
      builder: (ColorScheme? light, ColorScheme? dark) {
        light = light ?? ColorScheme.fromSeed(seedColor: Color(0xFF00A1BC));
        dark = dark ?? ColorScheme.fromSeed(seedColor: Color(0xFF00A1BC));

        return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: light,
            scaffoldBackgroundColor: light.surface,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: dark,
            scaffoldBackgroundColor: dark.surface,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('Turtagent Hub')),
            drawer: Drawer(child: const ConversationsSidebar()),
            body: chatContainer,
          ),
        );
      },
    );
  }
}
