import 'package:boilerplate/presentation/dashboard/chat/flutter_chat_types.dart';
import 'package:boilerplate/presentation/video_call/connectycube_sdk/lib/connectycube_sdk.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class MessageReaction {
  String userId;
  String messageId;
  String dialogId;
  String? addReaction;
  String? removeReaction;

  MessageReaction(this.userId, this.dialogId, this.messageId,
      {this.addReaction, this.removeReaction});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'message_id': messageId,
        'dialog_id': dialogId,
        'add': addReaction,
        'remove': removeReaction
      };

  @override
  String toString() => toJson().toString();
}

class CubeMessageReactions {
  Set<String> own = {};
  Map<String, int> total = {};

  CubeMessageReactions();

  CubeMessageReactions.fromJson(Map<String, dynamic> json) {
    own = List.of(json['own']).map((reaction) => reaction as String).toSet();
    total = Map.of(json['total'])
        .map((key, value) => MapEntry(key as String, value as int));
  }

  Map<String, dynamic> toJson() => {'own': own, 'total': total};

  @override
  toString() => toJson().toString();

  setOwn(own) {
    this.own = own;
  }

  setTotal(total) {
    this.total = total;
  }
}

// void onReactionReceived(CubeMessageReactions reaction) {
//   log("onReactionReceived message= ${reaction.messageId}");
//   _updateCubeMessageReactionss(reaction);
// }

getReactionsWidget(AbstractChatMessage message, String id,
    Function(Emoji emoji, AbstractChatMessage message) performReaction) {
  if (message.reactions == null) return Container();

  var isOwnMessage = message.author.id == id;

  return LayoutBuilder(builder: (context, constraints) {
    var widgetWidth = constraints.maxWidth == double.infinity
        ? 240
        : constraints.maxWidth * 0.5;
    var maxColumns = (widgetWidth / 60).round();
    if (message.reactions!.total.length < maxColumns) {
      maxColumns = message.reactions!.total.length;
    }

    return SizedBox(
        // duration: const Duration(milliseconds: 500),
        width: maxColumns * 56,
        child: GridView.count(
          primary: false,
          crossAxisCount: maxColumns,
          mainAxisSpacing: 4,
          childAspectRatio: 2,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 2),
          children: <Widget>[
            ...message.reactions!.total.keys.map((reaction) {
              return GestureDetector(
                  onTap: () => performReaction(Emoji(reaction, ''), message),
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: isOwnMessage ? 4 : 0,
                        right: isOwnMessage ? 0 : 4,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            color: message.reactions!.own.contains(reaction)
                                ? Colors.green
                                : Colors.grey,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(reaction,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontFamily: 'NotoColorEmoji',
                                        fontSize: 10)),
                                Text(
                                    ' ${message.reactions!.total[reaction].toString()}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ],
                            )),
                      )));
            })
          ],
        ));
  });
}

reactOnMessage(AbstractChatMessage message, context,
    Function(Emoji emoji, AbstractChatMessage message) performReaction) {
  showDialog<Emoji>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                width: 400,
                height: 400,
                child: EmojiPicker(
                  config: const Config(
                    emojiTextStyle: kIsWeb
                        ? TextStyle(
                            color: Colors.green, fontFamily: 'NotoColorEmoji')
                        : null,
                    categoryViewConfig: CategoryViewConfig(
                      initCategory: Category.SMILEYS,
                      backgroundColor: Colors.white,
                      indicatorColor: Colors.green,
                      iconColorSelected: Colors.green,
                    ),
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: Colors.white,
                      columns: 8,
                    ),
                    bottomActionBarConfig:
                        BottomActionBarConfig(enabled: false),
                  ),
                  onEmojiSelected: (category, emoji) {
                    Navigator.pop(context, emoji);
                  },
                )));
      }).then((emoji) {
    log("onEmojiSelected emoji: ${emoji?.emoji}");
    if (emoji != null) {
      performReaction(emoji, message);
    }
  });
}

// void performReaction(Emoji emoji, AbstractChatMessage message) {
//   if ((message.reactions?.own.isNotEmpty ?? false) &&
//       (message.reactions?.own.contains(emoji.emoji) ?? false)) {
//     // removeMessageReaction(message.id!, emoji.emoji);
//     // updateMessageReactions(CubeMessageReactions(
//     //     id!, _cubeDialog.dialogId!, message.messageId!,
//     //     removeReaction: emoji.emoji));
//   } else {
//     // addMessageReaction(message.messageId!, emoji.emoji);
//     // updateMessageReactions(CubeMessageReactions(
//     //     id!, _cubeDialog.dialogId!, message.messageId!,
//     //     addReaction: emoji.emoji));
//   }
// }
