import 'package:get/get.dart';
import 'package:rachidmallsystem/model/MarketPlace.dart';

import '../helper/firebase_helper.dart';
import 'base_controller.dart';

class MarketPlaceController extends BaseController {
  final _fireHelper = FireBaseHelper();

  List<MarketPlace> marketPlacesList = <MarketPlace>[].obs;

  addMarketPlacetoMap(MarketPlace newplace) async {
    isLoading.value = true;
    fireResponse.value = await _fireHelper.createNewMarkPlace(newplace);
    if (fireResponse.value.status == "OK") Get.back();
    showSnackBar();
    isLoading.value = false;
  }

  updateMarketPlace(MarketPlace place) async {
    isLoading.value = true;
    fireResponse.value = await _fireHelper.updateMarkPlace(place);
    if (fireResponse.value.status == "OK") Get.back(result: "updated");
    showSnackBar();
    isLoading.value = false;
  }

  deleteMarketPlace(MarketPlace place) async {
    isLoading.value = true;
    fireResponse.value = await _fireHelper.deleteMarkPlace(place);
    if (fireResponse.value.status == "OK") Get.back(result: "deleted");
    showSnackBar();
    isLoading.value = false;
  }

  Future<List<MarketPlace>> getFloorMarketPlaces(int floor) async {
    List<MarketPlace> floorPlacesList = <MarketPlace>[];
    isLoading.value = true;
    fireResponse.value = await _fireHelper.getFloorMarketPlaces(floor);
    if (fireResponse.value.status == "OK") {
      floorPlacesList = fireResponse.value.data;
    } else {
      showSnackBar();
    }
    isLoading.value = false;
    return floorPlacesList;
  }

  searchMarketPlaces(String searchKey) async {
    isLoading.value = true;
    fireResponse.value = await _fireHelper.searchMarketPlaces(searchKey);

    if (fireResponse.value.status == "OK") {
      marketPlacesList = fireResponse.value.data;
    } else {
      showSnackBar();
    }
    isLoading.value = false;
  }
}
