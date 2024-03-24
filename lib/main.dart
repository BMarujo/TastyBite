import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tastybite/firebase_options.dart';
import 'package:tastybite/splash.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/screens_builder.dart';
import 'package:tastybite/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initSerivceLocator();
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
                builder: (context) => LoginPage(),
              );
            case '/register':
              return MaterialPageRoute(
                builder: (context) => RegisterScreen(),
              );
          }
          return null;
        },
      ),
    );
  });
}
