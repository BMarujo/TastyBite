import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tastybite/firebase_options.dart';
import 'package:tastybite/splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tastybite/services/locator_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initSerivceLocator();
  initializeDateFormatting('pt_PT', null).then((_) {
    runApp(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
  });
}
