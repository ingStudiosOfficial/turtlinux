import 'package:flutter/material.dart';
import 'package:turtagent/features/overlay/presentation/input_overlay.dart';
import 'package:turtagent/features/overlay/presentation/response_overlay.dart';

class AgentOverlay extends StatefulWidget {
  const AgentOverlay({super.key});

  @override
  State<AgentOverlay> createState() => _AgentOverlayState();
}

class _AgentOverlayState extends State<AgentOverlay> {
  bool _showResponseOverlay = false;
  String _latestPrompt = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showResponseOverlay) ResponseOverlay(),
        InputOverlay(onPrompt: _onPrompt),
      ],
    );
  }

  void _onPrompt(String prompt) {
    setState(() {
      _latestPrompt = prompt;
      _showResponseOverlay = true;
    });
  }
}
