import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../utils/common/enums/message_type.dart';
import '../../../utils/constants/colors_constants.dart';
import 'audio_player_item.dart';
import 'video_player_item.dart';

class DisplayMessage extends StatelessWidget {
  const DisplayMessage({
    super.key,
    required this.message,
    required this.messageType,
    required this.isSender,
    this.isReplying = false,
    this.isDisplayReply = false,
  });
  final String message;
  final MessageType messageType;
  final bool isSender;
  final bool isReplying;
  final bool isDisplayReply;

  @override
  Widget build(BuildContext context) {
    return getMessage(context);
  }

  Widget getMessage(BuildContext context) {
    switch (messageType) {
      case MessageType.text:
        return Text(
          textAlign: TextAlign.left,
          message,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSender ? AppColors.white : AppColors.black,
                fontSize: isDisplayReply ? 10 : null
              ),
        );
      case MessageType.image:
        return CachedNetworkImage(imageUrl: message, height:isReplying || isDisplayReply ? 75 : null, width: isReplying || isDisplayReply ? 75 : null,fit: BoxFit.cover,);
      case MessageType.audio:
        return AudioPlayerItem(audioUrl: message, isSender: isSender);
      case MessageType.gif:
        return CachedNetworkImage(imageUrl:  message, height:isReplying || isDisplayReply ? 75 : null, width: isReplying || isDisplayReply ? 75 : null,fit: BoxFit.cover,);
      case MessageType.video:
        return VideoPlayerItem(videoUrl: message);
      default:
        return Text(
          textAlign: TextAlign.left,
          message,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSender ? AppColors.white : AppColors.black,
                fontSize: isDisplayReply ? 10 : null
              ),
        );
    }
  }
}
