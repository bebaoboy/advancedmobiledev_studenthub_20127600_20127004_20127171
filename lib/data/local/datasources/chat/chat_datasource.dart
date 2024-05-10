
import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/data/local/constants/db_constants.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/message.dart';
import 'package:sembast/sembast.dart';

class ChatDataSource {
  final _chatObjectStore =
      stringMapStoreFactory.store(DBConstants.CHAT_STORE_NAME);

  final _chatDataStore =
      stringMapStoreFactory.store(DBConstants.CHAT_DATA_STORE_NAME);

  // database instance
  final SembastClient _sembastClient;

  // Constructor
  ChatDataSource(this._sembastClient);

  // DB functions:--------------------------------------------------------------
  Future insert(WrapMessageList messageList, String currentId) async {
    if (currentId == messageList.chatUser.id) return;
    if (int.tryParse(messageList.chatUser.id) != null) {
      return await _chatObjectStore
          .record("${messageList.chatUser.id}${messageList.project!.objectId}")
          .put(_sembastClient.database, messageList.toJson(), merge: true);
    } else {
      return await _chatObjectStore.add(
          _sembastClient.database, messageList.toJson());
    }
  }

  Future insertOrReplaceChatContent(int projectId, int userId,
      List<Map<String, dynamic>> messageContents) async {
    try {
      final store = _chatDataStore;
      final key = "$projectId-$userId";

      final record = await store.record(key).get(_sembastClient.database);

      final allMessages = <String, List<Map<String, dynamic>>>{};
      if (record != null) {
        allMessages.addAll(record as Map<String, List<Map<String, dynamic>>>);
      }
      allMessages[key] = messageContents;

      await store.record(key).put(_sembastClient.database, allMessages);
    } catch (e) {
      print('Error while putting chat content: $e');
    }
  }

  // Future insertSingleMessage(int projectId, int userId) {
  // }

  Future<int> count() async {
    return await _chatObjectStore.count(_sembastClient.database);
  }

  Future<int> countCurrentChatContent(int projectId, int userId) async {
    final store = _chatDataStore;
    final key = "$projectId-$userId";

    try {
      final record = await store.record(key).get(_sembastClient.database);

      if (record != null) {
        final messages =
            List<Map<String, dynamic>>.from(record[key] as Iterable);
        return messages.length;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error while counting messages: $e');
      return -1;
    }
  }

  Future<List<WrapMessageList>> getListChatObjectFromDb() async {
    var list = List<WrapMessageList>.empty(growable: true);

    final recordSnapshots =
        await _chatObjectStore.find(_sembastClient.database);

    if (recordSnapshots.isNotEmpty) {
      list = recordSnapshots.map((snapshot) {
        final messageObject = WrapMessageList.fromJson(snapshot.value);
        return messageObject;
      }).toList();
    }

    return list;
  }

  Future<int> update(Project project) async {
    final finder = Finder(filter: Filter.byKey(project.objectId));
    return await _chatObjectStore.update(
      _sembastClient.database,
      project.toJson(),
      finder: finder,
    );
  }

  Future<int> delete(Project project) async {
    final finder = Finder(filter: Filter.byKey(int.parse(project.objectId!)));
    return await _chatObjectStore.delete(
      _sembastClient.database,
      finder: finder,
    );
  }

  Future deleteAll() async {
    await _chatObjectStore.drop(
      _sembastClient.database,
    );
  }

  Future deleteSingleContent(int projectId, int userId) async {
    final finder = Finder(filter: Filter.byKey(projectId + userId));
    return await _chatDataStore.delete(
      _sembastClient.database,
      finder: finder,
    );
  }

  Future<List<AbstractChatMessage>> getCurrentChatContent(
      int projectId, int userId) async {
    final store = _chatDataStore;
    final key = "$projectId-$userId";

    var list = List<AbstractChatMessage>.empty(growable: true);

    try {
      final recordSnapshot =
          await store.record(key).get(_sembastClient.database);

      if (recordSnapshot != null) {
        for (var r in recordSnapshot as Iterable) {
          final message = AbstractChatMessage.fromJson(r.value);
          list.add(message);
        }
      } else {
        return [];
      }
    } catch (e) {
      print('Error while getting chat content: $e');
      return [];
    }

    return list;
  }
}
