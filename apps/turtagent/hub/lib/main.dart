import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:turtagent_hub/core/data/db/database.dart';
import 'package:turtagent_hub/features/chat/presentation/chat.dart';
import 'package:turtagent_hub/features/conversations/presentation/conversations_sidebar.dart';

void main() async {
  runApp(const MyApp());
  await ConversationsDb().init();
  var history = await ConversationsDb().getHistory();
  if (history == null) {
    print('History is null');
  } else {
    for (final item in history) {
      print(item.title);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            body: const ChatContainer(),
          ),
        );
      },
    );
  }
}
