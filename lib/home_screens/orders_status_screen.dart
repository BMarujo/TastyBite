import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/services/locator_service.dart';
import 'package:tastybite/home_screens/order_page.dart';
import 'package:tastybite/home_screens/rounded_container.dart';
import 'package:intl/intl.dart';
import 'dart:async';

final FirebaseAuth _auth = locator.get();

class OrdersStatusScreen extends StatefulWidget {
  const OrdersStatusScreen({super.key});

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
        title: const Text('Minhas Encomendas'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<String?>(
        future: getAtualUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('Erro ao carregar as encomendas: ${snapshot.error}'));
          } else {
            String? currentUserName = snapshot.data;
            if (currentUserName == null) {
              return const Center(
                  child: Text('Nome de utilizador não encontrado.'));
            }
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: userOrdersCollection
                  .where('user', isEqualTo: currentUserName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Erro ao carregar as encomendas: ${snapshot.error}'));
                } else {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      orderDocuments = snapshot.data!.docs;

                  if (orderDocuments.isEmpty) {
                    return const Center(child: Text('Não há encomendas.'));
                  } else {
                    orderDocuments.sort((a, b) {
                      String orderDescriptionA = calculateOrderStatus(
                          a['orderTime'], a['time'])['orderdescription'];
                      String orderDescriptionB = calculateOrderStatus(
                          b['orderTime'], b['time'])['orderdescription'];

                      if (orderDescriptionA == 'Expirado' &&
                          orderDescriptionB != 'Expirado') {
                        return 1;
                      } else if (orderDescriptionA != 'Expirado' &&
                          orderDescriptionB == 'Expirado') {
                        return -1;
                      } else {
                        int remainingTimeA = calculateOrderStatus(
                            a['orderTime'], a['time'])['remainingTime'];
                        int remainingTimeB = calculateOrderStatus(
                            b['orderTime'], b['time'])['remainingTime'];
                        return remainingTimeA.compareTo(remainingTimeB);
                      }
                    });
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
                                builder: (context) =>
                                    OrderPage(orderData: orderData),
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
                                      const Icon(Icons.delivery_dining_rounded,
                                          size: 60),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              calculateOrderStatus(
                                                      orderData['orderTime'],
                                                      orderData['time'])[
                                                  'orderdescription'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .apply(
                                                      color: Colors.blue,
                                                      fontWeightDelta: 1),
                                            ),
                                            Text(
                                                calculateOrderStatus(
                                                        orderData['orderTime'],
                                                        orderData['time'])[
                                                    'timestatus'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_right, size: 16),
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
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Encomenda',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium,
                                                  ),
                                                  Text('${orderData['name']}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium),
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
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tempo Estimado de Chegada',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium,
                                                  ),
                                                  Text(
                                                      DateFormat.Hm().format(DateTime
                                                              .now()
                                                          .add(Duration(
                                                              minutes: calculateOrderStatus(
                                                                      orderData[
                                                                          'orderTime'],
                                                                      orderData[
                                                                          'time'])[
                                                                  'remainingTime']))),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium),
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
    return null;
  } else {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      return userData.data()?['name'];
    } catch (e) {
      print('Erro ao buscar os dados do utilizador: $e');
      return null;
    }
  }
}

Map<String, dynamic> calculateOrderStatus(String orderTime, int estimatedTime) {
  DateTime now = DateTime.now();
  List<String> orderTimeParts = orderTime.split(' ');
  List<String> dateParts = orderTimeParts[0].split('/');
  List<String> timeParts = orderTimeParts[1].split(':');
  DateTime orderDateTime = DateTime(
    int.parse(dateParts[2]), // year
    int.parse(dateParts[1]), // month
    int.parse(dateParts[0]), // day
    int.parse(timeParts[0]), // hour
    int.parse(timeParts[1]), // minute
  );
  int elapsedMinutes = now.difference(orderDateTime).inMinutes;
  int remainingTime = estimatedTime - elapsedMinutes;

  String timestatus;
  String orderdescription;

  remainingTime = estimatedTime - elapsedMinutes;

  if (remainingTime <= 0) {
    timestatus = 'Expirado';
    orderdescription = 'Expirado';
  } else if (remainingTime <= 5) {
    timestatus = '1-5 min';
    orderdescription = 'Quase lá';
  } else if (remainingTime <= 10) {
    timestatus = '6-10 min';
    orderdescription = 'A caminho';
  } else if (remainingTime <= 15) {
    timestatus = '11-15 min';
    orderdescription = 'A caminho';
  } else if (remainingTime <= 19) {
    timestatus = '16-19 min';
    orderdescription = 'Processando';
  } else {
    timestatus = '$remainingTime min';
    orderdescription = 'Processando';
  }

  return {
    'timestatus': timestatus,
    'orderdescription': orderdescription,
    'remainingTime': remainingTime,
  };
}
