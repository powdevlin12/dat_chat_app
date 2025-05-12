import 'package:dat_chat/colors.dart';
import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:dat_chat/features/landing/screens/landing_screen.dart';
import 'package:dat_chat/features/select_contacts/screens/select_contact_screen.dart';
import 'package:dat_chat/router.dart';
import 'package:dat_chat/screens/error_screen.dart';
import 'package:dat_chat/screens/loader.dart';
import 'package:dat_chat/screens/mobile_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: AppBarTheme(color: appBarColor)),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              if (user != null) {
                // return MobileLayoutScreen();
                return SelectContactScreen();
              }
              return LandingScreen();
            },
            error: (error, trace) {
              return ErrorScreen(
                error: error.toString(),
              );
            },
            loading: () => Loader(),
          ),
    );
  }
}
