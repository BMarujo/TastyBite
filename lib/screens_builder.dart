import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tastybite/home_screens/messenger_screen/messenger_screen.dart';
import 'package:tastybite/splash.dart';
import 'package:tastybite/util/myuser.dart';
import 'package:tastybite/util/wallet.dart';
import 'package:provider/provider.dart';
import 'package:tastybite/home_screens/home_screen/home_screen.dart';
import 'package:tastybite/home_screens/menu_screen.dart';
import 'package:tastybite/home_screens/wallet_screen.dart';
import 'package:tastybite/home_screens/orders_status_screen.dart';
import 'package:tastybite/util/logout.dart';

class Helper extends StatelessWidget {
  final MyUser user;
  const Helper({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LogoutHelper(), child: ScreenBuilder(user: user));
  }
}

class ScreenBuilder extends StatelessWidget {
  final MyUser user;

  ScreenBuilder({super.key, required this.user});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 2);

  List<Widget> _buildScreens() {
    return [
      MenuScreen(user: user),
      const OrdersStatusScreen(),
      HomeScreen(user: user),
      const WalletScreen(),
      const MessengerScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.menu,
          size: 35,
          weight: 20,
        ),
        title: ("Menu"),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.delivery_dining,
          size: 35,
          weight: 20,
        ),
        title: ("Orders"),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.home,
          size: 35,
          weight: 20,
        ),
        title: ("Home"),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.account_balance_wallet,
          size: 35,
          weight: 20,
        ),
        title: ("Carteira"),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          Icons.message,
          size: 35,
          weight: 20,
        ),
        title: ("Mensagens"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    LogoutHelper logoutHelper = Provider.of<LogoutHelper>(context);
    if (logoutHelper.balance == 1) {
      return const SplashScreen();
    } else {
      return ChangeNotifierProvider(
          create: (context) => Wallet(),
          child: PersistentTabView(
            context,
            controller: _controller,
            screens: _buildScreens(),
            items: _navBarsItems(),
            navBarHeight: 70,
            confineInSafeArea: true,
            backgroundColor: Colors.white, // Default is Colors.white.
            handleAndroidBackButtonPress: true, // Default is true.
            resizeToAvoidBottomInset:
                true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
            stateManagement: true, // Default is true.
            hideNavigationBarWhenKeyboardShows:
                true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(0.0),
              colorBehindNavBar: Colors.white,
            ),
            popAllScreensOnTapOfSelectedTab: true,
            popActionScreens: PopActionScreensType.all,
            itemAnimationProperties: const ItemAnimationProperties(
              // Navigation Bar's items animation properties.
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: const ScreenTransitionAnimation(
              // Screen transition animation on change of selected tab.
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle: NavBarStyle
                .style1, // Choose the nav bar style with this property.
          ));
    }
  }
}
