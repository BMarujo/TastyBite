import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tastybite/firebase_options.dart';
import 'package:tastybite/splash.dart';
import 'package:tastybite/myuser.dart';
import 'package:tastybite/screens_builder.dart';
import 'package:tastybite/login.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeDateFormatting('pt_PT', null).then((_) {
    runApp(
      MaterialApp(
        home: const SplashScreen(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/home':
              MyUser user = settings.arguments as MyUser;
              return MaterialPageRoute(
                  builder: (context) => ScreenBuilder(user: user));
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
              );
          }
          return null;
        },
      ),
    );
  });
}
