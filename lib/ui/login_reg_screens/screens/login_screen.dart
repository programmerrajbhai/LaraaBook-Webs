import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/image_url.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/loginController.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/forget_screen.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/reg_screen.dart';
import '../widgets/Textfromfield.dart';
import '../widgets/containnerBox.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final loginController= Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                ImagePath.appLogotransparent,
                width: Get.width * 1,
                height: Get.height * 0.35,
              ),
              textfromfield(
                icon: Icons.account_box,
                text: 'Email or Phone Number',
                controller:loginController.emailOrPhoneCtrl,
              ),
              SizedBox(height: 8),
              textfromfield(
                icon: Icons.lock,
                text: 'Password',
                controller: loginController.passwordCtrl,
              ),
              TextButton(
                onPressed: () {
                  Get.to(ForgotScreens());
                },
                child: Text(
                  "Forgot Password",
                  style: TextStyle(color: ColorPath.deepBlue, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () {
                  loginController.LoginUser();
                },
                child: containnerBox(
                  bgColors: ColorPath.deepBlue,
                  text: "LOGIN",
                  textColors: Colors.white,
                ),
              ),
              SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              containnerBox(
                bgColors: Colors.white,
                text: 'Sign in by google',
                prefixIcons: ImagePath.gogoleIcon,
                textColors: Colors.black,
              ),
              SizedBox(height: 40),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(RegistrationScreens());
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
