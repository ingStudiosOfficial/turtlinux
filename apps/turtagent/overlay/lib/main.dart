import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:turtagent/features/overlay/presentation/agent_overlay.dart';

void main() {
  runApp(const MyApp());
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
            scaffoldBackgroundColor: Colors.transparent,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: dark,
            scaffoldBackgroundColor: Colors.transparent,
          ),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: AgentOverlay(),
            ),
          ),
        );
      },
    );
  }
}
