import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/home_screens/home_screen/history.dart';
import 'package:tastybite/util/wallet.dart';
import 'package:provider/provider.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/auth_service/auth_service.dart';
import 'package:tastybite/util/logout.dart';
import 'package:tastybite/util/image.dart';

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
  }

  void onValueChanged(String newValue) {
    setState(() {
      imageUrl = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    Wallet wallet = Provider.of<Wallet>(context);

    LogoutHelper logoutHelper = Provider.of<LogoutHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, ${widget.user.getname}!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            fontFamily: 'Roboto',
          ),
          strutStyle: const StrutStyle(
            height: 3.5,
          ),
        ),
        backgroundColor: Colors.blue,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImagePickerWidget(onValueChanged: onValueChanged, edit: ""),
            const SizedBox(height: 40),
            ListTile(
              trailing: Icon(
                Icons.person_off_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Logout"),
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () async {
                await AuthServices(locator.get(), locator.get())
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
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.money_off,
                  size: 50,
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
                elevation: 30,
                shadowColor: const Color.fromARGB(255, 0, 0, 0),
              ),
              child: const Text('Ver Histórico de Compras'),
            ),
          ],
        ),
      ),
    );
  }
}
