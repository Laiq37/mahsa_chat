import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_chat/utils/common/providers/current_user_provider.dart';
import 'package:lets_chat/utils/common/widgets/helper_widgets.dart';
import '../../../utils/constants/colors_constants.dart';
import '../../../utils/constants/routes_constants.dart';
import '../../../utils/constants/string_constants.dart';
import '../../group/screens/group_chats_screen.dart';
import '../../news/widget/news_widget.dart';
import '../../sender_info/controllers/sender_user_data_controller.dart';
import '../widgets/home_fab.dart';
import '../../../models/user.dart' as app;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final TabController _tabController;
  late final app.User currentUser;
  Timer? inActivityTimer;
  bool isUnActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    currentUser = ref.read(currentUserProvider!);
    ref
        .read(senderUserDataControllerProvider(currentUser.username))
        .setSenderUserState(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        inActivityTimer?.cancel();
        if (isUnActive) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Future.delayed(const Duration(milliseconds: 500), () => _logout());
          // currentUserProvider = null;
          return;
        }
        ref
            .watch(senderUserDataControllerProvider(currentUser.username))
            .setSenderUserState(true);
        break;
      case AppLifecycleState.inactive:
        inActivityTimer?.cancel();
        inActivityTimer = Timer(const Duration(seconds: 60), () {
          isUnActive = true;
        });
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (isUnActive) return;
        ref
            .watch(senderUserDataControllerProvider(currentUser.username))
            .setSenderUserState(false);
    }
  }

  _logout() async {
    try {
      ref
          .read(senderUserDataControllerProvider(currentUser.username))
          .setSenderUserState(false);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.loginScreen,
        );
      });
      currentUserProvider = null;
    } catch (err) {
      if (!mounted) return;
      showSnackBar(context, content: 'Something went wrong!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: TabBarView(
          controller: _tabController,
          children: const [
            // ChatsList(),
            GroupChatScreen(),
            NewsWidget(url: 'https://www.cnn.com/world/middleeast/iran'),
            NewsWidget(url: 'https://edition.cnn.com/'),
          ],
        ),
        floatingActionButton: HomeFAB(tabController: _tabController),
      ),
    );
  }

  /// AppBar of the home screen
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
      ),
      title: Text(
        StringsConsts.appName,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.white,
        indicatorWeight: 4.0,
        labelColor: AppColors.sTabLabel,
        unselectedLabelColor: AppColors.uTabLabel,
        labelStyle: Theme.of(context).textTheme.headlineSmall,
        tabs:  [
          // Tab(text: 'CHATS'), can uncomment if needed
          Tab(text: StringsConsts.groupsCollection.toUpperCase()),
          Tab(text: StringsConsts.news1.toUpperCase()),
          Tab(text: StringsConsts.news2.toUpperCase()),
        ],
      ),
    );
  }
}
