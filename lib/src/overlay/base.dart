import 'package:flutter/cupertino.dart';
import 'package:longdo_maps_flutter/src/location/mapLocation.dart';

class BaseOverlay {
  String id;
  MapLocation mapLocation;

  BaseOverlay({@required this.id, @required this.mapLocation});
}
