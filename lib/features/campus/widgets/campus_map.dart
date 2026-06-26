import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mapa interativo do campus (OpenStreetMap, sem chave de API) com pino na
/// Av. Mutinga, 951. Tocar no botão abre o Google Maps.
class CampusMap extends StatelessWidget {
  const CampusMap({super.key});

  static const _lat = -23.4873375;
  static const _lng = -46.7360642;
  static const _point = LatLng(_lat, _lng);

  Future<void> _abrirMaps() async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(children: [
          FlutterMap(
            options: const MapOptions(initialCenter: _point, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.edu.ifsp.universe',
              ),
              const MarkerLayer(markers: [
                Marker(point: _point, width: 44, height: 44,
                    child: Icon(Icons.location_pin, size: 40, color: Color(0xFFD23B2E))),
              ]),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: ColoredBox(
                    color: Color(0xCCFFFFFF),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      child: Text('© OpenStreetMap', style: TextStyle(fontSize: 9, color: Color(0xFF333333))),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 10, bottom: 10,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _abrirMaps,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.open_in_new, size: 15, color: Color(0xFF00573A)),
                    SizedBox(width: 6),
                    Text('Abrir no Maps', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF00573A))),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
