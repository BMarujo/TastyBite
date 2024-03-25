import 'package:flutter/material.dart';

class OrderLocationScreen extends StatelessWidget {
  const OrderLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: const Center(
        child: Text('Map Screen'),
      ),
    );
  }
}
