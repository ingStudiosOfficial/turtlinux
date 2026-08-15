// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'database_types.dart';

// **************************************************************************
// AnalyzerHintGenerator
// **************************************************************************

// ignore_for_file: invalid_use_of_internal_member

// **************************************************************************
// NitriteEntityGenerator
// **************************************************************************

mixin _$ConversationItemEntityMixin implements NitriteEntity {
  @override
  String get entityName => "history";

  @override
  List<EntityIndex> get entityIndexes => const [];

  @override
  EntityId get entityId => EntityId("id", false);
}

// **************************************************************************
// ConverterGenerator
// **************************************************************************

class ConversationItemConverter extends EntityConverter<ConversationItem> {
  @override
  ConversationItem fromDocument(
    Document document,
    NitriteMapper nitriteMapper,
  ) {
    var entity = ConversationItem(
      id: document['id'] ?? "",
      title: document['title'] ?? "",
      history: EntityConverter.toList(document['history'], nitriteMapper),
      lastUpdated: document['lastUpdated'] ?? DateTime.now(),
    );
    return entity;
  }

  @override
  Document toDocument(ConversationItem entity, NitriteMapper nitriteMapper) {
    var document = emptyDocument();
    document.put('id', entity.id);
    document.put('title', entity.title);
    document.put(
      'history',
      EntityConverter.fromList(entity.history, nitriteMapper),
    );
    document.put('lastUpdated', entity.lastUpdated);
    return document;
  }
}

class ChatMessageConverter extends EntityConverter<ChatMessage> {
  @override
  ChatMessage fromDocument(Document document, NitriteMapper nitriteMapper) {
    var entity = ChatMessage(
      assistant: nitriteMapper.tryConvert<AssistantMessage, Document>(
        document['assistant'],
      )!,
      user: document['user'] ?? "",
    );
    return entity;
  }

  @override
  Document toDocument(ChatMessage entity, NitriteMapper nitriteMapper) {
    var document = emptyDocument();
    document.put(
      'assistant',
      nitriteMapper.tryConvert<Document, AssistantMessage>(entity.assistant),
    );
    document.put('user', entity.user);
    return document;
  }
}

class AssistantMessageConverter extends EntityConverter<AssistantMessage> {
  @override
  AssistantMessage fromDocument(
    Document document,
    NitriteMapper nitriteMapper,
  ) {
    var entity = AssistantMessage(
      isThinking: document['isThinking'] ?? false,
      text: document['text'] ?? "",
    );
    return entity;
  }

  @override
  Document toDocument(AssistantMessage entity, NitriteMapper nitriteMapper) {
    var document = emptyDocument();
    document.put('isThinking', entity.isThinking);
    document.put('text', entity.text);
    return document;
  }
}
