import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rachidmallsystem/controller/marketplace_controller.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';
import 'package:rachidmallsystem/model/MarketPlace.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
class AdminAddLocationScreen extends StatefulWidget {
  const AdminAddLocationScreen({Key? key}) : super(key: key);


  @override
  _AdminAddLocationScreenState createState() => _AdminAddLocationScreenState();
}

class _AdminAddLocationScreenState extends State<AdminAddLocationScreen> {
  //Getx objects
  final _marketplacesController=Get.find<MarketPlaceController>();
  //text controllers
  TextEditingController _placenameController=TextEditingController();
  TextEditingController _placecategoryController=TextEditingController();
  TextEditingController _placenotesController=TextEditingController();
  var args=Get.arguments;
  String placeid="";
  LatLng location=const LatLng(0,0);
  int floor=0;


  //Function handles TextFields Validating
  bool validateForm() {
    var check = true;
    String msg = "";
    if (_placenameController.text.isEmpty || _placecategoryController.text.isEmpty) {
      check = false;
      msg = "Empty Fields";
    }
    if (!check) {
      showGetSnackBar("Error", msg, "Error");
    }
    return check;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    placeid=args["placeid"];
    location=args["location"];
    floor=args["floor"];

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: Column(children: [const SizedBox(
                    height: 15,
                  ),
                    const Text("New Location Form",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        controller: _placenameController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          // icon: Icon(Icons.mail),
                            prefixIcon: const Icon(Icons.drive_file_rename_outline),
                            suffixIcon: _placenameController.text.isEmpty
                                ? const Text('')
                                : GestureDetector(
                                onTap: () {
                                  _placenameController.clear();
                                },
                                child: const Icon(Icons.close)),
                            hintText: 'Place name or title',
                            labelText: 'PlaceName',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(color: Colors.red, width: 1))),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        controller: _placecategoryController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          // icon: Icon(Icons.mail),
                            prefixIcon: const Icon(Icons.category),
                            suffixIcon: _placecategoryController.text.isEmpty
                                ? const Text('')
                                : GestureDetector(
                                onTap: () {
                                  _placecategoryController.clear();
                                },
                                child: const Icon(Icons.close)),
                            hintText: 'Wearshop,cafee,BeautyCenter..etc',
                            labelText: 'Category',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(color: Colors.red, width: 1))),
                      ),

                    ),const SizedBox(
                      height: 16,
                    ),Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        controller: _placenotesController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          // icon: Icon(Icons.mail),
                            prefixIcon: const Icon(Icons.notes),
                            suffixIcon: _placenotesController.text.isEmpty
                                ? const Text('')
                                : GestureDetector(
                                onTap: () {
                                  _placenotesController.clear();
                                },
                                child: const Icon(Icons.close)),
                            hintText: 'short discription',
                            labelText: 'Notes',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(color: Colors.red, width: 1))),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                            style: redButtonStyle,
                            onPressed: ()
                            { if (!validateForm()) return;
                            final name = _placenameController.text;
                            final category = _placecategoryController.text;
                            final notes=_placenotesController.text;
                            MarketPlace newplace=MarketPlace(id: placeid,name: name,
                                category: category,notes: notes,floor: floor,
                                location:GeoPoint(location.latitude,location.longitude) );
                            _marketplacesController.addMarketPlacetoMap(newplace); }            ,
                            child: const Text(
                              "Save",
                              style: TextStyle(fontSize: 20),
                            )),
                        const SizedBox(width: 10,),
                        Obx((){
                          return _marketplacesController.isLoading.value
                              ? const CircularProgressIndicator()
                              : const SizedBox(
                            width: 5,
                          );
                        })
                      ],
                    ),

                  ],),
                ),
              ),
            ),
          );})
      ),
    );
  }
}
