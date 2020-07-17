import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:longdo_maps_flutter/src/controller.dart';
import 'package:longdo_maps_flutter/src/interface.dart';
import 'package:longdo_maps_flutter/src/overlay/marker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LongdoMapView extends StatefulWidget {
  String apiKey;
  MapInterface listener;
  List<Marker> markers;

  LongdoMapView({@required this.apiKey, this.listener, this.markers}) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  _LongdoMapState createState() => _LongdoMapState();
}

class _LongdoMapState extends State<LongdoMapView> {
  InAppWebViewController webView;
  MapController model;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUrl(),
        builder: (context, snapshot) => snapshot.hasData
            ? InAppWebView(
                initialUrl: snapshot.data,
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform:
                        InAppWebViewOptions(useShouldOverrideUrlLoading: true)),
                shouldOverrideUrlLoading: (controller, request) async {
                  return ShouldOverrideUrlLoadingAction.CANCEL;
                },
                onWebViewCreated: (controller) {
                  webView = controller;
                  webView.addJavaScriptHandler(
                      handlerName: "init",
                      callback: (result) {
                        model = MapController(webView);
                        widget.listener.onInit(model);
                        webView.removeJavaScriptHandler(handlerName: "init");
                      });
                  webView.addJavaScriptHandler(
                      handlerName: "overlay",
                      callback: (result) {
                        if (result.isNotEmpty) {
                          final String id = result.first.toString();
                          widget.markers.forEach((it) {
                            if (id == it.id) {
                              widget.listener.onOverlayClicked(it);
                              return;
                            }
                          });
                        }
                      });
                },
              )
            : Center(child: CircularProgressIndicator()));
  }

  Future<String> getHTML() async =>
      rootBundle.loadString("packages/longdo_maps_flutter/assets/index.html");

  Future<String> assignApiKey(final html, final apiKey) async =>
      html.replaceAll("key=[YOUR_KEY_API]", "key=$apiKey");

  Future<Uri> parseToUri(final html) async => Uri.dataFromString(html,
      mimeType: "TEXT/HTML", encoding: Encoding.getByName("UTF-8"));

  Future<String> getUrl() async {
    var html = await getHTML();
    html = await assignApiKey(html, widget.apiKey);
    return (await parseToUri(html)).toString();
  }

  @override
  void didUpdateWidget(LongdoMapView oldWidget) {
    updateMarker();
    super.didUpdateWidget(oldWidget);
  }

  void updateMarker() async {
    final lastMarker = await model.marker();
    final ids = widget.markers.map((it) => it.id).toSet();
    final union = lastMarker?.union(ids) ?? ids;
    final remove = union.difference(ids);
    if (remove != null && remove.isNotEmpty) {
      model.remove(id: remove.toList());
    }
    final add = union.difference(lastMarker ?? Set());
    if (add != null && add.isNotEmpty) {
      initMarker(add: add.toList());
    }
  }

  void initMarker({@required List<String> add}) {
    var marker = getMarker(ids: add.toList());
    if (marker?.isNotEmpty ?? false) {
      model.add(markers: marker);
    }
  }

  List<Marker> getMarker({@required List<String> ids}) {
    return widget.markers?.where((it) => ids.contains(it.id))?.toList();
  }
}
