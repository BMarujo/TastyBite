import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/home_screens/home_screen/history.dart';
import 'package:tastybite/util/wallet.dart';
import 'package:provider/provider.dart';
import 'package:tastybite/services/locator_service.dart';
import 'package:tastybite/services/auth_service.dart';
import 'package:tastybite/util/logout.dart';
import 'package:tastybite/util/image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = locator.get();
final FirebaseFirestore _firestore = locator.get();

class HomeScreen extends StatefulWidget {
  final MyUser user;
  const HomeScreen({super.key, required this.user});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Wallet>(context, listen: false).getPointsFromFirebase();
      Provider.of<Wallet>(context, listen: false).getBalanceFromFirebase();
    });
  }

  void onImageChanged(String newValue) {
    setState(() {
      imageUrl = newValue;
    });
  }

  Future<String> get_user_type() async {
    String x = "";
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('type')) {
        throw Exception('Type data not available');
      }
      x = data['type'];
      return x;
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error retrieving type: $e');
      return x;
    }
  }

  @override
  Widget build(BuildContext context) {
    Wallet wallet = Provider.of<Wallet>(context);
    LogoutHelper logoutHelper = Provider.of<LogoutHelper>(context);

    return FutureBuilder<String>(
      future: get_user_type(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is being resolved, show a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurs, handle it accordingly
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future has completed successfully
          String userType = snapshot.data!;
          if (userType == "deliveryguy") {
            // Render UI for delivery guy
            return _buildDeliveryGuyUI(wallet, logoutHelper);
          } else {
            // Render UI for other users
            return _buildRegularUserUI(wallet, logoutHelper);
          }
        }
      },
    );
  }

  Widget _buildDeliveryGuyUI(Wallet wallet, LogoutHelper logoutHelper) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, ${widget.user.getname}!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontFamily: 'Roboto',
          ),
          strutStyle: const StrutStyle(
            height: 3.5,
          ),
        ),
        backgroundColor: Colors.blue,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ImagePickerWidget(
                onValueChanged: onImageChanged,
                edit: "",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(const Size(290, 60)),
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 243, 224, 230)),
                ),
                onPressed: () async {
                  await _firestore
                      .collection('Users')
                      .doc(_auth.currentUser!.uid)
                      .set({'available': true}, SetOptions(merge: true));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          style: TextStyle(fontSize: 17),
                          'Estás disponível para entregas!'),
                    ),
                  );
                },
                child: const Text(
                    style: TextStyle(fontSize: 17),
                    'Estou disponível para entregas!'),
              ),
              const SizedBox(height: 20),
              ListTile(
                trailing: Icon(
                  size: 30,
                  Icons.person_off_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(style: TextStyle(fontSize: 25), "Logout"),
                leading: Icon(
                  size: 30,
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () async {
                  await AuthServices(_firestore, _auth)
                      .signOut(context, logoutHelper);
                },
              ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text(
                    '6 Pontos = Menu Grátis!',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.money_off,
                    size: 35,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Os teus Pontos: ${wallet.points}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Route route = MaterialPageRoute(
                      builder: (context) => HistoryPage(user: widget.user));
                  Navigator.push(context, route);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(290, 60),
                  elevation: 30,
                  shadowColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                child: const Text(
                    style: TextStyle(fontSize: 18), 'Ver Histórico de Compras'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularUserUI(Wallet wallet, LogoutHelper logoutHelper) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, ${widget.user.getname}!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontFamily: 'Roboto',
          ),
          strutStyle: const StrutStyle(
            height: 3.5,
          ),
        ),
        backgroundColor: Colors.blue,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ImagePickerWidget(
                onValueChanged: onImageChanged,
                edit: "",
              ),
              const SizedBox(height: 40),
              ListTile(
                trailing: Icon(
                  size: 30,
                  Icons.person_off_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(style: TextStyle(fontSize: 25), "Logout"),
                leading: Icon(
                  size: 30,
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () async {
                  await AuthServices(_firestore, _auth)
                      .signOut(context, logoutHelper);
                },
              ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text(
                    '6 Pontos = Menu Grátis!',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.money_off,
                    size: 35,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Os teus Pontos: ${wallet.points}',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Route route = MaterialPageRoute(
                      builder: (context) => HistoryPage(user: widget.user));
                  Navigator.push(context, route);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(290, 60),
                  elevation: 30,
                  shadowColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                child: const Text(
                    style: TextStyle(fontSize: 18), 'Ver Histórico de Compras'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
