import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:tastybite/home_screens/order_screens/delivery_details_card.dart';

import 'package:lottie/lottie.dart';

import 'package:tastybite/home_screens/order_screens/animated_step_bar.dart';
import 'package:tastybite/home_screens/order_screens/contact_rider_card.dart';
import 'dart:async';

class OrderStatus {
  final String timestatus;
  final int currentStep;
  final String orderdescription;

  OrderStatus(this.timestatus, this.currentStep, this.orderdescription);
}

class OrderPage extends StatefulWidget {
  const OrderPage({
    super.key,
    required this.orderData,
  });

  final Map<String, dynamic> orderData;

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Timer _timer;
  late OrderStatus _orderStatus;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _calculateOrderStatus();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateOrderStatus();
      setState(() {});
    });
  }

  void _calculateOrderStatus() {
    setState(() {
      _orderStatus = calculateOrderStatus(
          widget.orderData['orderTime'], widget.orderData['time']);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'A Tua Encomenda',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Tempo Estimado de Entrega',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _orderStatus.timestatus,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Lottie.asset('assets/lottie/delivery_girl_cycling.json',
                    height: 160),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: AnimatedStepBar(
                    totalSteps: 6,
                    currentStep: _orderStatus.currentStep,
                    height: 4,
                    padding: 3,
                    stepWidths: const [1, 1, 2, 2, 1, 1],
                    selectedColor: Colors.blue,
                    unselectedColor: Colors.grey.shade300,
                    roundedEdges: const Radius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _orderStatus.orderdescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                ContactRiderCard(deliverymanName: widget.orderData['deliveryman']),
              ],
            ),
          ),
          DeliveryDetailsCard(orderData: widget.orderData),
        ],
      ),
    );
  }

  OrderStatus calculateOrderStatus(String orderTime, int estimatedTime) {
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
    String timestatus = 'min';
    String orderdescription = '';

    int currentStep;

    // Determinar o passo atual com base no tempo restante
    if (remainingTime <= 0) {
      orderdescription = 'Seu pedido foi entregue';
      timestatus = 'Pedido entregue';
      currentStep = 6; 
    } else if (remainingTime <= 5) {
      orderdescription = 'O entregador está quase lá!';
      timestatus = '1-5 min';
      currentStep = 5; 
    } else if (remainingTime <= 10) {
      orderdescription =
          'O entregador já tem o seu pedido\n e está a caminho de você';
      timestatus = '6-10 min';
      currentStep = 4; 
    } else if (remainingTime <= 15) {
      orderdescription =
          'O entregador já tem o seu pedido\n e está a caminho de você';
      timestatus = '11-15 min';
      currentStep = 3; 
    } else if (remainingTime <= 19) {
      orderdescription =
          'Foi encontrado um entregador para você!\n Ele já está a caminho do restaurante';
      timestatus = '16-19 min';
      currentStep = 2; 
    } else {
      orderdescription =
          'Foi encontrado um entregador para você!\n Ele já está a caminho do restaurante';
      timestatus = '$remainingTime min';
      currentStep = 1; 
    }

    return OrderStatus(timestatus, currentStep, orderdescription);
  }
}
