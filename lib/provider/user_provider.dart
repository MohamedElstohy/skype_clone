import 'package:flutter/material.dart';

import 'package:skype/models/user.dart';

import 'package:skype/resources/auth_methods.dart';

class UserProvider with ChangeNotifier{
  AppUser _user;
  AuthMethods _authMethods = AuthMethods();

  AppUser get getUser => _user;

  Future<void> refreshUser() async{
    AppUser user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}