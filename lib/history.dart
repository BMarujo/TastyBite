import 'package:flutter/material.dart';
import 'user.dart';

class HistoryPage extends StatelessWidget {
  final User user;
  const HistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Colors.blue, // Set the app bar background color to blue
      ),
      body: ListView.builder(
        itemCount: user.getHistory.length,
        itemBuilder: (context, index) {
          String historyItem = user.getHistory[index];
          String dateItem = user.getDate[index];
          Key itemkey = Key(historyItem);
          return Card(
            color: Colors.blue.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Dismissible(
              key: itemkey,
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                user.removeHistory(historyItem);
                user.removeDate(dateItem);
              },
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
              child: ListTile(
                subtitle: Text(
                  'Data da Compra: $dateItem',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 17),
                ),
                title: Text(
                  historyItem,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 25),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
