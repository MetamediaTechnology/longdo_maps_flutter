import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:longdo_maps_flutter/src/location/mapLocation.dart';
import 'package:longdo_maps_flutter/src/overlay/marker.dart';
import 'package:flutter_inappwebview/src/in_app_webview_controller.dart';

class MapController {
  InAppWebViewController webView;
  Location location;

  MapController(this.webView);

  // Core

  run({@required String script}) async {
    print(script);
    return await webView.evaluateJavascript(source: script);
  }

  // Defining or Display location on map
  // https://map.longdo.com/docs/javascript/ui/maplocation

  go({@required double lon, @required double lat, bool anim = true}) async {
    final script = '''
    map.location(
      {
        lon: $lon,
        lat: $lat
      },
        $anim
    );
    ''';
    await run(script: script);
  }

  Future<MapLocation> crosshairLocation() async {
    final script = '''
    map.location();
    ''';
    Map map = await run(script: script);
    return MapLocation(lon: map["lon"], lat: map["lat"]);
  }

  // Define or Display the zoom level in map
  // https://map.longdo.com/docs/javascript/ui/mapzoom

  zoom({int level, bool zoom, bool anim = true}) async {
    if (level != null) {
      final script = '''
      map.zoom($level, $anim);
      ''';
      await run(script: script);
    } else if (zoom != null) {
      final script = '''
      map.zoom($zoom, $anim);
      ''';
      await run(script: script);
    }
  }

  // Display of User Interface
  // https://map.longdo.com/docs/javascript/ui/disable-map-tool
  scaleBar({@required bool show}) async {
    final script = '''
    map.Ui.Scale.visible($show);
    ''';
    await run(script: script);
  }

  // Overlays
  Future<Set<String>> marker() async {
    final script = '''
    marker();
    ''';
    final List list = await run(script: script);
    return list.map((it) => it.toString()).toSet();
  }

  // Create Marker
  // https://map.longdo.com/docs/javascript/marker/createmarker

  add({@required List<Marker> markers}) async {
    final List<String> list =
        await Future.wait(markers.map((marker) async => await marker.create()));
    list.forEach((marker) {
      final script = '''
      $marker
      map.Overlays.add(overlay);
      ''';
      run(script: script);
    });
  }

  remove({@required List<String> id}) async {
    String _id = "";
    id.asMap().forEach((i, it) {
      if (i > 0) {
        _id += ",";
      }
      _id += "\"$it\"";
    });
    final script = '''
      remove([$_id]);
      ''';
    run(script: script);
  }

  // Layer

  base({@required String name}) async {
    final script = '''
    map.Layers.setBase($name);
    ''';
    await run(script: script);
  }

  layer({@required String layer, @required bool add}) {
    final script = '''
    map.Layers.${add ? "add" : "remove"}($layer);
    ''';
    run(script: script);
  }

  // Clear
  clear({bool overlay, bool layer}) async {
    if (overlay) {
      final script = '''
    map.Overlays.clear();
    ''';
      await run(script: script);
    }
    if (layer) {
      final script = '''
      map.Layers.clear();
    ''';
      await run(script: script);
    }
  }

  // Location

  Location _location() {
    if (location == null) {
      location = new Location();
    }
    return location;
  }

  Future<MapLocation> currentLocation() async {
    var location = _location();
    var service = await location.serviceEnabled();
    if (!service) {
      var enabled = await location.requestService();
      if (!enabled) {
        return null;
      }
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return null;
      }
    }

    var result = await location.getLocation();
    if (result != null) {
      return MapLocation(lon: result.longitude, lat: result.latitude);
    }
    return null;
  }
}
