import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachidmallsystem/constants.dart';
import 'package:rachidmallsystem/controller/auth_controller.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //TextEditing Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _authController=Get.find<AuthController>();

  bool isVisible = true;

  //Function handles TextFields Validating
  bool validateForm() {
    var check = true;
    String msg = "";
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      check = false;
      msg = "Empty Fields";
    }
    if (!check) {
      showGetSnackBar("Error", msg, "Error");
    }
    return check;
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
                      controller: emailController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          // icon: Icon(Icons.mail),
                          prefixIcon: const Icon(Icons.mail),
                          suffixIcon: emailController.text.isEmpty
                              ? const Text('')
                              : GestureDetector(
                                  onTap: () {
                                    emailController.clear();
                                  },
                                  child: const Icon(Icons.close)),
                          hintText: 'example@mail.com',
                          labelText: 'Email',
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
                      controller: passwordController,
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
                          labelText: 'Password',
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
            final email = emailController.text;
            final password = passwordController.text;
            _authController.userSignIn(email, password); }            ,
                          child: const Text(
                            "Sign In",
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
