import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/group.dart';
import '../../../models/user.dart' as app;
// import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/common/providers/current_user_provider.dart';
import '../../../utils/common/repositories/firebase_storage_repository.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/string_constants.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(FirebaseFirestore.instance, ref);
});

class GroupRepository {
  GroupRepository(FirebaseFirestore firestore, ProviderRef ref)
      : _firestore = firestore,
        _ref = ref;
  final FirebaseFirestore _firestore;
  final ProviderRef _ref;

  /// invoke to Get all contacts (fully fetched)
  Future<List<Group>> getGroups(BuildContext context, Ref ref) async {
    List<Group> groupList = [];
    try {
      var groupData =
          await _firestore.collection(StringsConsts.groupsCollection).get();
      if (groupData.docs.isNotEmpty) {
        String username = ref.read(currentUserProvider!).username;
        groupList.addAll(groupData.docs.map((group) {
          bool isUserGroupMember =
              group.data()['selectedMembersUIds'].contains(username);
          bool isRequested = !isUserGroupMember &&
              group.data()['memberRequests'] != null &&
              group.data()['memberRequests'].contains(username);
          return Group.fromMap(
              group.data(),
              // group.data()['selectedMembersUIds'].contains(username),
              isUserGroupMember,
              isRequested);
        }));
      }
      // var currentUsername = ref.read(currentUserProvider!).username;
      // for (var userMap in usersData.docs) {
      //   try {
      //     if(isContactSame(currentUsername, userMap.data()['username']))continue;
      //     groupList.add(app.User.fromMap(userMap.data()));
      //   } catch (err) {
      //     print('user not valid');
      //   }
      // }
      // if (await FlutterContacts.requestPermission()) {
      //   groupList = await FlutterContacts.getContacts(
      //     withPhoto: true,
      //     withProperties: true,
      //   );
      // }
    } catch (e) {
      showSnackBar(context, content: e.toString());
    }

    return groupList;
  }

  Future getAllGroupsOfUser(String username)async{
    var userGroupData = await _firestore.collection(StringsConsts.groupsCollection).where("selectedMembersUIds",arrayContains: username).get();
    return userGroupData.docs;
  }

  Future<void> removeUserFromGroups()async{
    var user = _ref.read(currentUserProvider!);
    if(!user.isSecondaryLogin)return;
    var userGroupData = await getAllGroupsOfUser(user.username);
    if(userGroupData.isEmpty) return;
    List<Future> groups = [...userGroupData.map((groupData) {
      var group = Group.fromMap(groupData.data());
      return removeMember(group.groupName, group.selectedMembersUIds..removeWhere((member) => member == user.username));
    }).toList()];
    await Future.wait(groups);
  }

  Future<void> groupJoinReq(groupName, membersRequests) async {
    try {
      await _firestore
          .collection(StringsConsts.groupsCollection)
          .doc(groupName)
          .update({'memberRequests': membersRequests});
    } catch (e) {
      throw 'Failed to send request';
    }
  }

  Future<void> approveUserRequest(
      groupName, membersRequests, selectMembers) async {
    try {
      await _firestore
          .collection(StringsConsts.groupsCollection)
          .doc(groupName)
          .update({
        'memberRequests': membersRequests,
        'selectedMembersUIds': selectMembers
      });
    } on FirebaseException catch (_) {
      throw 'Something went wrong!';
    } catch (e) {
      throw 'Something went wrong!';
    }
  }

  Future<void> removeMember(groupName, selectMembers) async {
    try {
      await _firestore
          .collection(StringsConsts.groupsCollection)
          .doc(groupName)
          .update({'selectedMembersUIds': selectMembers});
    } on FirebaseException catch (_) {
      throw 'Something went wrong!';
    } catch (e) {
      throw 'Something went wrong!';
    }
  }

  Future<void> createGroup(
    bool mounted,
    BuildContext context, {
    required String currentUsername,
    required String groupName,
    required File? groupProfilePic,
    // required List<app.User> selectedContacts,
  }) async {
    try {
      // List<String> uIds = [];
      // String groupId = const Uuid().v1();

      // getting list of users from firestore
      // final querySnapshot =
      //     await _firestore.collection(StringsConsts.usersCollection).get();
      // loop to got (doc) snapshots from querySnapshots
      // for (var snapshot in querySnapshot.docs) {
      //   app.User user = app.User.fromMap(snapshot.data());

      // loop to compare selectedContacts number with firebase users
      // to check if the selected users exists in our app
      // for (var contact in selectedContacts) {
      //   String number;
      //   try {
      //     number = contact.phones[0].number.replaceAll(' ', '');
      //   } catch (e) {
      //     number = '+12345667';
      //   }

      //   if (user.phoneNumber == number) {
      //     uIds.add(user.uid);
      //   }
      // }
      // }

      // uploading our groupProfilePic to firebase storage and get url
      var groupData = await _firestore.collection(StringsConsts.groupsCollection).doc(groupName).get();
      if(groupData.data()!= null)throw "Group already exist";
      if (!mounted) return;
      String? groupProfilePicUrl;
      if (groupProfilePic != null) {
        groupProfilePicUrl = await _ref
            .read(firebaseStorageRepositoryProvider)
            .storeFileToFirebaseStorage(
              context,
              file: groupProfilePic,
              path: 'groups',
              fileName: groupName,
            );
      }

      // creating group instance
      final Group group = Group(
        groupAdmin: currentUsername,
        groupName: groupName,
        // groupId: groupId,
        groupProfilePic: groupProfilePicUrl,
        lastMessage: '',
        lastMessageUserSenderId: currentUsername,
        time: DateTime.now(),
        selectedMembersUIds: [currentUsername],
        memberRequests: [],
      );

      await _firestore
          .collection(StringsConsts.groupsCollection)
          .doc(groupName)
          .set(group.toMap());
    } catch (e) {
      showSnackBar(context, content: e.toString());
    }
  }
}
