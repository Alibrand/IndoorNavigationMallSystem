import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachidmallsystem/constants.dart';
import 'package:rachidmallsystem/model/MarketPlace.dart';

import '../controller/marketplace_controller.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  //get injected Getx object
  final _marketplaceController = Get.find<MarketPlaceController>();
  final _searchTextController = TextEditingController();
  List<MarketPlace> searchList = <MarketPlace>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _marketplaceController.marketPlacesList = [];
    searchList = [..._marketplaceController.marketPlacesList.toList()];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Search Locations",
              style: TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchTextController,
              onChanged: (value) {
                if (_searchTextController.text.isEmpty) return;
                String searchKey = value;
                _marketplaceController.searchMarketPlaces(searchKey);

                setState(() {
                  searchList = [
                    ..._marketplaceController.marketPlacesList.toList()
                  ];
                });
              },
              decoration: InputDecoration(
                  // icon: Icon(Icons.mail),
                  prefixIcon: GestureDetector(
                      onTap: () {}, child: const Icon(Icons.search)),
                  suffixIcon: _searchTextController.text.isEmpty
                      ? const Text('')
                      : GestureDetector(
                          onTap: () {
                            _searchTextController.clear();
                          },
                          child: const Icon(Icons.close)),
                  hintText: 'Search by place name',
                  labelText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1))),
            ),
          ),
          Expanded(
              child: Obx(() => _marketplaceController.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: searchList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(searchList[index].name),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(searchList[index].category),
                            Text(
                                "Floor: " + searchList[index].floor.toString()),
                          ],
                        ),
                        isThreeLine: true,
                        leading: const Icon(Icons.location_pin),
                        trailing: TextButton(
                          style: redButtonStyle,
                          onPressed: () {
                            Get.back(result: searchList[index]);
                          },
                          child: const Icon(Icons.directions),
                        ),
                      ),
                    )))
        ],
      ),
    ));
  }
}
