import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/screens/group/controllers/group_controller.dart';
import 'package:lets_chat/utils/common/widgets/helper_widgets.dart';
import 'package:lets_chat/utils/constants/string_constants.dart';

import '../../../utils/common/providers/current_user_provider.dart';
import '../../../utils/constants/colors_constants.dart';

class RequestApprovalScreen extends ConsumerStatefulWidget {
  const RequestApprovalScreen({super.key});

  @override
  ConsumerState<RequestApprovalScreen> createState() =>
      _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends ConsumerState<RequestApprovalScreen> {
  late Map<String, dynamic> groupData;
  bool isDataInitialize = false;
  bool isRequestScreen = true;
  late final String currentUser;
  @override
  Widget build(BuildContext context) {
    if (!isDataInitialize) {
      groupData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      if (groupData[StringsConsts.memberRequests] == null) {
        isRequestScreen = false;
        currentUser = ref.read(currentUserProvider!).username;
      }
      isDataInitialize = true;
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme.copyWith(
            color: AppColors.onPrimary,
          ),
      title: Text(
        isRequestScreen ? 'Join Requests' : 'Group Members',
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: AppColors.onPrimary,
              fontSize: 18.0,
            ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _buildItem(
            groupData[isRequestScreen
                ? StringsConsts.memberRequests
                : StringsConsts.selectedMembers][index],
            index);
      },
      itemCount: groupData[isRequestScreen
              ? StringsConsts.memberRequests
              : StringsConsts.selectedMembers]
          .length,
    );
  }

  Widget _buildItem(member, index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          // onTap: () => selectContact(index, contact),
          title: Text(member),
          leading:
              //contact.photo == null
              //     ? null
              //     : CircleAvatar(
              //         backgroundImage: MemoryImage(contact.photo!),
              //       ),
              const CircleAvatar(
            backgroundImage: NetworkImage(
              r'https://images.pexels.com/photos/13728847/pexels-photo-13728847.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
            ),
          ),
          trailing: isRequestScreen
              ? _buildRequestTrailing(member, index)
              : 
              groupData[StringsConsts.groupAdmin] == currentUser
                  ?
                   _buildMemberRemovedButton(member, index)
                  : member == groupData[StringsConsts.groupAdmin]
                      ? Text('Admin',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: AppColors.black, fontSize: 12))
                      : null
                      ,
        ),
        const Divider(
          indent: 50.0,
          endIndent: 50.0,
          height: 1.0,
        ),
      ],
    );
  }

  _buildRequestTrailing(member, index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
            onPressed: () {
              var declineMember =
                  groupData[StringsConsts.memberRequests].removeAt(index);
              try {
                ref.read(groupControllerProvider).approveUserRequest(
                    groupData[StringsConsts.username],
                    groupData[StringsConsts.memberRequests],
                    groupData[StringsConsts.selectedMembers]);
                showSnackBar(context,
                    content: "$member request has been declined");
                setState(() {});
              } catch (e) {
                groupData[StringsConsts.memberRequests]
                    .insert(index, declineMember);
                showSnackBar(context, content: "Something went wrong!");
              }
            },
            child: Text(
              'Decline',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: AppColors.lightBlack, fontSize: 12),
            )),
        TextButton(
            onPressed: () {
              var approveMember =
                  groupData[StringsConsts.memberRequests].removeAt(index);
              groupData[StringsConsts.selectedMembers].add(approveMember);
              try {
                ref.read(groupControllerProvider).approveUserRequest(
                    groupData[StringsConsts.username],
                    groupData[StringsConsts.memberRequests],
                    groupData[StringsConsts.selectedMembers]);
                showSnackBar(context,
                    content: "$member request has been Accepted");
                setState(() {});
              } catch (e) {
                groupData[StringsConsts.memberRequests]
                    .insert(index, approveMember);
                groupData['selectedMemebers']
                    .removeWhere((mem) => mem == approveMember);
                showSnackBar(context, content: "Something went wrong!");
              }
            },
            child: Text(
              'Accept',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: AppColors.primary, fontSize: 12),
            ))
      ],
    );
  }

  _buildMemberRemovedButton(member, index) {
    return TextButton(
        onPressed: ref.read(currentUserProvider!).username == member
            ? null
            : () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Confirmation',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: AppColors.lightBlack),
                        ),
                        content:
                            Text('Are you sure to remove $member from group?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'No',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: AppColors.primary, fontSize: 14),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              var approveMember =
                                  groupData[StringsConsts.selectedMembers]
                                      .removeAt(index);
                              try {
                                ref.read(groupControllerProvider).removeMember(
                                    groupData[StringsConsts.username],
                                    groupData[StringsConsts.selectedMembers]);
                                showSnackBar(context,
                                    content: "$member has been removed");
                                setState(() {});
                              } catch (e) {
                                groupData[StringsConsts.selectedMembers]
                                    .insert(index, approveMember);
                                showSnackBar(context,
                                    content: "Something went wrong!");
                              }
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Remove',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: AppColors.primary, fontSize: 14),
                            ),
                          )
                        ],
                      );
                    });
              },
        child: Text(
          member == groupData[StringsConsts.groupAdmin] ? 'Admin' : 'Remove',
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: ref.read(currentUserProvider!).username == member
                  ? AppColors.black
                  : AppColors.primary,
              fontSize: 12),
        ));
  }
}
