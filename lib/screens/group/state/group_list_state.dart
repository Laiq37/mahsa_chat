import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_groups/group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/models/group.dart';
import 'package:lets_chat/models/user.dart';
import '../controllers/group_controller.dart';
// import '../controllers/select__groups_controller.dart';

final groupListStateProvider = StateNotifierProvider.autoDispose.family<
    GroupListStateNotifier, GroupListState, BuildContext>(
  (ref, context) {
    return ref.watch(getGroupsControllerProvider(context)).when(
      data: (data) {
        return GroupListStateNotifier(
          groupList: [...data],
          state: const GetAllGroupListState([]),
        );
      },
      error: (error, stackTrace) {
        return GroupListStateNotifier(
          groupList: [],
          state: ErrorGroupListState(error.toString()),
        );
      },
      loading: () {
        return GroupListStateNotifier(
          groupList: [],
          state: const LoadingGroupListState(),
        );
      },
    );
  },
);

/// Base class for list states
@immutable
abstract class GroupListState extends Equatable {
  const GroupListState();
}

class GetAllGroupListState extends GroupListState {
  const GetAllGroupListState(this.groupList);

  final List<Group> groupList;

  @override
  List<Object?> get props => [groupList];

  @override
  bool? get stringify => true;
}

class SearchedGroupListState extends GroupListState {
  const SearchedGroupListState(this.searchedQueryList);

  final List<Group> searchedQueryList;

  @override
  List<Object?> get props => [searchedQueryList];

  @override
  bool? get stringify => true;
}

class ErrorGroupListState extends GroupListState {
  const ErrorGroupListState(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];

  @override
  bool? get stringify => true;
}

class LoadingGroupListState extends GroupListState {
  const LoadingGroupListState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

/// groups List State Notifier for notifying listeners.
class GroupListStateNotifier extends StateNotifier<GroupListState> {
  GroupListStateNotifier({
    required this.groupList,
    required GroupListState state,
  }) : super(state);

  final List<Group> groupList;

  void updateMemberReq(groupName, currentState, username, [String? query]){
    int index = groupList.indexWhere((group) => group.groupName == groupName);
    groupList[index].memberRequests!.add(username);
    groupList[index].isJoinRequested = true;
    if(currentState is GetAllGroupListState){
      state = GetAllGroupListState(groupList);
    }
    else if(currentState is SearchedGroupListState){
      getSearchedgroupsList(query!);
    }
  }

  void getSearchedgroupsList(String query) async {
    List<Group> filteredList = groupList
        .where((group) =>
              group.groupName.toLowerCase() == query.toLowerCase())
            // group.groupName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    state = SearchedGroupListState(filteredList);
  }
}
