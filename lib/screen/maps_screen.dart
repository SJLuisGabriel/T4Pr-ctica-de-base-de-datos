import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => MapsScreenState();
}

class MapsScreenState extends State<MapsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.526363760640447, -100.8173053789328),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(20.536960429355872, -100.82646858979982),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: const InfoWindow(title: "Nuevo Lugar"),
        ),
      );
    });
  }

  // Función para ir a la ubicación de la "Joyería ITC"
  void _goToJoyeriaITC() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId("joyeriaITC"),
          position: const LatLng(20.536903, -100.826432),
          infoWindow: InfoWindow(
            title: 'Joyeria ITC',
            snippet: 'Lugar para surtir más plata',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text("Detalles de Joyeria ITC"),
                    content: Text(
                        "Aqui en nuestra sucursal podras ir a surtir mercancía de buena calidad"),
                  );
                },
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de Ubicaciones"),
      ),
      body: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: _addMarker,
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(right: 95),
        child: FloatingActionButton.extended(
          onPressed: _goToJoyeriaITC,
          label: const Padding(
            padding: EdgeInsets.fromLTRB(2, 8, 8, 8),
            child: Text('Joyeria ITC'),
          ),
          icon: const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 2, 8),
            child: Icon(Icons.diamond),
          ),
          extendedPadding: const EdgeInsets.all(6),
        ),
      ),
    );
  }
}
