import 'package:flutter/material.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';

class RoleSwitcherController extends ChangeNotifier {
  final KrishiRepository repository;

  RoleSwitcherController(this.repository);

  UserRole get currentRole => repository.currentRole;

  void switchRole(UserRole role) {
    repository.switchRole(role);
    repository.closeRoleSwitcher();
  }

  void close() => repository.closeRoleSwitcher();
}
