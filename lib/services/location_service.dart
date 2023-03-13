import 'package:geolocator/geolocator.dart';
import 'package:rachidmallsystem/model/FireResponse.dart';

class LocationService {
  //instance of geolocator
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<FireRespone> getCurrentPosition() async {
    FireRespone response = FireRespone();
    try {
      await _handlePermission();

      final position = await _geolocatorPlatform.getCurrentPosition();
      response.status = "OK";
      response.data = position;

      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      throw Exception(
          "Location services are not enabled!\n Please Enable from Settings");
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception("Permission Denied by User");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      throw Exception("Permission Denied forever");
    }

    return true;
  }

  double getdistanceBetween(lat1, long1, lat2, long2) {
    return _geolocatorPlatform.distanceBetween(lat1, long1, lat2, long2);
  }
}
