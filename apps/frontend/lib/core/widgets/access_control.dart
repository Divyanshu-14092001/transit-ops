import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/access_control_service.dart';

class AccessControl extends StatelessWidget {
  final String permission;
  final Widget child;

  const AccessControl({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool allowed = AccessControlService.to.hasPermission(permission);
      if (allowed) {
        return child;
      }
      return const SizedBox.shrink();
    });
  }
}
