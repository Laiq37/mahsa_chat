import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'firebase_options.dart';
import 'router/router.dart';
import 'screens/auth/screens/login_screen.dart';
import 'utils/constants/string_constants.dart';
import 'utils/constants/theme_constants.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringsConsts.appName,
      theme: appTheme,
      home: _getHomeWidget(ref),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }

  Widget _getHomeWidget(WidgetRef ref) {
    return const LoginScreen();
  }
}
