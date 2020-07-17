import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:longdo_maps_flutter/longdo_maps_flutter.dart';

class Base extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Base Map")),
        body: ListView.separated(
          itemBuilder: (context, int i) {
            return ListTile(
                title: Text(_title(i)),
                onTap: () {
                  Navigator.pop(context, _value(i));
                });
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: 4,
        ));
  }

  String _title(i) {
    switch (i) {
      case 0:
        return "Normal";
      case 1:
        return "Gray";
      case 2:
        return "Reverse";
      case 3:
        return "POI";
      default:
        return null;
    }
  }

  String _value(i) {
    switch (i) {
      case 0:
        return Layers.BASE_NORMAL;
      case 1:
        return Layers.BASE_GRAY;
      case 2:
        return Layers.BASE_REVERSE;
      case 3:
        return Layers.BASE_POI;
      default:
        return null;
    }
  }
}
