import 'package:flutter/material.dart';

class ContactRiderCard extends StatelessWidget {
  final String deliverymanName;

  const ContactRiderCard({
    Key? key,
    required this.deliverymanName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(3),
      ),
      leading: Image.asset('assets/imgs/avatar.png'),
      title: Text('Contact $deliverymanName'),
      //subtitle: const Text('Add delivery instructions'),
      /*
      trailing: const Icon(
        Icons.message_outlined,
        size: 30,
        color: Colors.blue,
      ),
      */
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
}