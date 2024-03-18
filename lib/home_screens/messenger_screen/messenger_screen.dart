import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/auth_service/auth_service.dart';
import 'package:tastybite/chat_service/chat_services.dart';
import 'package:tastybite/home_screens/messenger_screen/chatpage.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.text, required this.onTap});
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(
              width: 20.0,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}

final ChatService _chatService = locator.get();
final AuthServices _authServices = locator.get();

class MessengerScreen extends StatelessWidget {
  const MessengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        title: const Text("HOME"),
        centerTitle: true,
      ),
      body: const BuildUserList(),
    );
  }
}

class BuildUserList extends StatelessWidget {
  const BuildUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getuserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20.0,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Loading",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SpinKitWanderingCubes(
                  color: Theme.of(context).colorScheme.primary,
                  size: 30.0,
                ),
              ],
            ),
          );
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) => BuilduserStreamList(
                  userData: userData,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class BuilduserStreamList extends StatelessWidget {
  const BuilduserStreamList({super.key, required this.userData});
  final Map<String, dynamic> userData;
  @override
  Widget build(BuildContext context) {
    if (userData['email'] != _authServices.getCurrentuser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverEmail: userData["email"],
                receiverId: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
