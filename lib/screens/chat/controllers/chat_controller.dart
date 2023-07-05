import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chat.dart';
import '../../../models/group.dart';
import '../../../models/message.dart';
import '../../../models/user.dart' as app;
import '../../../utils/common/enums/message_type.dart';
import '../../../utils/common/providers/current_user_provider.dart';
import '../../../utils/common/providers/reply_message_provider.dart';
import '../../../utils/constants/string_constants.dart';
import '../repositories/chat_repository.dart';

final chatControllerProvider = Provider<ChatController>(
  (ref) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return ChatController(chatRepository: chatRepository, ref: ref);
  },
);

class ChatController {
  ChatController({
    required ChatRepository chatRepository,
    required ProviderRef ref,
  })  : _chatRepository = chatRepository,
        _ref = ref;

  final ChatRepository _chatRepository;
  final ProviderRef _ref;

  Future<void> sendTextMessage(BuildContext context,
      {required String lastMessage,
      required String receiverUsername,
      required String? groupId,
      required bool isGroupChat,
      bool isPostTab = false}) async {
    ReplyMessage? replyMessage = _ref.watch(replyMessageProvider);
    app.User senderUser = _ref.watch(currentUserProvider!);

    _chatRepository.sendTextMessage(context,
        lastMessage: lastMessage,
        receiverUsername: receiverUsername,
        senderUser: senderUser,
        replyMessage: replyMessage,
        groupId: groupId,
        isGroupChat: isGroupChat,
        isPostTab: isPostTab);

    _ref.watch(replyMessageProvider.state).state = null;
  }

  Future<void> sendGIFMessage(BuildContext context,
      {required String gifUrl,
      required String receiverUsername,
      required String? groupId,
      required bool isGroupChat,
      bool isPostTab = false}) async {
    ReplyMessage? replyMessage = _ref.watch(replyMessageProvider);
    app.User senderUser = _ref.watch(currentUserProvider!);

    _chatRepository.sendGIGMessage(context,
        gifUrl: _getGifUrl(gifUrl),
        receiverUsername: receiverUsername,
        senderUser: senderUser,
        replyMessage: replyMessage,
        groupId: groupId,
        isGroupChat: isGroupChat,
        isPostTab: isPostTab);

    _ref.watch(replyMessageProvider.state).state = null;
  }

  Future<void> sendFileMessage(bool mounted, BuildContext context,
      {required File file,
      required String receiverUsername,
      required MessageType messageType,
      required String? groupId,
      required bool isGroupChat,
      bool isPostTab = false}) async {
    ReplyMessage? replyMessage = _ref.watch(replyMessageProvider);
    app.User senderUser = _ref.watch(currentUserProvider!);

    _chatRepository.sendFileMessage(mounted, context,
        file: file,
        receiverUsername: receiverUsername,
        senderUser: senderUser,
        messageType: messageType,
        ref: _ref,
        replyMessage: replyMessage,
        groupId: groupId,
        isGroupChat: isGroupChat,
        isPostTab: isPostTab);

    _ref.watch(replyMessageProvider.state).state = null;
  }

  Stream<List<Chat>> getChatsList() {
    app.User senderUser = _ref.watch(currentUserProvider!);
    return _chatRepository.getChatsList(senderUsername: senderUser.username);
  }

  Stream<List<Group>> getGroupChatsList() {
    app.User senderUser = _ref.watch(currentUserProvider!);
    return _chatRepository.getGroupChatsList(
        currentUsername: senderUser.username);
  }

  /// invoke to get single chat (messages)
  Stream<List<Message>> getMessagesList({required receiverUsername}) {
    app.User senderUser = _ref.watch(currentUserProvider!);
    return _chatRepository.getMessagesList(
      senderUsername: senderUser.username,
      receiverUsername: receiverUsername,
    );
  }

  /// invoke to get single group chat (messages)
  Stream<List<Message>> getGroupMessagesList({
    required String groupId,
  }) {
    return _chatRepository.getGroupMessagesList(groupId: groupId);
  }

  Stream<List<Message>> getGroupPostsList({
    required String groupId,
  }) {
    return _chatRepository.getGroupPostsList(groupId: groupId);
  }

  Future<void> setChatMessageSeen(
    BuildContext context, {
    required String receiverUsername,
    required String messageId,
  }) async {
    app.User user = _ref.watch(currentUserProvider!);
    _chatRepository.setChatMessageSeen(
      context,
      receiverUsername: receiverUsername,
      senderUsername: user.username,
      messageId: messageId,
    );
  }

  String _getGifUrl(String gifUrl) {
    String midUrl = gifUrl.substring(gifUrl.lastIndexOf('-') + 1);
    return '${StringsConsts.staticGiphyUrlStart}$midUrl${StringsConsts.staticGiphyUrlEnd}';
  }
}
