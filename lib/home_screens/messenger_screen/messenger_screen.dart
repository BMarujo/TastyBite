import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tastybite/services/locator_service.dart';
import 'package:tastybite/services/auth_service.dart';
import 'package:tastybite/services/chat_services.dart';
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
        title: const Text("Mensagens"),
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

        final List<Map<String, dynamic>> users =
            snapshot.data as List<Map<String, dynamic>>;
        final List<Map<String, dynamic>> deliveryGuys = [];
        final List<Map<String, dynamic>> clients = [];

        for (final userData in users) {
          if (userData['type'] == 'deliveryguy') {
            deliveryGuys.add(userData);
          } else if (userData['type'] == 'client') {
            clients.add(userData);
          }
        }

        return ListView(
          children: [
            if (deliveryGuys.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      'Entregadores',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...deliveryGuys.map<Widget>(
                      (userData) => BuildUserTile(userData: userData)),
                ],
              ),
            if (clients.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      'Clientes',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...clients.map<Widget>(
                      (userData) => BuildUserTile(userData: userData)),
                ],
              ),
          ],
        );
      },
    );
  }
}

class BuildUserTile extends StatelessWidget {
  const BuildUserTile({super.key, required this.userData});

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
