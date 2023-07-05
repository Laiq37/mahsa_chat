import 'dart:io';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/group.dart';
import '../../../utils/common/providers/current_user_provider.dart';
import '../repositories/group_repository.dart';
import '../../../models/user.dart' as app;

final groupControllerProvider = Provider.autoDispose<GroupController>(
  (ref) {
    return GroupController(
      groupRepository: ref.read(groupRepositoryProvider),
      ref: ref,
    );
  },
);

final getGroupsControllerProvider =
    FutureProvider.autoDispose.family<List<Group>, BuildContext>(
  (ref, context) {
    final selectReceiverContactsRepository =
        ref.watch(groupRepositoryProvider);
    return selectReceiverContactsRepository.getGroups(context, ref);
  },
);

final removeUserFromAllgroupProvider = FutureProvider.autoDispose<void>(
  (ref) async{
    final selectReceiverContactsRepository =
        ref.watch(groupRepositoryProvider);
    return await  selectReceiverContactsRepository.removeUserFromGroups();
  },
);

class GroupController {
  GroupController({
    required GroupRepository groupRepository,
    required ProviderRef ref,
  })  : _groupRepository = groupRepository,
        _ref = ref;

  final GroupRepository _groupRepository;
  final ProviderRef _ref;

  Future<void> createGroup(
    BuildContext context,
    bool mounted, {
    required String groupName,
    File? groupProfilePic,
    // required List<Contact> selectedContacts,
  }) async {
    app.User user = _ref.read(currentUserProvider!);
   await _groupRepository.createGroup(
      mounted,
      context,
      currentUsername: user.username,
      groupName: groupName,
      groupProfilePic: groupProfilePic,
      // selectedContacts: selectedContacts,
    );
  }

  Future<void> approveUserRequest(groupName, updateMembersRequest, selectMembers)async{
    await _groupRepository.approveUserRequest(groupName, updateMembersRequest, selectMembers);
  }

  Future<void> removeMember(groupName, selectMembers)async{
    await _groupRepository.removeMember(groupName, selectMembers);
  }

  Future<void> groupJoinReq(String groupName,List memberRequests)async{
    app.User user = _ref.read(currentUserProvider!);
    memberRequests.add(user.username);
    await _groupRepository.groupJoinReq(groupName, memberRequests);
  }
}
