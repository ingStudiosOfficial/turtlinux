import 'package:flutter/material.dart';
import 'package:turtagent/features/overlay/presentation/data/agent_rpc_service.dart';
import 'package:turtagent/features/overlay/presentation/input_overlay.dart';
import 'package:turtagent/features/overlay/presentation/response_overlay.dart';

class AgentOverlay extends StatefulWidget {
  const AgentOverlay({super.key});

  @override
  State<AgentOverlay> createState() => _AgentOverlayState();
}

class _AgentOverlayState extends State<AgentOverlay> {
  bool _showResponseOverlay = false;
  final _agentRpcService = AgentRpcService();
  late Stream<String> _responseStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showResponseOverlay)
          ResponseOverlay(responseStream: _responseStream),
        InputOverlay(onPrompt: _onPrompt),
      ],
    );
  }

  void _onPrompt(String prompt) {
    setState(() {
      _showResponseOverlay = true;
      _responseStream = _agentRpcService.streamPrompt(prompt);
    });
  }
}
