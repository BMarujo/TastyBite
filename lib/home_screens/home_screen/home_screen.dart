import 'package:flutter/material.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/home_screens/home_screen/history.dart';
import 'package:tastybite/util/wallet.dart';
import 'package:provider/provider.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/auth_service/auth_service.dart';
import 'package:tastybite/util/logout.dart';

class HomeScreen extends StatelessWidget {
  final MyUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Wallet wallet = Provider.of<Wallet>(context);

    LogoutHelper logoutHelper = Provider.of<LogoutHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, ${user.getname}!',
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
            ListTile(
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
            const SizedBox(height: 50),
            Image.asset('assets/qrcode.png', width: 200, height: 200),
            const SizedBox(height: 75),
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
            const SizedBox(height: 50),
            Text(
              'Os teus Pontos: ${wallet.points}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => HistoryPage(user: user));
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
