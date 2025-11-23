import 'package:meetyarah/ui/login_reg_screens/model/user_model.dart';

class LoginModel {
  late final String status;
  late final String token;
  late final UserModel userModel;

  LoginModel.fromJson(Map<String, dynamic> jsonData) {
    status = jsonData[''] ?? '';
    userModel = UserModel.fromJson(jsonData['user'] ?? {});
    token = jsonData['token'];
  }
}

//
// {
// "status": "success",
// "message": "Login successful.",
// "user": {
// "user_id": 15,
// "username": "xxxx",
// "email": "xxxx",
// "full_name": "xxxx",
// "profile_picture_url": null
// },
// "token": "833a99ac5bb82233fc654dc1be11b41f2b2ea699df1d9e2b9f77b70169c1c926"
// }
