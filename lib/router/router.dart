import 'package:flutter/widgets.dart';
import 'package:lets_chat/screens/auth/screens/login_screen.dart';
import 'package:lets_chat/screens/group/screens/request_approval_screen.dart';
import 'package:page_route_animator/page_route_animator.dart';
import '../screens/auth/screens/signup_screen.dart';
import '../screens/chat/screens/chat_screen.dart';
import '../screens/contact/screens/select_receiver_contact_screen.dart';
import '../screens/group/screens/create_group_screen.dart';
import '../screens/group/screens/group_chats_screen.dart';
import '../utils/common/screens/error_screen.dart';
import '../screens/home/screens/home_screen.dart';
import '../screens/sender_info/screens/sender_user_information_screen.dart';
import '../utils/constants/routes_constants.dart';

class AppRouter {
  static Route<PageRouteAnimator>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeScreen:
        return PageRouteAnimator(
          child: const HomeScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      case AppRoutes.loginScreen:
        return PageRouteAnimator(
          child: const LoginScreen(),
          routeAnimation: RouteAnimation.leftToRight,
          settings: settings,
        );
        case AppRoutes.signupScreen:
        return PageRouteAnimator(
          child: const SignupScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      case AppRoutes.userInformationScreen:
        return PageRouteAnimator(
          child: const SenderUserInformationScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      case AppRoutes.chatScreen:
        return PageRouteAnimator(
          child: const ChatScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      case AppRoutes.selectContactScreen:
        return PageRouteAnimator(
          child: const SelectReceiverContactScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      case AppRoutes.createGroupScreen:
        return PageRouteAnimator(
          child: const CreateGroupScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      case AppRoutes.groupChatsScreen:
        return PageRouteAnimator(
          child: const GroupChatScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
        case AppRoutes.requestApprovalScreen:
        return PageRouteAnimator(
          child: const RequestApprovalScreen(),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
      default:
        return PageRouteAnimator(
          child: ErrorScreen(error: settings.arguments as String),
          routeAnimation: RouteAnimation.rightToLeft,
          settings: settings,
        );
    }
  }
}
