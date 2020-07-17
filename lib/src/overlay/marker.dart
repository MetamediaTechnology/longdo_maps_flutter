import 'package:flutter/cupertino.dart';
import 'package:longdo_maps_flutter/src/location/mapLocation.dart';
import 'package:longdo_maps_flutter/src/overlay/base.dart';

class Marker extends BaseOverlay {
  String url;
  double offsetX;
  double offsetY;
  int width;
  int height;
  int minZoom;
  int maxZoom;
  int weight;
  int rotate;

  Marker({
    @required id,
    @required MapLocation mapLocation,
    this.url = "https://api.longdo.com/map/images/pin.svg",
    this.width = 30,
    this.height = 42,
    this.offsetX = 15.0,
    this.offsetY = 42.0,
    this.minZoom = 1,
    this.maxZoom = 20,
    this.weight = 1,
    this.rotate = 0,
  }) : super(id: id, mapLocation: mapLocation);

  Future<String> create() async => '''
  var overlay = new longdo.Marker({ lon: ${mapLocation.lon}, lat: ${mapLocation.lat} },
  {
    icon: {
      url: "$url",
      offset: { x: $offsetX, y: $offsetY },
      size: { width: $width, height: $height }
    },
    visibleRange: { min: $minZoom, max: $maxZoom },
    weight: ${weight ?? "longdo.OverlayWeight.Top"},
    rotate: $rotate
  });
  overlay.id = "$id";
  ''';
}
