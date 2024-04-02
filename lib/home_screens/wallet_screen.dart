import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/services/locator_service.dart';
import 'package:tastybite/util/wallet.dart';

final FirebaseAuth _auth = locator.get();
final FirebaseFirestore _firestore = locator.get();

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
      body: SingleChildScrollView(
        child: Container(
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
                      const Text(
                        'Saldo na Carteira:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 49,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('Users')
                            .doc(_auth.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;

                          if (data == null) {
                            // Document doesn't exist, handle accordingly
                            return const Text(
                              'Balance not available',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }

                          final balance = data["balance"] ?? 0.0;
                          return Text(
                            balance.toStringAsFixed(2) + '€',
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
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
                    fontSize: 30,
                    height: 2,
                  ),
                  controller: money,
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(
                      fontSize: 30,
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
                  fixedSize: const Size(180, 100),
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Depositar',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
