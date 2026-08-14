import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitrite/nitrite.dart';
import 'package:nitrite_hive_adapter/nitrite_hive_adapter.dart';
import 'package:path/path.dart' as path;
import 'package:turtagent_hub/core/data/models/chat_types.dart';
import 'package:turtagent_hub/core/data/models/database_types.dart';

class _ConversationsNotifier extends AsyncNotifier<Conversations> {
  late Nitrite _db;

  @override
  Future<Conversations> build() async {
    final String? home = Platform.environment['HOME'];
    final String storageDir = '.local/share/turtagent_hub/';
    final String dbDir = 'database/';
    final String filename = 'main';

    final String dbPath = path.join(home ?? '', storageDir, dbDir, filename);

    var storeModule = HiveModule.withConfig()
        .crashRecovery(true)
        .path(dbPath)
        .build();

    _db = await Nitrite.builder()
        .loadModule(storeModule)
        .registerEntityConverter(ConversationItemConverter())
        .registerEntityConverter(ChatMessageConverter())
        .registerEntityConverter(AssistantMessageConverter())
        .openOrCreate();

    return await getHistory(10);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => getHistory(10));
  }

  Future<void> addHistory(ConversationItem item) async {
    final currentHistory = state.valueOrNull ?? [];
    state = await AsyncValue.guard(() async {
      final repository = await _db.getRepository<ConversationItem>(
        key: 'history',
      );
      await repository.insert(item);
      return [...currentHistory, item];
    });
  }

  Future<Conversations> getHistory(int amountToLoad) async {
    final repository = await _db.getRepository<ConversationItem>(
      key: 'history',
    );
    final history = await repository
        .find(findOptions: FindOptions(limit: amountToLoad))
        .toList();
    return history;
  }
}

final conversationsProvider =
    AsyncNotifierProvider<_ConversationsNotifier, Conversations>(() {
      return _ConversationsNotifier();
    });
