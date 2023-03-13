import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rachidmallsystem/controller/location_controller.dart';
import 'package:rachidmallsystem/controller/routing_controller.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';
import 'package:rachidmallsystem/model/MarketPlace.dart';
import 'package:rachidmallsystem/routing/models/Graph.dart';
import 'package:rachidmallsystem/screens/user_search_locations_screen.dart';

import '../constants.dart';
import '../controller/marketplace_controller.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({Key? key}) : super(key: key);

  @override
  _HomeNavigationScreenState createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  //get injected Getx object
  final _locationController = Get.find<LocationController>();
  final _marketPlaceController = Get.put(MarketPlaceController());
  final _routingController = Get.put(RoutingController());

  late GoogleMapController _mapController;

  //declare initial camera position
  late CameraPosition kGooglePlex;

  //geojson object to read floorplan details
  final geo = GeoJson();

  //Rachid mall location constants
  final LatLng mallLocation =
      const LatLng(18.236889506003262, 42.57969427853822);
  final double zoomLevel = 17.64417266845703;
  final double bearing = 220.48236083984375;
  final LatLng swLimit = const LatLng(18.234986525271296, 42.577868700027466);
  final LatLng neLimit = const LatLng(18.23881794046614, 42.58134484291077);

// save map style from file
  String _mapStyle = "";

  //create Graph
  Graph graph = Graph();
  //router

  bool routeMode = false;
  int sourceFloor = 0;
  int destinationFloor = 0;
  LatLng source = LatLng(0, 0);
  LatLng destination = LatLng(0, 0);

  //markers and circles map layers
  Set<Circle> circles = <Circle>{};
  Set<Marker> markers = <Marker>{};
  Set<Polygon> polygones = <Polygon>{};
  Set<Polyline> _polylines = <Polyline>{};
  //index for markers and polygons id
  int idIndex = 0;
  //current selected floor
  int _selectedFloor = 0;

  //function read floor plan details from geojsons folder
  Future<void> parseAndDrawAssetsOnMap() async {
    //when file parsed add the parsed objects to map
    geo.processedFeatures.listen((event) {
      switch (event.type) {

        //parsed polygons
        case GeoJsonFeatureType.polygon:
          {
            //get polygon points
            GeoJsonPolygon parsedPolygon = event.geometry;

            //get polygon extra properties
            Map<String, dynamic>? geoProperties = event.properties;
            //get the category 'hole' marketplace ' stair'
            String category = geoProperties!["category"].toString();
            Color fillColor, strokeColor;
            //each object on map should have an id
            String placeId = "";
            // check polygon category to generate unique colors and styles
            if (category == 'hole') {
              placeId = "f" +
                  _selectedFloor.toString() +
                  "h" +
                  (idIndex++).toString();
              fillColor = Colors.white;
              strokeColor = Colors.black38;
            } else if (category == 'marketplace') {
              placeId = "f" +
                  _selectedFloor.toString() +
                  "mp" +
                  (idIndex++).toString();
              fillColor = Colors.green.shade300.withAlpha(20);
              strokeColor = Colors.green;
            } else if (category == 'stair') {
              placeId = "f" +
                  _selectedFloor.toString() +
                  "st" +
                  (idIndex++).toString();
              fillColor = Colors.pink.shade300.withAlpha(20);
              strokeColor = Colors.pink;
            } else {
              placeId = "f" +
                  _selectedFloor.toString() +
                  "area" +
                  (idIndex++).toString();
              fillColor = Colors.blue.shade300.withAlpha(20);
              strokeColor = Colors.red;
            }
            List<LatLng> polyGonPoints = <LatLng>[];
            //get polygon points from parsed geometery
            parsedPolygon.geoSeries.first.geoPoints.forEach((element) {
              polyGonPoints.add(LatLng(element.latitude, element.longitude));
            });
            //add object to the map
            setState(() {
              polygones.add(Polygon(
                polygonId: PolygonId(placeId),
                points: polyGonPoints,
                visible: true,
                strokeWidth: 1,
                fillColor: fillColor,
                strokeColor: strokeColor,
                consumeTapEvents: false,
              ));
            });

            break;
          }
        //if the parsed object is a marker
        case GeoJsonFeatureType.point:
          {
            GeoJsonPoint parsedPoint = event.geometry;
            //get polygon extra properties
            Map<String, dynamic>? geoProperties = event.properties;
            //get the category 'hole' marketplace ' stair'
            String category = geoProperties!["category"].toString();
            String markerid = category.startsWith("stairpoint")
                ? category
                : "exit" + (idIndex++).toString();

            setState(() {
              //add marker to the map
              markers.add(Marker(
                  markerId: MarkerId(markerid),
                  position: LatLng(parsedPoint.geoPoint.latitude,
                      parsedPoint.geoPoint.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  infoWindow: const InfoWindow(title: "Entrance/Exit")));
            });
            break;
          }
      }
    });
    //read floor details from the file specified with selected floor
    //e.g assets/geojsons/level0.geojson
    String data = await rootBundle
        .loadString('assets/geojsons/level${_selectedFloor}.geojson');
    //parse file content
    await geo.parse(data).then((_) async {
      setState(() {
        graph = Graph();
      });
    });
  }

//function to handle select floor from user
  selectFloor(int floor) async {
    //clear all objects on map
    setState(() {
      _selectedFloor = floor;
      _polylines = <Polyline>{};
      polygones = <Polygon>{};
      markers = <Marker>{};
      idIndex = 0;
    });
    //read data from the selected floor file
    String data = await rootBundle
        .loadString('assets/geojsons/level${_selectedFloor}.geojson');
    //parse data
    await geo.parse(data).then((_) async {
      setState(() {
        graph = Graph();
      });
      if (_routingController.routeMode.value) {
        await drawRoutePath();
      }
      ;
    });

    //get saved locations from firebase
    getFloorPlaces();
  }

  initRoutePropretiesTo(MarketPlace marketplace) async {
    if (_locationController.userLocation == null) {
      showGetSnackBar("No location",
          "Failed to get your location..restart app please", "Error");
      return;
    }
    _routingController.startLoading();
    setState(() {
      source = LatLng(_locationController.userLocation.latitude,
          _locationController.userLocation.longitude);
      destination =
          LatLng(marketplace.location.latitude, marketplace.location.longitude);
      sourceFloor = _selectedFloor;
      destinationFloor = marketplace.floor;
      _polylines = <Polyline>{};
    });
    await drawRoutePath();
  }

  drawRoutePath() async {
    await _routingController
        .drawPathForFloor(source, destination, sourceFloor, destinationFloor,
            markers, polygones, _selectedFloor)
        .then((path) {
      setState(() {
        if (path != null)
          _polylines.add(path);
        else
          _polylines = <Polyline>{};
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      //reading mapstyle from file
      //to hide map labels
      rootBundle.loadString('assets/styles/mapstyle.json').then((string) {
        _mapStyle = string;
      });
      //call function to draw floor detalis
      parseAndDrawAssetsOnMap();
      //obtain the current GPS position
      _locationController.getCurrentUserLocation().then((value) async {});
      //initialize camera to Gps current position
      kGooglePlex = CameraPosition(
        bearing: bearing,
        target: mallLocation,
        zoom: zoomLevel,
      );

      //get marketplaces from firebase
      getFloorPlaces();
    });
  }

//function to get saved places from firebase
  getFloorPlaces() async {
    //call function from controller
    await _marketPlaceController
        .getFloorMarketPlaces(_selectedFloor)
        .then((placeslist) {
      //when finished add a marker place for every location
      for (int i = 0; i < placeslist.length; i++) {
        LatLng position = LatLng(
            placeslist[i].location.latitude, placeslist[i].location.longitude);
        setState(() {
          markers.add(Marker(
              markerId: MarkerId("place" + placeslist[i].id),
              position: position,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
              infoWindow: InfoWindow(
                  title: placeslist[i].name,
                  snippet:
                      placeslist[i].category + "\n" + placeslist[i].notes)));
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mapController.dispose();
    geo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: kGooglePlex,
            zoomGesturesEnabled: true,
            minMaxZoomPreference:
                const MinMaxZoomPreference(17.64417266845703, null),
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: true,
            onCameraMove: (cam) {
              debugPrint(cam.bearing.toString());
              debugPrint(cam.target.toString());
              debugPrint(cam.zoom.toString());
            },

            cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(southwest: swLimit, northeast: neLimit)),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _mapController.setMapStyle(_mapStyle);
            },
            polygons: polygones,
            markers: markers,
            polylines: _polylines,
            // circles: circles,
          ),
          Obx(() => _routingController.routeMode.value == false
              ? const SizedBox()
              : Positioned(
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _routingController.routeMessage.value == ""
                                ? "No route in this floor"
                                : _routingController.routeMessage.value,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text("Floors"),
                    SizedBox(
                      width: 50,
                      height: 35,
                      child: ElevatedButton(
                        style: _selectedFloor == 2
                            ? yellowButtonStyle.copyWith(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0)),
                              )
                            : redButtonStyle.copyWith(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0)),
                              ),
                        onPressed: () {
                          selectFloor(2);
                        },
                        child: const Text('2'),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 35,
                      child: ElevatedButton(
                        style: _selectedFloor == 1
                            ? yellowButtonStyle.copyWith(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0)),
                              )
                            : redButtonStyle.copyWith(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0)),
                              ),
                        onPressed: () {
                          selectFloor(1);
                        },
                        child: const Text('1'),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 35,
                      child: ElevatedButton(
                        style: _selectedFloor == 0
                            ? yellowButtonStyle.copyWith(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0)),
                              )
                            : redButtonStyle.copyWith(
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.all(0)),
                              ),
                        onPressed: () {
                          selectFloor(0);
                        },
                        child: const Text('0'),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () async {
                if (_routingController.routeMode.value) {
                  _routingController.resetRouteMode();
                  return;
                }
                //wait user to return the place choosen
                MarketPlace marketplace =
                    await Get.to(() => const UserSearchScreen());
                //call controller to generate route
                await initRoutePropretiesTo(marketplace);
              },
              child: Obx(() => _routingController.routeMode.value
                  ? Icon(Icons.close)
                  : Icon(Icons.search)),
              tooltip: "Search",
              backgroundColor: Colors.red,
              heroTag: "btnSearch",
            ),
            const SizedBox(
              height: 5,
            ),
            Obx(() => _marketPlaceController.isLoading.value ||
                    _routingController.isLoading.value
                ? const CircularProgressIndicator()
                : const SizedBox())
          ],
        ),
      ),
    ));
  }
}
