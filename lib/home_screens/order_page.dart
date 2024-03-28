import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:tastybite/home_screens/menu_screen.dart';

import 'package:tastybite/home_screens/order_screens/delivery_details_card.dart';

import 'package:lottie/lottie.dart';

import 'package:tastybite/home_screens/order_screens/animated_step_bar.dart';
import 'package:tastybite/home_screens/order_screens/contact_rider_card.dart';

// Classe para armazenar o tempo restante e o passo atual da barra de progresso
class OrderStatus {
  final String timestatus;
  final int currentStep;
  final String orderdescription;
  

  OrderStatus(this.timestatus, this.currentStep, this.orderdescription);
}

class OrderPage extends StatelessWidget {
  const OrderPage({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  final Map<String, dynamic> orderData;

  @override
  Widget build(BuildContext context) {
    // Obter o tempo restante e o passo atual da barra de progresso
    final orderStatus = calculateOrderStatus(orderData['orderTime'], orderData['time']);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
          onPressed: () {
            // Navegar de volta para a tela anterior quando o ícone for pressionado
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Your Order',
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
                  'Estimated time of delivery',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  orderStatus.timestatus,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Lottie.asset('assets/lottie/delivery_girl_cycling.json', height: 160),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: AnimatedStepBar(
                    totalSteps: 4,
                    currentStep: orderStatus.currentStep,
                    height: 4,
                    padding: 3,
                    stepWidths: const [1, 3, 2, 2],
                    selectedColor: Colors.blue,
                    unselectedColor: Colors.grey.shade300,
                    roundedEdges: const Radius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  orderStatus.orderdescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                ContactRiderCard(deliverymanName: orderData['deliveryman']),
              ],
            ),
          ),
          DeliveryDetailsCard(orderData: orderData),
        ],
      ),
    );
  }

  // Função para calcular o tempo restante e o passo atual da barra de progresso
  OrderStatus calculateOrderStatus(String orderTime, int estimatedTime) {
    DateTime now = DateTime.now();
    List<String> orderTimeParts = orderTime.split(':');
    DateTime orderDateTime = DateTime(now.year, now.month, now.day, int.parse(orderTimeParts[0]), int.parse(orderTimeParts[1]));
    int elapsedMinutes = now.difference(orderDateTime).inMinutes;
    int remainingTime = estimatedTime - elapsedMinutes;
    String timestatus = 'min';
    String orderdescription = '';

    int currentStep;
    // Determinar o passo atual com base no tempo restante
    if (remainingTime <= 0) {
      orderdescription = 'Seu pedido foi entregue';
      timestatus = 'Pedido entregue';
      currentStep = 4; // Pedido entregue
    } else if (remainingTime <= 5) {
      orderdescription = 'O entregador está quase lá!';
      timestatus = '1-5 min';
      currentStep = 3; // Último passo
    } else if (remainingTime <= 10) {
      orderdescription = 'O entregador pegou seu pedido\n e está a caminho de você';
      timestatus = '6-10 min';
      currentStep = 2; // Penúltimo passo
    }else if(remainingTime <= 15){
      orderdescription = 'O entregador pegou seu pedido\n e está a caminho de você';
      timestatus = '11-15 min';
      currentStep = 2; // Segundo passo
    }else if(remainingTime <= 19){
      orderdescription = 'Nós conseguimos um entregador para você!\n Eles estão indo para o restaurante';
      timestatus = '16-19 min';
      currentStep = 1; // Primeiro passo
    } else {
      orderdescription = 'Nós conseguimos um entregador para você!\n Eles estão indo para o restaurante'; 
      timestatus = remainingTime.toString() + ' min';
      currentStep = 1; // Primeiro passo
    }

    return OrderStatus(timestatus, currentStep, orderdescription);
  }
}


