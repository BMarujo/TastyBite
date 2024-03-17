import 'package:flutter/material.dart';
import 'package:tastybite/myuser.dart';

class MessengerScreen extends StatelessWidget {
  final MyUser user;
  const MessengerScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mensagens',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Colors.blue, // Set the app bar background color to blue
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.blue.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {},
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    Text(
                      'Remover',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              child: const ListTile(
                subtitle: Text(
                  'Data da Mensagem: ',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 17),
                ),
                title: Text(
                  "essageItem",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
