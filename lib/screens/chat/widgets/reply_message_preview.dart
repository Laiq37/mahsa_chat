import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/common/providers/reply_message_provider.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/colors_constants.dart';
import 'display_message.dart';

class ReplyMessagePreview extends ConsumerWidget {
  final String receiverUsername;
  const ReplyMessagePreview({required this.receiverUsername, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ReplyMessage? replyMessage = ref.read(replyMessageProvider);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2.0),
      padding: const EdgeInsets.all(8.0,),
      decoration: BoxDecoration(
        color: AppColors.grey[500],
        // replyMessage!.isMe ? AppColors.primary : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  replyMessage!.isMe ? 'You' : receiverUsername,
                  style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: replyMessage.isMe ? AppColors.lightBlack : null, fontSize: 11 ),
                ),
              ),
              GestureDetector(
                onTap: () => _cancelReply(ref),
                child: Icon(
                  Icons.close,
                  color: replyMessage.isMe ? AppColors.white : AppColors.black,
                  size: 20,
                ),
              )
            ],
          ),
          addVerticalSpace(4.0),
          DisplayMessage(
            isReplying: true,
            message: replyMessage.message,
            messageType: replyMessage.messageType,
            isSender: replyMessage.isMe,
          ),
        ],
      ),
    );
  }

  void _cancelReply(WidgetRef ref) {
    ref.read(replyMessageProvider.state).state = null;
  }
}
