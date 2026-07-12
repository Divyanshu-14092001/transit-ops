import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/responsive_layout.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget formContent = Form(
      key: controller.loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Sign In',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'TransitOps Enterprise Portal',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Email Address',
            hint: 'e.g. admin@transitops.com',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email address is required';
              }
              if (!GetUtils.isEmail(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Obx(() => AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: controller.passwordController,
                isPassword: !controller.isPasswordVisible.value,
                prefixIcon: Icons.lock_outline,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              )),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Obx(() => TextButton.icon(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(
                      controller.isPasswordVisible.value ? 'Hide' : 'Show',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() => AppButton(
                label: 'Sign In',
                isLoading: controller.isLoading.value,
                onPressed: controller.login,
              )),
          const SizedBox(height: 32),
        ],
      ),
    );

    return Scaffold(
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ResponsiveLayout(
                    mobile: formContent,
                    tablet: SizedBox(
                      width: 420,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: formContent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
