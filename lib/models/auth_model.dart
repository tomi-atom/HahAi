import 'dart:convert';

import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
  bool _isLogin = false;
  Map<String, dynamic> user = {}; //update user details when login


  bool get isLogin {
    return _isLogin;
  }


//when login success, update the status
  void loginSuccess(
      Map<String, dynamic> userData) {
    _isLogin = true;

    //update all these data when login
    user = userData;

    notifyListeners();
  }
}
