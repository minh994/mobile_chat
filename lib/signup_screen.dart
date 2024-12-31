import 'package:flutter/material.dart';
import 'package:mobile_chat/routes/app_routes.dart';
import 'package:mobile_chat/service/auth_service.dart';
import 'package:mobile_chat/widgets/social_login_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    Future<void> _handleSignup() async {
      if (_formKey.currentState!.validate()) {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }
        
        try {
          await _authService.signUpWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
            _usernameController.text,
          );
          // Navigate to home screen on success
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.blue,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'TASK-WAN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Management App',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _usernameController,
                  icon: Icons.person,
                  hintText: 'Username',
                  validator: Validators.validateUsername,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  icon: Icons.email,
                  hintText: 'Email',
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hintText: 'Password',
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  icon: Icons.lock,
                  hintText: 'Confirm Password',
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Register',
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or Register with'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      icon: 'assets/icons/google.png',
                      onPressed: () => _authService.signInWithGoogle(),
                    ),
                    const SizedBox(width: 16),
                    SocialLoginButton(
                      icon: 'assets/icons/facebook.png',
                      onPressed: () {
                        // Handle Facebook sign in
                      },
                    ),
                    const SizedBox(width: 16),
                    SocialLoginButton(
                      icon: 'assets/icons/twitter.png',
                      onPressed: () {
                        // Handle Twitter sign in
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 