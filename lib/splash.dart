import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tastybite/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> opacity;
  late AnimationController controller;
  late SharedPreferences prefs;
  bool loggedIn = false;

  @override
  void initState() {
    initialize();
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      changePage();
    });
  }

  Future initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void changePage() {
    Route route = MaterialPageRoute(builder: (context) => LoginPage());
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(155, 165, 179, 241)),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(155, 182, 191, 231),
          body: Column(
            children: [
              Expanded(
                child: Opacity(
                  opacity: opacity.value,
                  child: Image.asset('assets/h3.jpg'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
