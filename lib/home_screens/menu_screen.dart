import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/util/wallet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tastybite/services/local_notification_service.dart';
import 'package:tastybite/home_screens/order_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/services/locator_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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

final FirebaseAuth _auth = locator.get();

final Map<String, dynamic> orderData = {
  'user': 'John Doe',
  'deliveryman': 'Jane Doe',
  'name': 'GRELHADO',
  'time': '20 min',
  'orderTime': '2022/01/01 12:00',
};

class MenuScreen extends StatefulWidget {
  final MyUser user;

  const MenuScreen({super.key, required this.user});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // for location permission,...
  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }
  // for location permission,...

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
              Text('Preço: ${menuItem.price.toStringAsFixed(2)}€'),
              const Divider(),
              Text('Saldo atual: ${wallet.balance.toStringAsFixed(2)}€'),
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
              onPressed: () async {
                Navigator.pop(context);
                // Confirm purchase and deduct the amount from the wallet
                if (wallet.points >= 6) {
                  await _getCurrentPosition();
                  _showSuccessDialog2(menuItem.name, wallet, menuItem);
                } else {
                  if (menuItem.price > wallet.balance) {
                    _showUnsuccessDialog();
                  } else {
                    await _getCurrentPosition();
                    _showSuccessDialog(menuItem.name, wallet, menuItem);
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

  void _showSuccessDialog(String itemName, Wallet wallet, MenuItem menuItem) {
    // Store the context in a variable
    BuildContext dialogContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('A processar!'),
          content: const Text('Obrigado pela sua compra!'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                DocumentSnapshot<Map<String, dynamic>>? deliveryGuySnapshot =
                    await getAvailableDeliveryGuy();

                if (deliveryGuySnapshot != null) {
                  // Use the stored context variable here
                  showDialog(
                    context: dialogContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sucesso!'),
                        content: const Text('Você ganhou 1 ponto!'),
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
                  // Rest of your code
                  await wallet.withdraw(menuItem.price);
                  await wallet.addPoint(1);
                  DateTime now = DateTime.now();

                  String formattedDate =
                      DateFormat('EEE d MMM y\nkk:mm:ss', 'pt_PT').format(now);
                  widget.user.addHistory(
                      '${menuItem.name}\nData da compra:\n$formattedDate');
                  widget.user.addDate(formattedDate);
                  // Optionally, you can perform other actions here
                  // such as sending the order to the server
                  // or updating the cart state.
                  // Se um entregador estiver disponível, obtemos os detalhes do entregador
                  Map<String, dynamic> deliveryGuyData =
                      deliveryGuySnapshot.data()!;
                  String deliverymanName = deliveryGuyData['name'];

                  final User? user = _auth.currentUser;

                  if (user == null) {
                    print('Utilizador não autenticado.');
                    return;
                  }

                  final String name = await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user.uid)
                      .get()
                      .then((value) => value.data()!['name']);

                  // Adiciona um novo pedido à coleção 'orders' com o entregador atribuído
                  await FirebaseFirestore.instance.collection('orders').add({
                    'user': name,
                    'deliveryman': deliverymanName,
                    'name': itemName,
                    'time': 20,
                    'orderTime':
                        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    'deliveryAddress': _currentAddress,
                  });

                  // update orderData
                  orderData['user'] = name;
                  orderData['deliveryman'] = deliverymanName;
                  orderData['name'] = itemName;
                  orderData['time'] = 20;
                  orderData['orderTime'] =
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
                  orderData['deliveryAddress'] = _currentAddress;

                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(deliveryGuyData['uid'])
                      .set({'available': false}, SetOptions(merge: true));

                  // Mostra a notificação ao utilizador
                  await service.showNotificationWithPayload(
                    id: 0,
                    title: 'Tasty Bite',
                    body: 'Clica para ver o estado do Pedido!',
                    payload: itemName,
                  );
                } else {
                  showDialog(
                    context:
                        dialogContext, // Use the stored context variable here
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text(
                            'Nenhum entregador disponível no momento.'),
                        title: const Text('Insucesso'),
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
                  print('Nenhum entregador disponível no momento.');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog2(String itemName, Wallet wallet, MenuItem menuItem) {
    BuildContext dialogContext = context;
    showDialog(
      context: context,
      barrierDismissible:
          false, // Não permite fechar o diálogo clicando fora dele
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('A processar!'),
          content: const Text('Obrigado pela sua compra!'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Tenta obter o entregador disponível
                Navigator.pop(context);
                DocumentSnapshot<Map<String, dynamic>>? deliveryGuySnapshot =
                    await getAvailableDeliveryGuy();

                // Verifica se um entregador está disponível
                if (deliveryGuySnapshot != null) {
                  showDialog(
                    context: dialogContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sucesso!'),
                        content: const Text('Você usou os pontos!'),
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
                  // Se um entregador estiver disponível, obtemos os detalhes do entregador
                  await wallet.removePoints();
                  DateTime now = DateTime.now();
                  String formattedDate =
                      DateFormat('EEE d MMM y\nkk:mm:ss', 'pt_PT').format(now);
                  widget.user.addHistory(
                      '${menuItem.name}\nData da compra:\n$formattedDate');
                  widget.user.addDate(formattedDate);
                  // Optionally, you can perform other actions here
                  // such as sending the order to the server
                  // or updating the cart state.
                  Map<String, dynamic> deliveryGuyData =
                      deliveryGuySnapshot.data()!;
                  String deliverymanName = deliveryGuyData['name'];

                  final User? user = _auth.currentUser;

                  if (user == null) {
                    print('Utilizador não autenticado.');
                    return;
                  }

                  final String name = await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user.uid)
                      .get()
                      .then((value) => value.data()!['name']);

                  // Adiciona um novo pedido à coleção 'orders' com o entregador atribuído
                  await FirebaseFirestore.instance.collection('orders').add({
                    'user': name,
                    'deliveryman': deliverymanName,
                    'name': itemName,
                    'time': 20,
                    'orderTime':
                        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    'deliveryAddress': _currentAddress,
                  });

                  // update orderData
                  orderData['user'] = name;
                  orderData['deliveryman'] = deliverymanName;
                  orderData['name'] = itemName;
                  orderData['time'] = 20;
                  orderData['orderTime'] =
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
                  orderData['deliveryAddress'] = _currentAddress;

                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(deliveryGuyData['uid'])
                      .set({'available': false}, SetOptions(merge: true));

                  // Mostra a notificação ao utilizador
                  await service.showNotificationWithPayload(
                    id: 0,
                    title: 'Tasty Bite',
                    body: 'Clica para ver o estado do Pedido!',
                    payload: itemName,
                  );
                } else {
                  showDialog(
                    context: dialogContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text(
                            'Nenhum entregador disponível no momento.'),
                        title: const Text('Insucesso'),
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
                  // Se nenhum entregador estiver disponível, imprime uma mensagem ou executa outra lógica de tratamento
                  print('Nenhum entregador disponível no momento.');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showUnsuccessDialog() {
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

  void listenToNotification() =>
      service.onNotificationClick.stream.listen(onNotificationListener);

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('Payload: $payload');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderPage(orderData: orderData)));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?>
      getAvailableDeliveryGuy() async {
    try {
      // Referência para a coleção 'Users'
      CollectionReference<Map<String, dynamic>> usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Consulta para filtrar os usuários do tipo 'deliveryguy' e disponíveis
      Query<Map<String, dynamic>> query = usersCollection
          .where('type', isEqualTo: 'deliveryguy')
          .where('available', isEqualTo: true)
          .limit(1);

      // Obtém os documentos que satisfazem a consulta
      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      Map<String, dynamic> deliveryGuyData = snapshot.docs.first.data();
      // Verifica se há documentos retornados
      if (deliveryGuyData['available'] == true && snapshot.docs.isNotEmpty) {
        // Retorna o primeiro documento encontrado
        return snapshot.docs.first;
      } else {
        // Retorna null se nenhum entregador disponível for encontrado
        return null;
      }
    } catch (e) {
      // Lida com erros e retorna null em caso de falha
      print('Erro ao procurar entregador disponível: $e');
      return null;
    }
  }
}
