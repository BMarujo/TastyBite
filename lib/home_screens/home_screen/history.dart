import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';

class HistoryPage extends StatelessWidget {
  final MyUser user;
  const HistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<String>>(
        future: user.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            List<String> history = snapshot.data ?? [];
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                String historyItem = history[index];
                return FutureBuilder<List<String>>(
                  future: user.getDate(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      );
                    } else {
                      List<String> dates = snapshot.data ?? [];
                      String dateItem = dates[index];
                      Key itemKey = Key(historyItem);
                      return Card(
                        color: Colors.blue.shade200,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Dismissible(
                          key: itemKey,
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
                            title: Text(
                              historyItem,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 25),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
