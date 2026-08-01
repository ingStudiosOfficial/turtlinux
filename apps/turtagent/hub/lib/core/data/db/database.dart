import 'dart:io';

import 'package:nitrite/nitrite.dart';
import 'package:nitrite_hive_adapter/nitrite_hive_adapter.dart';
import 'package:path/path.dart' as path;
import 'package:turtagent_hub/core/data/models/chat_types.dart';
import 'package:turtagent_hub/core/data/models/database_types.dart';

class ConversationsDb {
  ConversationsDb._internal();
  static final ConversationsDb _instance = ConversationsDb._internal();

  late Nitrite _db;

  factory ConversationsDb() {
    return _instance;
  }

  Future<void> init() async {
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
  }

  void addHistory(ConversationItem item) async {
    final repository = await _db.getRepository<ConversationItem>(
      key: 'history',
    );
    await repository.insert(item);
  }

  Future<Conversations?> getHistory(int amountToLoad) async {
    final repository = await _db.getRepository<ConversationItem>(
      key: 'history',
    );
    final history = await repository
        .find(findOptions: FindOptions(limit: amountToLoad))
        .toList();
    return history;
  }
}
