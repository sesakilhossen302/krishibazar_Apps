import 'package:flutter/material.dart';
import '../../../../Core/AppRoute/app_route.dart';

class SplashController extends ChangeNotifier {
  void init(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoute.loginScreen);
      }
    });
  }
}
