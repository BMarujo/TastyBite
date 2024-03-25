import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:tastybite/auth_service/auth_service.dart';
import 'package:tastybite/chat_service/chat_services.dart';
import 'package:tastybite/home_screens/messenger_screen/chatpage.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';


class OrderLocationScreen extends StatelessWidget {
  const OrderLocationScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const OrderLocationScreenPage(title: 'Flutter Demo Home Page'),
    );
  }
}
class OrderLocationScreenPage extends StatefulWidget {
  const OrderLocationScreenPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<OrderLocationScreenPage> createState() => _OrderLocationScreenPageState();
}

class _OrderLocationScreenPageState extends State<OrderLocationScreenPage> {

  MapController mapController = MapController(
                            initMapWithUserPosition: true,
                            initPosition: GeoPoint(latitude: 14.599512, longitude: 120.984222),
                            areaLimit: const BoundingBox.world(),
                       );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
        title: const Text('Mapa de Encomendas'),
        backgroundColor:
            Colors.blue, // Set the app bar background color to blue
      ),

      body: Stack(
          children: <Widget>[
OSMFlutter( 
              controller: mapController,
              trackMyPosition: true,
              initZoom: 15,
              stepZoom: 1.0,
              userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                      icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.red,
                          size: 48,
                      ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                      icon: Icon(
                          Icons.double_arrow,
                          size: 48,
                      ),
                  ),
              ),
              roadConfiguration: RoadConfiguration(
                      startIcon: const MarkerIcon(
                        icon: Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.brown,
                        ),
                      ),
                      roadColor: Colors.yellowAccent,
              ),
              markerOption: MarkerOption(
                  defaultMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 56,
                        ),
                      )
              ),
          ) 
          ],
        ),


    );
  }
}