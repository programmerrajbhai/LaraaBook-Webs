import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/login_reg_screens/widgets/Textfromfield.dart';
import 'package:meetyarah/ui/login_reg_screens/widgets/containnerBox.dart';

class ForgotScreens extends StatefulWidget {
  const ForgotScreens({super.key});

  @override
  State<ForgotScreens> createState() => _ForgotScreensState();
}

class _ForgotScreensState extends State<ForgotScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(onPressed: (){},
      //       icon: Icon(Icons.arrow_back)),
      // ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 50,),
              GestureDetector(
                onTap: (){Get.back();},
                child: CircleAvatar(
                  backgroundColor: Color(0xA0F5F5F5),
                  child:Icon(Icons.arrow_back,size: 27,color: Colors.black,)),
              )
              ,
              SizedBox(height: 50,),
              Text("Forget Password",
              style: TextStyle(
             fontWeight: FontWeight.bold,fontSize: 30
              ),),
              SizedBox(height: 30,),
              textfromfield(
                text: "Enter your email",
                icon: Icons.email, controller: null,
              ),
              SizedBox(height: 40),

              containnerBox(
                bgColors: ColorPath.deepBlue,
                text: "Send Email",
                textColors: Colors.white,
              ),


            ],
          ),
        ),
      ),
      
    );
  }
}
