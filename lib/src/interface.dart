import 'package:longdo_maps_flutter/src/controller.dart';
import 'package:longdo_maps_flutter/src/overlay/base.dart';

abstract class MapInterface {
  void onInit(MapController map);

  void onOverlayClicked(BaseOverlay overlay);
}
