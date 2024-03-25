import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/auth_service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/register_screen.dart';
import 'package:tastybite/screens_builder.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.text, required this.onTap});
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25.0),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField(
      {super.key,
      required this.hint,
      required this.obsecure,
      required this.controller,
      this.focusNode});
  final String hint;
  final bool obsecure;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        cursorColor: Colors.black,
        focusNode: focusNode,
        controller: controller,
        obscureText: obsecure,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final FirebaseAuth user = locator.get();

  Future<void> signIn(
      String email, String password, String name, context) async {
    final authUser = AuthServices(locator.get(), locator.get());

    MyUser user2 = MyUser(name: name);

    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      await authUser.signIn(email, password);
      Route route =
          MaterialPageRoute(builder: (context) => ScreenBuilder(user: user2));
      Navigator.pushReplacement(context, route);
    } on Exception catch (ex) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(ex.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 126, 178, 255),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: TextFormField(
                controller: name,
                strutStyle: const StrutStyle(
                  fontSize: 20,
                  height: 2,
                ),
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20,
                ),
                decoration: const InputDecoration(
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                  ),
                  labelText: 'Nome',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 187, 231, 161),
                      width: 3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 187, 231, 161),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 187, 231, 161),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                fixedSize: const Size(200, 70),
              ),
              onPressed: () {
                if (name.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Introduza o seu nome'),
                    ),
                  );
                } else {
                  MyUser user2 = MyUser(name: name.text);
                  Route route = MaterialPageRoute(
                      builder: (context) => ScreenBuilder(user: user2));
                  Navigator.pushReplacement(context, route);
                }
              },
              child: const Text(
                'Entrar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(
              Icons.message,
              color: Theme.of(context).colorScheme.primary,
              size: 60,
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Welcome back, You've been missed",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MyTextField(
              hint: "Email",
              obsecure: false,
              controller: emailController,
            ),
            const SizedBox(
              height: 10,
            ),
            MyTextField(
              hint: "Password",
              obsecure: true,
              controller: passwordController,
            ),
            const SizedBox(
              height: 25,
            ),
            MyButton(
              text: "Login",
              onTap: () async {
                await signIn(emailController.text.trim(),
                    passwordController.text.trim(), name.text, context);
              },
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Route route = MaterialPageRoute(
                        builder: (context) => RegisterScreen());
                    Navigator.pushReplacement(context, route);
                  },
                  child: Text(
                    "Register now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
