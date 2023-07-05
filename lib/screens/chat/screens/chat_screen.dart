import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_chat/utils/common/providers/current_user_provider.dart';
import '../../../models/user.dart' as app;
import '../../../utils/common/widgets/loader.dart';
import '../../../utils/constants/colors_constants.dart';
import '../../../utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';
import '../../auth/controllers/auth_controller.dart';
// import '../../call/controllers/call_controller.dart';
// import '../../call/screens/call_pickup_screen.dart';
import '../widgets/messages_list.dart';
import '../widgets/bottom_chat_text_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late Map<String, Object?> userData;

  approveRequest() {
    Navigator.pushNamed(
      context,
      AppRoutes.requestApprovalScreen,
      arguments: <String, Object>{
        StringsConsts.selectedMembers:
            userData[StringsConsts.selectedMembers] as List,
        StringsConsts.memberRequests:
            userData[StringsConsts.memberRequests] as List,
        StringsConsts.username: userData[StringsConsts.username] as String,
      },
    );
  }

  viewMembers() {
    Navigator.pushNamed(
      context,
      AppRoutes.requestApprovalScreen,
      arguments: <String, Object>{
        StringsConsts.selectedMembers:
            userData[StringsConsts.selectedMembers] as List,
        StringsConsts.username: userData[StringsConsts.username] as String,
        StringsConsts.groupAdmin: userData[StringsConsts.groupAdmin] as String,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object?>;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: userData[StringsConsts.isGroupChat] as bool
            ? _buildScaffoldWithTab()
            : _buildScaffold());
  }

  Widget _buildScaffoldWithTab() {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body:
            TabBarView(controller: DefaultTabController.of(context), children: [
          _buildBody(),
          _buildBody(true),
        ]),
        backgroundColor: AppColors.scaffoldBGChat,
        // ),
      ),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      backgroundColor: AppColors.scaffoldBGChat,
      // ),
    );
  }

  Widget _buildBody([isGroupPost = false]) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: MessagesList(
              receiverUsername: userData[StringsConsts.username] as String,
              isGroupChat: userData[StringsConsts.isGroupChat] as bool,
              isPostTab: isGroupPost,
              isAdmin: userData[StringsConsts.groupAdmin] == ref.read(currentUserProvider!).username,
            ),
          ),
          if (!isGroupPost ||
              ref.read(currentUserProvider!).username ==
                  userData[StringsConsts.groupAdmin])
            BottomChatTextField(
                receiverUsername: userData[StringsConsts.username] as String,
                isGroupChat: userData[StringsConsts.isGroupChat] as bool,
                isPostTab: isGroupPost),
          if (isGroupPost &&
              ref.read(currentUserProvider!).username !=
                  userData[StringsConsts.groupAdmin])
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Only admin can Post!",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.primary,
                      )),
            )
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      leadingWidth: 32.0,
      elevation: 1,
      shadowColor: AppColors.white,
      backgroundColor: AppColors.chatAppBar,
      iconTheme: Theme.of(context).iconTheme.copyWith(
            color: AppColors.primary,
          ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: userData[StringsConsts.profilePic] != null
                ? NetworkImage(userData[StringsConsts.profilePic] as String)
                : null,
            backgroundColor: AppColors.primary,
            child: userData[StringsConsts.profilePic] != null
                ? null
                : Icon(
                    userData[StringsConsts.isGroupChat] as bool
                        ? Icons.group
                        : Icons.person,
                    color: AppColors.white,
                    size: 20,
                  ),
          ),
          addHorizontalSpace(12.0),
          Expanded(
            child: (userData[StringsConsts.isGroupChat] as bool)
                ? Text(
                    userData[StringsConsts.username] as String,
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                              color: AppColors.lightBlack,
                              fontSize: 16.0,
                            ),
                  )
                : StreamBuilder<app.User>(
                    stream:
                        ref.watch(authControllerProvider).getReceiverUserData(
                              userData[StringsConsts.username] as String,
                            ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data!.username,
                              style: GoogleFonts.poppins(
                                color: AppColors.lightBlack,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              snapshot.data!.isOnline ? 'online' : 'offline',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Loader();
                      }
                    }),
          ),
        ],
      ),
      actions: userData[StringsConsts.isGroupChat] as bool
          // && userData[StringsConsts.groupAdmin] ==
          //             ref.read(currentUserProvider!).username
          ? [
              IconButton(
                onPressed: viewMembers,
                padding: const EdgeInsets.all(0.0),
                icon: const Icon(
                  Icons.group,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              if (userData[StringsConsts.groupAdmin] ==
                  ref.read(currentUserProvider!).username)
                IconButton(
                  onPressed: approveRequest,
                  padding: const EdgeInsets.all(0.0),
                  icon: const Icon(
                    size: 25,
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.primary,
                  ),
                ),
            ]
          : null,
      bottom: userData[StringsConsts.isGroupChat] as bool
          ? TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 4.0,
              labelColor: AppColors.black,
              // unselectedLabelColor: AppColors.uTabLabel,
              labelStyle: Theme.of(context).textTheme.headlineSmall,
              tabs: const [
                  Tab(
                    text: "Room",
                  ),
                  Tab(
                    text: "Posts",
                  )
                ])
          : null,
    );
  }
}
