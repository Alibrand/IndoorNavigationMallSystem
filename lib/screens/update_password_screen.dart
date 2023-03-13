import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachidmallsystem/controller/auth_controller.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';

import '../constants.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  //TextEditing Controllers
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  String userEmail="";
  final _authController=Get.find<AuthController>();

  bool isVisible = true;

  //Function handles TextFields Validating
  bool validateForm() {
    var check = true;
    String msg = "";
    if (oldPassController.text.isEmpty || newPassController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      check = false;
      msg = "Empty Fields";
    }
    if(newPassController.text!=confirmPassController.text)
      {
        check = false;
        msg = "Passwords don't match";
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
    userEmail=_authController.currentUser.value.email;
  }


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
                        const Text("Admin Sign In",
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
                            obscureText: isVisible,
                            controller: oldPassController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              // icon: Icon(Icons.mail),

                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      isVisible = !isVisible;
                                      setState(() {});
                                    },
                                    child: Icon(isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                labelText: 'Old Password',
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
                            obscureText: isVisible,
                            controller: newPassController,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      isVisible = !isVisible;
                                      setState(() {});
                                    },
                                    child: Icon(isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                hintText: 'Type your password',
                                labelText: 'New Password',
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
                            obscureText: isVisible,
                            controller: confirmPassController,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      isVisible = !isVisible;
                                      setState(() {});
                                    },
                                    child: Icon(isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                hintText: 'Type your password',
                                labelText: 'Confirm New Password',
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
                                final email = userEmail;
                                final oldPassword = oldPassController.text;
                                final newPassword=newPassController.text;
                                _authController.adminUpdatePassword(email, oldPassword, newPassword); }            ,
                                child: const Text(
                                  "Update",
                                  style: TextStyle(fontSize: 20),
                                )),
                            const SizedBox(width: 10,),
                            Obx((){
                              return _authController.isLoading.value
                                  ? const CircularProgressIndicator()
                                  : const SizedBox(
                                width: 5,
                              );
                            })
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );})),
    );
  }
}
