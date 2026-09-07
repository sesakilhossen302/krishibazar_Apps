import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/controller/krishi_controller.dart';
import '../../global/controller/krishi_repository.dart';

class Dependency {
  static void init() {}

  static Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KrishiController()),
        ChangeNotifierProvider(create: (_) => KrishiRepository()),
      ],
      child: child,
    );
  }
}
