import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lets_chat/screens/group/controllers/group_controller.dart';
import 'package:lets_chat/utils/common/providers/current_user_provider.dart';
import '../../../models/group.dart';
import '../../../utils/common/widgets/loader.dart';
import '../../../utils/constants/colors_constants.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/widgets/no_chat.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  @override
  Widget build(BuildContext context) {
    return
        _buildBody();
  }

  Widget _buildBody() {
    return Consumer(
        builder: (context, ref, _) =>
            ref.watch(removeUserFromAllgroupProvider).when(
                data: (_) => StreamBuilder<List<Group>>(
                      stream:
                          ref.watch(chatControllerProvider).getGroupChatsList(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Loader();
                        }
                        return snapshot.data!.isEmpty
                            ? const NoChat()
                            : ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  Group group = snapshot.data![index];
                                  return _buildChatListItem(
                                      context, index, group);
                                },
                              );
                      },
                    ),
                error: ((error, stackTrace) => const Center(
                      child: Text('Something went wrong'),
                    )),
                loading: () => const Loader()));

  }

  Widget _buildChatListItem(BuildContext context, int index, Group group) {
    Size size = MediaQuery.of(context).size;

    return ListTile(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chatScreen,
        arguments: <String, Object?>{
          StringsConsts.username: group.groupName,
          StringsConsts.userId: group.groupName,
          StringsConsts.profilePic: group.groupProfilePic,
          StringsConsts.isGroupChat: true,
          // StringsConsts.isGroupAdmin:group.groupAdmin == ref.read(currentUserProvider!).username,
          StringsConsts.groupAdmin: group.groupAdmin,
          StringsConsts.selectedMembers: group.selectedMembersUIds,
          StringsConsts.memberRequests: group.memberRequests,
        },
      ),
      title: Text(
        group.groupName,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: size.width * 0.04,
            ),
      ),
      subtitle: Text(
        group.lastMessage,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: size.width * 0.035,
            ),
      ),
      leading: CircleAvatar(
        radius: size.width * 0.06,
        backgroundImage:group.groupProfilePic == null ? null : NetworkImage(
          group.groupProfilePic!,
              // 'https://images.pexels.com/photos/13728847/pexels-photo-13728847.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        ),
        backgroundColor: AppColors.primary,
        child: group.groupProfilePic != null ? null : Icon(Icons.group,color: AppColors.white,size: size.width * 0.06,),
      ),
      trailing: Text(
        DateFormat.Hm().format(group.time),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: size.width * 0.030,
            ),
      ),
    );
  }
}
