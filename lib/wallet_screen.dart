import 'package:flutter/material.dart';
import 'wallet.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController money = TextEditingController();
    Wallet wallet = Provider.of<Wallet>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Minha Carteira'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: const Color.fromARGB(255, 58, 121, 172),
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Saldo na Carteira:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 39,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              wallet.balance.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.euro_symbol,
                              size: 40,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                strutStyle: const StrutStyle(
                  fontSize: 20,
                  height: 2,
                ),
                controller: money,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: const InputDecoration(
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  labelText: 'Quantia a depositar',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(195, 23, 21, 139),
                      width: 3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 106, 75, 216),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                try {
                  wallet.deposit(
                      money.text.isEmpty ? 0 : double.parse(money.text));
                } catch (e) {
                  print(e);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 20,
                backgroundColor: const Color.fromARGB(255, 213, 238, 250),
                foregroundColor: Colors.black,
                fixedSize: const Size(150, 70),
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Depositar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
