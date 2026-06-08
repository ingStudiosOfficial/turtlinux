import 'package:flutter/material.dart';
import 'package:turtagent/features/overlay/presentation/agent_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00A1BC)),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const Scaffold(
        body: Align(alignment: Alignment.bottomCenter, child: AgentOverlay()),
      ),
    );
  }
}
