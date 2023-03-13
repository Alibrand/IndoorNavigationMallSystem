import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachidmallsystem/constants.dart';
import 'package:rachidmallsystem/controller/marketplace_controller.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({Key? key}) : super(key: key);

  @override
  _AdminSearchScreenState createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  //get injected Getx object
  final _marketplaceController = Get.find<MarketPlaceController>();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _marketplaceController.marketPlacesList = [];
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
              "Admin Search Locations",
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
                setState(() {});
              },
              decoration: InputDecoration(
                  // icon: Icon(Icons.mail),
                  prefixIcon: const Icon(Icons.search),
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
                      itemCount: _marketplaceController.marketPlacesList.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(_marketplaceController
                            .marketPlacesList[index].name),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_marketplaceController
                                .marketPlacesList[index].category),
                            Text("Floor: " +
                                _marketplaceController
                                    .marketPlacesList[index].floor
                                    .toString()),
                          ],
                        ),
                        isThreeLine: true,
                        leading: const Icon(Icons.location_pin),
                        trailing: TextButton(
                          style: redButtonStyle,
                          onPressed: () {
                            Get.back(
                                result: _marketplaceController
                                    .marketPlacesList[index]);
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
