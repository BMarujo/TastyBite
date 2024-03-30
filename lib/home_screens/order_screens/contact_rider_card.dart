import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/home_screens/messenger_screen/chatpage.dart';
import 'package:tastybite/services/locator_service.dart';

final FirebaseAuth _auth = locator.get();

class ContactRiderCard extends StatelessWidget {
  final String deliverymanName;
  const ContactRiderCard({
    super.key,
    required this.deliverymanName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(3),
      ),
      leading: Image.asset('assets/imgs/avatar.png'),
      title: Text('Contacte o $deliverymanName'),
      trailing: GestureDetector(
        onTap: () {
          fetchDeliverymanInfoAndNavigateToChat(context);
        },
        child: const Icon(
          Icons.message_outlined,
          size: 30,
          color: Colors.blue,
        ),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  // Função para buscar as informações do entregador e navegar para a tela de chat
  void fetchDeliverymanInfoAndNavigateToChat(BuildContext context) async {
    try {
      // Busca os dados do entregador
      Map<String, dynamic> deliverymanData =
          await getDeliverymanData(deliverymanName);
      // Navega para a tela de chat com os dados do entregador
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiverEmail: deliverymanData["email"],
            receiverId: deliverymanData["uid"],
          ),
        ),
      );
    } catch (e) {
      print('Erro ao buscar informações do entregador: $e');
      // Trate o erro conforme necessário
    }
  }

  // Função para buscar os dados do entregador
  Future<Map<String, dynamic>> getDeliverymanData(
      String deliverymanName) async {
    final QuerySnapshot<Map<String, dynamic>> deliverymanDataSnapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('name', isEqualTo: deliverymanName)
            .get();
    if (deliverymanDataSnapshot.docs.isNotEmpty) {
      return deliverymanDataSnapshot.docs.first.data();
    } else {
      throw Exception(
          'Nenhum entregador encontrado com o nome $deliverymanName');
    }
  }
}
