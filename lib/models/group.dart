class Group {
  Group({
    required this.groupAdmin,
    required this.groupName,
    // required this.groupId,
    required this.groupProfilePic,
    required this.lastMessage,
    required this.lastMessageUserSenderId,
    required this.time,
    required this.selectedMembersUIds,
    required this.memberRequests,
    this.isGroupJoined = true,
    this.isJoinRequested = false,
  });

  final String groupAdmin;
  final String groupName;
  // final String groupId;
  final String? groupProfilePic;
  final String lastMessage;
  final String lastMessageUserSenderId;
  final DateTime time;
  final List<String> selectedMembersUIds;
  final List memberRequests;
  bool isGroupJoined;
  bool isJoinRequested;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupAdmin': groupAdmin,
      'groupName': groupName,
      // 'groupId': groupId,
      'groupProfilePic': groupProfilePic,
      'lastMessage': lastMessage,
      'lastMessageUserSenderId': lastMessageUserSenderId,
      'time': time.millisecondsSinceEpoch,
      'selectedMembersUIds': selectedMembersUIds,
      'memberRequests': memberRequests ?? []
    };
  }

  factory Group.fromMap(Map<String, dynamic> map, [isJoined = true, isRequested = false]) {
    return Group(
      groupAdmin: map['groupAdmin'],
      groupName: map['groupName'] as String,
      // groupId: map['groupId'] as String,
      groupProfilePic: map['groupProfilePic'],
      lastMessage: map['lastMessage'] as String,
      lastMessageUserSenderId: map['lastMessageUserSenderId'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      selectedMembersUIds:
          List<String>.from(map['selectedMembersUIds'] as List,
          ),
      memberRequests: map['memberRequests'] ?? [],
      isGroupJoined: isJoined,
      isJoinRequested: isRequested
    );
  }
}
