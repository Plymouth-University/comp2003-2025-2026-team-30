import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'package:adaptive_english_learning_app/widgets/custom_scafford.dart';
import 'package:adaptive_english_learning_app/widgets/auth_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup failed. Please try again."),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topToggle(
                    isLogin: false,
                    onLoginTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    onSignUpTap: () {},
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  inputField(
                    label: "Email",
                    hint: "you@example.com",
                    icon: Icons.email,
                    controller: _emailController,
                  ),

                  const SizedBox(height: 16),

                  inputField(
                    label: "Password",
                    hint: "••••••••",
                    icon: Icons.lock,
                    isPassword: true,
                    controller: _passwordController,
                  ),

                  const SizedBox(height: 30),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : primaryButton(
                          "Create Account",
                          onPressed: _signUp,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
