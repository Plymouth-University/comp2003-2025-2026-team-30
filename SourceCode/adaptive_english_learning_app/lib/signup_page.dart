import 'package:flutter/material.dart';
import 'package:adaptive_english_learning_app/widgets/custom_scafford.dart';
import 'package:adaptive_english_learning_app/widgets/auth_widgets.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topToggle(isLogin: false),
                  const SizedBox(height: 30),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Start your personalized English learning experience",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "AI Personalization Available\nWe’ll customize your learning experience based on your goals.",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  inputField(
                    label: "Full Name",
                    hint: "John Doe",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),
                  inputField(
                    label: "Email",
                    hint: "you@example.com",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 16),
                  inputField(
                    label: "Password",
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Expanded(
                        child: Text(
                          "I agree to the Terms of Service and Privacy Policy",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  primaryButton("Create Account"),

                  const SizedBox(height: 20),
                  divider(),
                  const SizedBox(height: 20),

                  socialButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
