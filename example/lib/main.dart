import 'package:flutter/material.dart';

import 'package:longdo_maps_flutter/longdo_maps_flutter.dart';
import 'package:map_example/base.dart';
import 'package:map_example/layer.dart';
import 'package:map_example/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements MapInterface {
  // STEP 1 : Get a Key API
  // https://map.longdo.com/docs/javascript/getting-started
  static const API_KEY = "YOUR_KEY_API";

  MapController map;
  List<Marker> markers = [];
  final global = GlobalKey<ScaffoldState>();
  bool thaiChote = false;
  bool traffic = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.DATA,
        home: Scaffold(
          key: global,
          appBar: AppBar(
              title: Row(
                children: <Widget>[Text("Longdo Map Plugin")],
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.map),
                    onPressed: () async {
                      final String base = await Navigator.push(
                        global.currentState.context,
                        MaterialPageRoute(builder: (_) => Base()),
                      );
                      if (base != null) {
                        map?.base(name: base);
                      }
                    }),
                IconButton(
                    icon: Icon(Icons.layers),
                    onPressed: () async {
                      final String layer = await Navigator.push(
                          global.currentState.context,
                          MaterialPageRoute(builder: (_) => Layer()));
                      if (layer != null) {
                        manageLayer(layer);
                      }
                    }),
              ]),
          body: Builder(builder: (context) {
            return Column(children: <Widget>[
              Expanded(
                  child: LongdoMapView(
                      apiKey: API_KEY, listener: this, markers: markers),
                  flex: 1),
              Row(children: <Widget>[
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        map?.zoom(zoom: Zooms.IN, anim: true);
                      },
                    ),
                    flex: 1),
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        map?.zoom(zoom: Zooms.OUT, anim: true);
                      },
                    ),
                    flex: 1),
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () async {
                        var location = await map.currentLocation();
                        if (location != null) {
                          map.go(lon: location.lon, lat: location.lat);
                        }
                      },
                    ),
                    flex: 1),
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.pin_drop),
                      onPressed: () async {
                        final mapLocation = await map?.crosshairLocation();
                        final marker = Marker(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            mapLocation: mapLocation);
                        setState(() {
                          markers.add(marker);
                        });
                      },
                    ),
                    flex: 1),
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        if (markers.isNotEmpty) {
                          setState(() {
                            markers?.clear();
                          });
                        }
                      },
                    ),
                    flex: 1)
              ])
            ]);
          }),
        ));
  }

  void manageLayer(String layer) {
    switch (layer) {
      case Layers.LAYER_THAICHOTE:
        thaiChote = !thaiChote;
        map?.layer(layer: Layers.LAYER_THAICHOTE, add: thaiChote);
        break;
      case Layers.LAYER_TRAFFIC:
        traffic = !traffic;
        map?.layer(layer: Layers.LAYER_TRAFFIC, add: traffic);
        break;
    }
  }

  @override
  void onInit(MapController map) {
    this.map = map;
  }

  @override
  void onOverlayClicked(BaseOverlay overlay) {
    if (overlay is Marker) {
      var location = overlay.mapLocation;
      map?.go(lon: location.lon, lat: location.lat);
    }
  }
}
