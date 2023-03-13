import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachidmallsystem/constants.dart';
import 'package:rachidmallsystem/controller/auth_controller.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';
import 'package:rachidmallsystem/screens/update_password_screen.dart';

import 'admin_locations_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _authController=Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child:LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Center(
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: size.width / 3,
                      height: size.width / 3,
                      child: Image.asset('assets/images/logo.png')),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Admin Page",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.red,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 15,
                  ),
                  TextButton.icon(
                    style: redButtonStyle,
                      onPressed: (){
                      Get.to(()=>const AdminLocationsScreen());
                      },
                      icon: const Icon(Icons.location_pin), label: const Text(
                        "Locations",

                        style: TextStyle(fontSize: 20),
                      ) ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextButton.icon(
                      style: redButtonStyle,
                      onPressed: (){
                        Get.to(()=>const UpdatePasswordScreen());
                      },
                      icon: const Icon(Icons.edit), label: const Text(
                    "Update Password",

                    style: TextStyle(fontSize: 20),
                  ) ),

                  const SizedBox(
                    height: 15,
                  ),
                  TextButton.icon(
                      style: yellowButtonStyle,
                      onPressed: (){
                        _authController.adminLogout();
                      },
                      icon: const Icon(Icons.logout), label: const Text(
                    "Logout",

                    style: TextStyle(fontSize: 20),
                  ) ),
                ],
        ),
      ),
              ),
            ),
          );})),
    );
  }
}
