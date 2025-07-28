import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/home_screen.dart';
import 'package:topmortarseller/services/api.dart';
import 'package:topmortarseller/services/auth_api.dart';
// import 'package:topmortarseller/services/contact_api.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/screen/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var tryToLoginChance = 2;

  @override
  void initState() {
    super.initState();
    _delayNavigate();
  }

  void _delayNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
    // getContact(); // Until now, it is just for debugging only
    final loginState = await getLoginState();
    if (loginState) {
      loginHandler();
    } else {
      _returnAuthScreen();
    }
  }

  // Until now, it is just for debugging only
  // void getContact() async {
  //   const idContact = "";
  //   const idDistributor = "";

  //   try {
  //     final data = await ContactApiService().byId(
  //       idContact: idContact,
  //       idDistributor: idDistributor,
  //       onSuccess: (data) => print('get user data: $data'),
  //       onError: (e) => print('get user error: $e'),
  //       onCompleted: () => print('get user complete'),
  //     );

  //     if (data != null) {
  //         final ContactModel userData = data[0];
  //           await saveLoginState("nomorhp", "password");
  //           await saveContactModel(userData);
  //           _returnHomeScreen(userData);
  //     }

  //   } catch (e) {
  //     print('get user catch: $failedRequestText. Exception: $e');
  //   }
  // }

  void loginHandler() async {
    var phoneNumber = await getLoginPhone();
    final password = await getLoginPassword();

    try {
      final response = await AuthApiService().login(
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            final userData = ContactModel.fromJson(apiResponse.data!);
            await saveLoginState(phoneNumber, password);
            await saveContactModel(userData);
            // print('userData: ${apiResponse.msg}');
            _returnHomeScreen(userData);
          } else {
            // print('userData: Response data is null!');
            tryToLogin();
          }
        } else {
          // print('userData: ${apiResponse.msg}');
          tryToLogin();
        }
      } else {
        // print(
        //     'userData: $failedRequestText. Status Code: ${response.statusCode}');
        tryToLogin();
      }
    } catch (e) {
      // print('userData: $failedRequestText. Exception: $e');
      tryToLogin();
    }
  }

  void tryToLogin() async {
    if (tryToLoginChance <= 0) {
      final userData = await getContactModel();
      if (userData != null) {
        _returnHomeScreen(userData);
      } else {
        _returnAuthScreen();
      }
    } else {
      tryToLoginChance -= 1;
      // print('userData: Relogin Chance $tryToLoginChance');
      loginHandler();
    }
  }

  void _returnHomeScreen(ContactModel? userData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)),
    );
  }

  void _returnAuthScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: TagHero.faviconAuth,
          child: Semantics(
            label: '${TagHero.faviconAuth}',
            child: Image.asset(
              'assets/favicon/favicon_circle.png',
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ),
    );
  }
}
