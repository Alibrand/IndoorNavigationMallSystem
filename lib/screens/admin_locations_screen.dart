import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rachidmallsystem/controller/location_controller.dart';
import 'package:rachidmallsystem/controller/marketplace_controller.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';
import 'package:rachidmallsystem/screens/admin_edit_location.dart';

import '../constants.dart';
import '../model/MarketPlace.dart';
import 'admin_add_new_location.dart';
import 'admin_search_locations.dart';

class AdminLocationsScreen extends StatefulWidget {
  const AdminLocationsScreen({Key? key}) : super(key: key);

  @override
  _AdminLocationsScreenState createState() => _AdminLocationsScreenState();
}

class _AdminLocationsScreenState extends State<AdminLocationsScreen> {
  //get injected Getx object
  final _locationController = Get.find<LocationController>();
  final _marketPlaceController = Get.put(MarketPlaceController());

  late GoogleMapController _mapController;

  //declare initial camera position
  late CameraPosition kGooglePlex;

  //geojson object to read floorplan details
  final geo = GeoJson();

  //Rachid mall location constants
  final LatLng mallLocation =
      const LatLng(18.23698121539208, 42.58013516664506);
  final double zoomLevel = 17.64417266845703;
  final double bearing = 218.07952880859375;
  final LatLng swLimit = const LatLng(18.235478787310416, 42.5786082856901);
  final LatLng neLimit = const LatLng(18.238087412158595, 42.580582391314564);

// save map style from file
  String _mapStyle = "";

  //markers and circles map layers
  Set<Circle> circles = <Circle>{};
  Set<Marker> markers = <Marker>{};
  Set<Polygon> polygones = <Polygon>{};
  //index for markers and polygons id
  int idIndex = 0;
  //current selected floor
  int _selectedFloor = 0;
//to indicate if admin is adding a new place
  bool _selectMode = false;

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
            //to indicate if admin can tap on polygon
            bool tappable = false;
            // check polygon category to generate unique colors and styles
            if (category == 'hole') {
              placeId = "f" +
                  _selectedFloor.toString() +
                  "h" +
                  (idIndex++).toString();
              fillColor = Colors.white;
              strokeColor = Colors.black38;
            } else if (category == 'marketplace') {
              //the only object can be tapped id market place
              tappable = true;
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
                  consumeTapEvents: true,
                  onTap: () {
                    if (!tappable) return;
                    openNewPlaceForm(polyGonPoints, placeId);
                  }));
            });

            break;
          }
        //if the parsed object is a marker
        case GeoJsonFeatureType.point:
          {
            GeoJsonPoint parsedPoint = event.geometry;
            setState(() {
              //add marker to the map
              markers.add(Marker(
                  markerId: MarkerId("mark" + (idIndex++).toString()),
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
    await geo.parse(data);
  }

//function to handle select floor from user
  selectFloor(int floor) async {
    //clear all objects on map
    setState(() {
      _selectedFloor = floor;
      polygones = <Polygon>{};
      markers = <Marker>{};
      idIndex = 0;
    });
    //read data from the selected floor file
    String data = await rootBundle
        .loadString('assets/geojsons/level${_selectedFloor}.geojson');
    //parse data
    await geo.parse(data);
    //get saved locations from firebase
    getFloorPlaces();
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
          //TODO:show labels always below marker
          markers.add(Marker(
              markerId: MarkerId("place" + placeslist[i].id),
              position: position,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
              infoWindow: InfoWindow(
                  onTap: () async {
                    //wait to know if place updated or delete
                    final result = await Get.to(
                        () => const AdminEditLocationScreen(),
                        arguments: placeslist[i]);
                    //if the admin took an action delete or update
                    //reload the floor places
                    if (result != "") {
                      selectFloor(_selectedFloor);
                    }
                  },
                  title: placeslist[i].name,
                  snippet:
                      placeslist[i].category + "\n" + placeslist[i].notes)));
        });
      }
    });
  }

//function to handle open new location form
  openNewPlaceForm(List<LatLng> points, String placeid) {
    setState(() {
      //if the admin hasnt tap on add btn return
      if (!_selectMode) return;
      //close select mode
      _selectMode = !_selectMode;
      //get the centerpoint of the marketplace
      LatLng centroid = calculateCentroid(points);
      //add marker to the selected place
      markers.add(
          Marker(markerId: MarkerId("place" + placeid), position: centroid));
      //open new location form and send new location info
      //to complete them in the form and do the rest
      Get.to(() => const AdminAddLocationScreen(), arguments: {
        "placeid": placeid,
        "location": centroid,
        "floor": _selectedFloor
      });
    });
  }
//funtion handle tap the add button

  selectNewMarketPlaceLocation() {
    setState(() {
      //switch select mode on
      //when select mode is on
      //admin can tap on any market place to add a new location
      _selectMode = !_selectMode;
      if (_selectMode) {
        showGetSnackBar(
            "Select mode is On", "Tap on the place you want to add", "OK");
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
            cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(southwest: swLimit, northeast: neLimit)),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _mapController.setMapStyle(_mapStyle);
            },
            polygons: polygones,
            markers: markers,
            // circles: circles,
          ),
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
                MarketPlace marketplace =
                    await Get.to(() => const AdminSearchScreen());
                //if the place is not in the same floor
                if (marketplace.floor != _selectedFloor) {
                  //load target floor
                  await selectFloor(marketplace.floor).then((_) => {
                        //show marker info
                        _mapController.showMarkerInfoWindow(
                            MarkerId("place" + marketplace.id))
                      });
                }
                //move camera to the position of the place
                _mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(marketplace.location.latitude,
                            marketplace.location.longitude),
                        zoom: 19)));
                //show marker info
                _mapController
                    .showMarkerInfoWindow(MarkerId("place" + marketplace.id));
                setState(() {});
              },
              child: const Icon(Icons.search),
              tooltip: "Search",
              backgroundColor: Colors.red,
              heroTag: "btnSearch",
            ),
            const SizedBox(
              height: 5,
            ),
            FloatingActionButton(
              onPressed: () {
                selectNewMarketPlaceLocation();
              },
              child: Icon(_selectMode ? Icons.location_pin : Icons.add),
              heroTag: "btnAdd",
              tooltip: "Add market place",
              backgroundColor: Colors.green,
            ),
            SizedBox(
              height: 5,
            ),
            Obx(() => _marketPlaceController.isLoading.value
                ? const CircularProgressIndicator()
                : const SizedBox())
          ],
        ),
      ),
    ));
  }

  LatLng calculateCentroid(List<LatLng> points) {
    double cenLat = 0.0;
    double cenLng = 0.0;
    LatLng centroid = LatLng(cenLat, cenLng);

    for (int i = 0; i < points.length; i++) {
      cenLat += points[i].latitude;
      cenLng += points[i].longitude;
    }

    int totalPoints = points.length;
    cenLat = cenLat / totalPoints;
    cenLng = cenLng / totalPoints;
    centroid = LatLng(cenLat, cenLng);

    return centroid;
  }
}
