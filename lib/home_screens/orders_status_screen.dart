import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/home_screens/order_page.dart';
import 'package:tastybite/home_screens/rounded_container.dart';
import 'package:intl/intl.dart';
import 'dart:async';

final FirebaseAuth _auth = locator.get();

class OrdersStatusScreen extends StatefulWidget {
  const OrdersStatusScreen({Key? key});

  @override
  _OrdersStatusScreenState createState() => _OrdersStatusScreenState();
}

class _OrdersStatusScreenState extends State<OrdersStatusScreen> {
  late Timer _timer;
  late String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _getCurrentUserName();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Atualizar a lista de pedidos a cada minuto
      setState(() {});
    });
  }

  Future<void> _getCurrentUserName() async {
    final String? currentUserName = await getAtualUserName();
    setState(() {
      _currentUserName = currentUserName;
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> userOrdersCollection =
        FirebaseFirestore.instance.collection('orders');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor:
            Colors.blue, // Set the app bar background color to blue
      ),
      body: FutureBuilder<String?>(
        future: getAtualUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar os pedidos: ${snapshot.error}'));
          } else {
            String? currentUserName = snapshot.data;
            if (currentUserName == null) {
              return Center(child: Text('Nome do usuário não encontrado.'));
            }
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: userOrdersCollection
                  .where('user', isEqualTo: currentUserName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Erro ao carregar os pedidos: ${snapshot.error}'));
                } else {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      orderDocuments = snapshot.data!.docs;
                  if (orderDocuments.isEmpty) {
                    return Center(child: Text('Não há pedidos.'));
                  } else {
                    return ListView.builder(
                      itemCount: orderDocuments.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> orderData =
                            orderDocuments[index].data();
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPage(orderData: orderData),
                              ),
                            );
                          },
                          child: ListTile(
                            subtitle: TRoundedContainer(
                              showBorder: true,
                              padding: const EdgeInsets.all(16),
                              backgroundColor: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.delivery_dining_rounded, size: 60),
                                      const SizedBox(width: 8),

                                      Expanded(
                                        child : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              calculateOrderStatus(orderData['orderTime'], orderData['time'])['orderdescription'],
                                              style: Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.blue, fontWeightDelta: 1), 
                                            ),
                                            Text(
                                              calculateOrderStatus(orderData['orderTime'], orderData['time'])['timestatus'],
                                              style: Theme.of(context).textTheme.headlineSmall),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_right, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.local_offer),
                                            const SizedBox(width: 8),
                                        
                                            Expanded(
                                              child : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Order', // Replace 'Your Text Here' with the desired text
                                                    style: Theme.of(context).textTheme.labelMedium, 
                                                  ),
                                                  Text('${orderData['name']}', style: Theme.of(context).textTheme.titleMedium),
                                        
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_month),
                                            const SizedBox(width: 8),
                                        
                                            Expanded(
                                              child : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Estimated Delivery', 
                                                    style: Theme.of(context).textTheme.labelMedium, 
                                                  ),
                                                  Text(
                                                    // access key remainingTime
                                                    DateFormat.Hm().format(DateTime.now().add(Duration(minutes: calculateOrderStatus(orderData['orderTime'], orderData['time'])['remainingTime']))),
                                                    style: Theme.of(context).textTheme.titleMedium),
                                        
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            
                            
                            /*
                            title: Text('Status: ${orderData['status']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Entregador: ${orderData['deliveryman']}'),
                                Text('Nome: ${orderData['name']}'),
                                Text('Tempo estimado: ${orderData['time']} min'),
                                Text('Hora do pedido: ${orderData['orderTime']}'),
                              ],
                            ),
                            */
                          ),
                        );
                      },
                    );
                  }
                }
              },
            );
          }
        },
      ),
    );
  }
}


Future<String?> getAtualUserName() async {
  final User? user = _auth.currentUser;

  if (user == null) {
    // Se o usuário não estiver autenticado, retorne null
    return null;
  } else {
    try {
      // Busca os dados do usuário na coleção 'Users' utilizando o UID do usuário atual
      final userData = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      // Retorna o nome do usuário
      return userData.data()?['name'];
    } catch (e) {
      // Se ocorrer algum erro durante a busca dos dados do usuário, imprime o erro e retorna null
      print('Erro ao buscar os dados do usuário: $e');
      return null;
    }
  }
}

Map<String, dynamic> calculateOrderStatus(String orderTime, int estimatedTime) {
  DateTime now = DateTime.now();
  List<String> orderTimeParts = orderTime.split(':');
  DateTime orderDateTime = DateTime(now.year, now.month, now.day, int.parse(orderTimeParts[0]), int.parse(orderTimeParts[1]));
  int elapsedMinutes = now.difference(orderDateTime).inMinutes;
  int remainingTime = estimatedTime - elapsedMinutes;

  String timestatus;
  String orderdescription;

  
  remainingTime = estimatedTime - elapsedMinutes;

  if (remainingTime <= 0) {
    // Se o tempo restante for negativo, a ordem está atrasada
    timestatus = 'Expired';
    orderdescription = 'Expired';
  } else if (remainingTime <= 5) {
    timestatus = '1-5 min';
    orderdescription = 'Almost ready';
  } else if (remainingTime <= 10) {
    timestatus = '6-10 min';
    orderdescription = 'On the way';
  } else if (remainingTime <= 15) {
    timestatus = '11-15 min';
    orderdescription = 'On the way';
  } else if (remainingTime <= 19) {
    timestatus = '16-19 min';
    orderdescription = 'Processing';
  } else {
    timestatus = remainingTime.toString() + ' min';
    orderdescription = 'Processing';
  }

  return {
    'timestatus': timestatus,
    'orderdescription': orderdescription,
    'remainingTime': remainingTime,
  };
}