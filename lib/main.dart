import 'package:flutter/material.dart';
import 'Core/AppRoute/app_route.dart';
import 'Core/Dependency/dependency.dart';
import 'Utils/AppConst/app_const.dart';
import 'global/theme/light.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Dependency.init();
  runApp(
    Dependency.wrapWithProviders(const KrishiBazarApp()),
  );
}

class KrishiBazarApp extends StatelessWidget {
  const KrishiBazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConst.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      initialRoute: AppRoute.splashScreen,
      routes: AppRoute.routes,
    );
  }
}
