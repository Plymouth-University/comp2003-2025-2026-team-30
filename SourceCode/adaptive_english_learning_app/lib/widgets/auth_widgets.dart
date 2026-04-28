import 'package:flutter/material.dart';

import 'translated_text.dart';

/// ===========================
/// TOP LOGIN / SIGNUP TOGGLE
/// ===========================
Widget topToggle({
  required bool isLogin,
  required VoidCallback onLoginTap,
  required VoidCallback onSignUpTap,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLoginTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLogin ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: TranslatedText(
                  "Login",
                  style: TextStyle(
                    color: isLogin ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onSignUpTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !isLogin ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: TranslatedText(
                  "Sign Up",
                  style: TextStyle(
                    color: !isLogin ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// ===========================
/// INPUT FIELD
/// ===========================
Widget inputField({
  required String label,
  required String hint,
  required IconData icon,
  TextEditingController? controller,
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TranslatedText(label),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ],
  );
}

/// ===========================
/// PRIMARY BUTTON
/// ===========================
Widget primaryButton(String text, {required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: TranslatedText(text, style: const TextStyle(fontSize: 16)),
    ),
  );
}

Widget divider() {
  return Row(
    children: const [
      Expanded(child: Divider()),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: TranslatedText("Or continue with"),
      ),
      Expanded(child: Divider()),
    ],
  );
}

Widget socialButtons() {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata),
          label: const TranslatedText("Google"),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.code),
          label: const TranslatedText("GitHub"),
        ),
      ),
    ],
  );
}

Widget bottomText({
  required String text,
  required String action,
  required VoidCallback onTap,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TranslatedText(text),
      TextButton(onPressed: onTap, child: TranslatedText(action)),
    ],
  );
}
