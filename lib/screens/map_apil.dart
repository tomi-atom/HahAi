import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hahai/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:hahai/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:turf/helpers.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

import '../models/auth_model.dart';
import '../providers/dio_provider.dart';



class MapApil extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const MapApil({
    required this.initialLatitude,
    required this.initialLongitude,
  });


  @override
  State createState() => MapApilState();
}

class MapApilState extends State<MapApil>
    with TickerProviderStateMixin {
  final defaultEdgeInsets =
  MbxEdgeInsets(top: 100, left: 100, bottom: 100, right: 100);

  late MapboxMap mapboxMap;
  late PointAnnotationManager pointAnnotationManager;
  Animation<double>? animation;
  AnimationController? controller;
  Timer? timer;
  var trackLocation = false;
  var showAnnotations = true;
  int styleIndex = 1;
  List<dynamic> listData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

  }


  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    this.pointAnnotationManager =
    await mapboxMap.annotations.createPointAnnotationManager();

    mapboxMap.subscribe(_eventObserver, [
      MapEvents.STYLE_LOADED,
      MapEvents.MAP_LOADED,
      MapEvents.MAP_IDLE,
    ]);

    await _getPermission();
  }


  _getPermission() async {
    await Permission.locationWhenInUse.request();
  }

  _eventObserver(Event event) {
    // print("Receive event, type: ${event.type}, data: ${event.data}");
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) {
    setLocationComponent();
    refreshTrackLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [

          MapWidget(
            key: const ValueKey("mapWidget"),
            resourceOptions: ResourceOptions(accessToken: MyApp.ACCESS_TOKEN),
            cameraOptions: CameraOptions(
                center: Point(coordinates: Position(widget.initialLongitude, widget.initialLatitude )).toJson(),
                zoom:9.0),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            textureView: true,
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoadedCallback,
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  setLocationComponent() async {
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
      ),
    );
  }

  refreshTrackLocation() async {
    timer?.cancel();
    if (trackLocation) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final position = await mapboxMap.style.getPuckPosition();
        setCameraPosition(position);
      });
    }
  }


  setCameraPosition(Position position) {
    mapboxMap.flyTo(
        CameraOptions(
          center: Point(coordinates: position).toJson(),
          padding: defaultEdgeInsets,
          zoom: 4,
        ),
        null);
  }


}

