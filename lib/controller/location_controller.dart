import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/location_service.dart';
import 'base_controller.dart';

class LocationController extends BaseController {
  dynamic userLocation;

  Future<void> getCurrentUserLocation() async {
    isLoading.value = true;
    fireResponse.value = await LocationService().getCurrentPosition();
    if (fireResponse.value.status != "OK") {
      showGetDialog();
    } else {
      userLocation = fireResponse.value.data;
    }
    isLoading.value = false;
  }

  double getDistanceFromPosition(GeoPoint point) {
    return LocationService().getdistanceBetween(userLocation.latitude,
        userLocation.longitude, point.latitude, point.longitude);
  }
}
