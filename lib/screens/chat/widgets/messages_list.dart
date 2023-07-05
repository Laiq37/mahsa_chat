import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lets_chat/utils/common/widgets/helper_widgets.dart';
import 'package:lets_chat/utils/constants/string_constants.dart';
import '../../../models/message.dart';
import '../../../utils/common/enums/message_type.dart';
import '../../../utils/common/enums/swipe_direction.dart';
import '../../../utils/common/providers/reply_message_provider.dart';
import '../../../utils/constants/colors_constants.dart';
import '../controllers/chat_controller.dart';
import '../../../utils/common/providers/current_user_provider.dart';
import '../../../utils/common/widgets/loader.dart';
import 'message_card.dart';

class MessagesList extends ConsumerStatefulWidget {
  const MessagesList({
    super.key,
    required this.receiverUsername,
    required this.isGroupChat,
    this.isPostTab = false,
    this.isAdmin = false,
  });

  final String receiverUsername;
  final bool isGroupChat;

  //this property only only indicating if we are on second tab of group chat or not(second Tab: Posts)
  //we will call stream api accordingly
  final bool isPostTab;

  final bool isAdmin;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessagesList> {
  late final ScrollController _messagesScrollController;
  String? previousMessageSender;

  @override
  void initState() {
    super.initState();
    _messagesScrollController = ScrollController();
  }

  @override
  void dispose() {
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: !widget.isGroupChat
          ? ref
              .watch(chatControllerProvider)
              .getMessagesList(receiverUsername: widget.receiverUsername)
          : widget.isGroupChat && widget.isPostTab
              ? ref
                  .watch(chatControllerProvider)
                  .getGroupPostsList(groupId: widget.receiverUsername)
              : ref
                  .watch(chatControllerProvider)
                  .getGroupMessagesList(groupId: widget.receiverUsername),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          return Center(
            child: Text(StringsConsts.err,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.lightBlack,
                    )),
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Center(
            child: Text(
                !widget.isPostTab
                    ? StringsConsts.startConv
                    : widget.isAdmin
                        ? StringsConsts.startPost
                        : StringsConsts.noPost,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.lightBlack,
                    )),
          );
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_messagesScrollController.position.atEdge) return;
          _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        });
        snapshot.data != [...snapshot.data!.reversed];
        return ListView.builder(
          reverse: true,
          controller: _messagesScrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Message message = snapshot.data![snapshot.data!.length - 1 - index];

            final bool isSenderUser = message.senderUsername ==
                ref.read(currentUserProvider!).username;

            // setting message seen for receiver
            if (!message.isSeen &&
                message.receiverUsername ==
                    ref.read(currentUserProvider!).username) {
              ref.read(chatControllerProvider).setChatMessageSeen(
                    context,
                    receiverUsername: widget.receiverUsername,
                    messageId: message.messageId,
                  );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //checking previous message sender and curr messagfe sender are not
                if (ref.read(currentUserProvider!).username !=
                        message.senderUsername &&
                    (snapshot.data!.length - index - 2 < 0 ||
                        snapshot.data![snapshot.data!.length - index - 2]
                                .senderUsername !=
                            message.senderUsername)) ...[
                  addVerticalSpace(8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(message.senderUsername,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppColors.primary, fontSize: 13)),
                  ),
                ],
                MessageCard(
                  isSender: isSenderUser ? true : false,
                  message: message.lastMessage,
                  messageType: message.messageType,
                  isSeen: message.isSeen,
                  time: DateFormat.Hm().format(message.time),
                  swipeDirection:
                      isSenderUser ? SwipeDirection.left : SwipeDirection.right,
                  repliedText: message.repliedMessage,
                  repliedMessageType: message.repliedMessageType,
                  username: message.repliedTo,
                  onSwipe: widget.isPostTab && !widget.isAdmin
                      ? null
                      : isSenderUser
                          ? () => _onSwipeMessage(
                                message: message.lastMessage,
                                isMe: true,
                                messageType: message.messageType,
                                isSender: true,
                              )
                          : () => _onSwipeMessage(
                                message: message.lastMessage,
                                isMe: false,
                                messageType: message.messageType,
                                isSender: false,
                              ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onSwipeMessage({
    required String message,
    required bool isMe,
    required MessageType messageType,
    required bool isSender,
  }) {
    ref.watch(replyMessageProvider.state).state = ReplyMessage(
      message: message,
      isMe: isMe,
      messageType: messageType,
      isSender: isSender,
    );
  }
}
