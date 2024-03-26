import 'package:flutter/material.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/auth_service/auth_service.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/login.dart';
import 'package:tastybite/screens_builder.dart';

enum AccountType { client, deliveryguy }

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
  const MyTextField({
    super.key,
    required this.hint,
    required this.obsecure,
    required this.controller,
    this.focusNode,
  });

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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final user = AuthServices(locator.get(), locator.get());
  late AccountType _selectedAccountType;

  @override
  void initState() {
    super.initState();
    _selectedAccountType = AccountType.client; // Default value
  }

  Future<void> signUp(String email, String password, String passwordConfirm,
      String nickname, context) async {
    MyUser user2 = MyUser(name: nickname);
    if (password == passwordConfirm) {
      try {
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        await user.signUp(email, password, nickname);
        Route route =
            MaterialPageRoute(builder: (context) => Helper(user: user2));
        Navigator.pushReplacement(context, route);
      } on Exception catch (ex) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(ex.toString()),
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Passwords don't match"),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();
    var pwConfirmController = TextEditingController();
    var nicknameController =
        TextEditingController(); // New controller for nickname
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 126, 178, 255),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                color: Theme.of(context).colorScheme.primary,
                size: 60,
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                "Let's create an account for you",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                hint: "Nickname", // New text field for nickname
                obsecure: false,
                controller: nicknameController,
              ),
              const SizedBox(
                height: 10,
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
                height: 10,
              ),
              MyTextField(
                hint: "Confirm Password",
                obsecure: true,
                controller: pwConfirmController,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButtonFormField<AccountType>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 25.0), // Adjust padding as needed
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 0, 0, 0), // Change the color to black
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  value: _selectedAccountType,
                  onChanged: (AccountType? newValue) {
                    setState(() {
                      _selectedAccountType = newValue!;
                    });
                  },
                  items: <AccountType>[
                    AccountType.client,
                    AccountType.deliveryguy,
                  ].map<DropdownMenuItem<AccountType>>((AccountType value) {
                    return DropdownMenuItem<AccountType>(
                      value: value,
                      child: Text(value == AccountType.client
                          ? 'Client'
                          : 'Delivery Guy'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              MyButton(
                text: "Register",
                onTap: () async {
                  await signUp(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      pwConfirmController.text.trim(),
                      nicknameController.text
                          .trim(), // Get nickname from text field
                      context);
                },
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Route route =
                          MaterialPageRoute(builder: (context) => LoginPage());
                      Navigator.pushReplacement(context, route);
                    },
                    child: Text(
                      "Login now",
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
      ),
    );
  }
}
