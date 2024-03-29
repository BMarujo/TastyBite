import 'package:flutter/material.dart';

class DeliveryDetailsCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const DeliveryDetailsCard({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.blue, size: 28),
              SizedBox(width: 16),
              Text(
                'Detalhes da encomenda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${orderData['deliveryAddress']}\n',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Transform.flip(
                    flipX: true,
                    child: Text('\u275E', style: TextStyle(color: Colors.grey.shade800)),
                  ),
                ),
                const TextSpan(text: '  Por favor contacte-me antes de entregar a encomenda. Obrigado!'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: 'Entregador:'),
                TextSpan(
                  text: ' ${orderData['deliveryman']}',
                  style: TextStyle(
                    color: Colors.blueGrey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}