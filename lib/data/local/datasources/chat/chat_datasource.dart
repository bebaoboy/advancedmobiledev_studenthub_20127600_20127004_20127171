import 'package:boilerplate/core/data/local/sembast/sembast_client.dart';
import 'package:boilerplate/data/local/constants/db_constants.dart';
import 'package:boilerplate/domain/entity/chat/chat_list.dart';
import 'package:boilerplate/domain/entity/project/entities.dart';
import 'package:boilerplate/domain/entity/project/project_entities.dart';
import 'package:boilerplate/presentation/dashboard/chat/type/message.dart';
import 'package:sembast/sembast.dart';

class ChatDataSource {
  final _chatObjectStore =
      intMapStoreFactory.store(DBConstants.CHAT_STORE_NAME);

  final _chatDataStore =
      intMapStoreFactory.store(DBConstants.CHAT_DATA_STORE_NAME);

  // database instance
  final SembastClient _sembastClient;

  // Constructor
  ChatDataSource(this._sembastClient);

  // DB functions:--------------------------------------------------------------
  Future insert(WrapMessageList messageList, String currentId) async {
    if (currentId == messageList.chatUser.id) return;
    if (int.tryParse(messageList.chatUser.id) != null) {
      return await _chatObjectStore
          .record(int.parse(messageList.chatUser.id))
          .put(_sembastClient.database, messageList.toJson());
    } else {
      return await _chatObjectStore.add(
          _sembastClient.database, messageList.toJson());
    }
  }

  Future insertOrReplaceChatContent(int projectId, int userId,
      List<AbstractChatMessage> messageContents) async {
    for (var element in messageContents) {
      try {
        _chatDataStore
            .record(projectId + userId)
            .put(_sembastClient.database, element.toJson());
      } catch (e) {
        // Handle errors here
        print('Error while putting chat content: $e');
      }
    }
  }

  // Future insertSingleMessage(int projectId, int userId) {
  // }

  Future<int> count() async {
    return await _chatObjectStore.count(_sembastClient.database);
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
    var filter =
        Filter.equals(DBConstants.CHAT_CONTENT_FIELD_ID, projectId + userId);
    var list = List<AbstractChatMessage>.empty(growable: true);

    final recordSnapshots = await _chatDataStore.find(_sembastClient.database,
        finder: Finder(filter: filter));

    if (recordSnapshots.isNotEmpty) {
      list = recordSnapshots.map((snapshot) {
        final message = AbstractChatMessage.fromJson(snapshot.value);
        return message;
      }).toList();
    }

    return Future.value(list);
  }
}
