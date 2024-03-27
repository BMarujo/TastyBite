import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/util/wallet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tastybite/services/local_notification_service.dart';
import 'package:tastybite/home_screens/second_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final String description;
  final double price;
  final Image image;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });
}

class MenuScreen extends StatefulWidget {
  final MyUser user;

  MenuScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final List<MenuItem> menuItems = [
    MenuItem(
      name: 'GRELHADO',
      description:
          'Um hambúrguer de 200 gramas de pura carne, grelhado no ponto escolhido e servido num prato aquecido.',
      price: 12.99,
      image: Image.asset('assets/grelhado.jpg', height: 200, width: 300),
    ),
    MenuItem(
      name: 'COM MOLHO',
      description:
          'O primeiro é que usamos produtos frescos para o fazer e o segundo não revelamos porque faz parte, neste tipo de molhos, haver um segredo.',
      price: 14.99,
      image: Image.asset('assets/comMolho_crop.jpg', height: 200, width: 300),
    ),
    MenuItem(
      name: 'CHAMPIGNON',
      description:
          'Não gostamos de cogumelos em lata. E isto basta para que este molho seja feito apenas com cogumelos frescos.',
      price: 10.99,
      image: Image.asset('assets/champignon_crop.jpg', height: 200, width: 300),
    ),
    MenuItem(
      name: 'COM QUEIJO',
      description:
          'O queijo é um dos ingredientes mais importantes na cozinha. E é por isso que usamos um queijo de qualidade.',
      price: 16.99,
      image: Image.asset('assets/comQueijo_crop.jpg', height: 200, width: 300),
    ),
    MenuItem(
      name: 'MEDITERRÂNEO',
      description:
          'Rúcula, tomate seco, lascas de parmesão e molho de azeite virgem extra e limão. E é isto.',
      price: 13.39,
      image:
          Image.asset('assets/mediterraneo_crop.jpg', height: 200, width: 300),
    ),
    // Add more items as needed
  ];

  late final LocalNotificationServices service;

  @override
  void initState() {
    service = LocalNotificationServices();
    service.initialize();
    listenToNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Wallet wallet = Provider.of<Wallet>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratos Disponíveis'),
        backgroundColor:
            Colors.blue, // Set the app bar background color to blue
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            return _buildMenuItemCard(context, wallet, menuItems[index]);
          },
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(
      BuildContext context, Wallet wallet, MenuItem menuItem) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            title: Text(menuItem.name),
            subtitle: Text(menuItem.description),
          ),
          menuItem.image,
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(menuItem.price.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 20)),
                  const Icon(Icons.euro_symbol, size: 20),
                ]),
                ElevatedButton(
                  onPressed: () {
                    _showCheckoutDialog(context, wallet, menuItem);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 126, 188, 240),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    fixedSize: const Size(110, 45),
                  ),
                  child: const Text('Comprar', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(
      BuildContext context, Wallet wallet, MenuItem menuItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Compra'),
          contentPadding: const EdgeInsets.all(30.0),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Prato: ${menuItem.name}'),
              Text('Preço: \$${menuItem.price.toStringAsFixed(2)}'),
              const Divider(),
              Text('Saldo atual: \$${wallet.balance.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Confirm purchase and deduct the amount from the wallet
                if (wallet.points >= 6) {
                  wallet.removePoints();
                  widget.user.addHistory(menuItem.name);
                  DateTime now = DateTime.now();
                  String formattedDate =
                      DateFormat('EEE d MMM y\nkk:mm:ss', 'pt_PT').format(now);
                  widget.user.addDate(formattedDate);
                  // Optionally, you can perform other actions here
                  // such as sending the order to the server
                  // or updating the cart state.
                  Navigator.pop(context); // Close the dialog
                  _showSuccessDialog2(context, menuItem.name);
                } else {
                  if (menuItem.price > wallet.balance) {
                    Navigator.pop(context); // Close the dialog
                    _showUnsuccessDialog(context);
                  } else {
                    wallet.withdraw(menuItem.price);
                    wallet.addPoint();
                    widget.user.addHistory(menuItem.name);
                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('EEE d MMM y\nkk:mm:ss', 'pt_PT')
                            .format(now);
                    widget.user.addDate(formattedDate);
                    // Optionally, you can perform other actions here
                    // such as sending the order to the server
                    // or updating the cart state.
                    Navigator.pop(context); // Close the dialog
                    _showSuccessDialog(context, menuItem.name);
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(' Sucesso!'),
          content: const Text('Obrigado pela sua compra!'),
          actions: [
            ElevatedButton(
              onPressed: () async{
                print("Data: ${DateTime.now()}");
                // add item data to firestore colletion orders
                await FirebaseFirestore.instance.collection('orders').add({
                  'deliveryman': 'Delivery Guy',
                  'name': itemName,
                  'time': '20 min',
                  'orderTime': DateTime.now(),
                });

                Navigator.pop(context); // Close the dialog
                await service.showNotificationWithPayload(id: 0, title: 'Tasty Bite', body: 'Obrigado pela sua compra!', payload: itemName);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog2(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso!'),
          content: const Text('Você usou os seus pontos!'),
          actions: [
            ElevatedButton(
              onPressed: () async{
                Navigator.pop(context); // Close the dialog
                await service.showNotificationWithPayload(id: 0, title: 'Tasty Bite', body: 'Obrigado pela sua compra!', payload: itemName);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showUnsuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insucesso'),
          content: const Text(
              'Você não tem saldo suficiente para comprar este prato!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void listenToNotification() => service.onNotificationClick.stream.listen(onNotificationListener);

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('Payload: $payload');
      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(payload: payload)));
    }
  }
}
