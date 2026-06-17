import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turtagent/features/overlay/data/agent_rpc_service.dart';
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
  late Stream<({bool isThinking, String text})> _responseStream;
  late StreamSubscription<({bool isThinking, String text})> _responseStreamSubscription;
  final _inputOverlayController = InputOverlayController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showResponseOverlay)
          ResponseOverlay(responseStream: _responseStream),
        InputOverlay(
          onPrompt: _onPrompt,
          inputOverlayController: _inputOverlayController,
          onStop: _onStop,
        ),
      ],
    );
  }

  void _onPrompt(String prompt) {
    setState(() {
      _showResponseOverlay = true;
      _responseStream = _agentRpcService
          .streamPrompt(prompt)
          .asBroadcastStream();
      _responseStreamSubscription = _responseStream.listen(
        (data) {},
        onDone: () {
          _inputOverlayController.onEnd?.call();
        },
      );
    });
  }

  void _onStop() {
    _responseStreamSubscription.cancel();
    _agentRpcService.cancelCurrentStream();
    _agentRpcService.shutdown();
  }
}
