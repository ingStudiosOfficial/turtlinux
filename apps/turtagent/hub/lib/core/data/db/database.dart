import 'dart:io';

import 'package:nitrite/nitrite.dart';
import 'package:nitrite_hive_adapter/nitrite_hive_adapter.dart';
import 'package:path/path.dart' as path;
import 'package:turtagent_hub/core/data/models/chat_types.dart';

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

    _db = await Nitrite.builder().loadModule(storeModule).openOrCreate();
  }

  void addHistory(ConversationItem item) async {
    var collection = await _db.getCollection('history');
    var cursor = collection.find();
    var currentDocument = await cursor.first;

    var conversations = currentDocument.get<Conversations>('conversations');
    conversations?.add(item);

    currentDocument.put('conversations', conversations);
    await collection.update(
      where('_id').eq(currentDocument.id),
      currentDocument,
    );
  }

  Future<Conversations?> getHistory() async {
    var collection = await _db.getCollection('history');
    var cursor = collection.find();

    try {
      var currentDocument = await cursor.first;
      return currentDocument.get<Conversations>('conversations');
    } catch (error) {
      print(error);
      return null;
    }
  }
}
