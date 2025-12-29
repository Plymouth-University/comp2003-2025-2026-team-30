import 'package:flutter/material.dart';

Widget topToggle({required bool isLogin}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLogin ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "Login",
                style: TextStyle(
                  color: isLogin ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: !isLogin ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: !isLogin ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget inputField({
  required String label,
  required String hint,
  required IconData icon,
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 6),
      TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );
}

Widget primaryButton(String text) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(text),
    ),
  );
}

Widget divider() {
  return Row(
    children: const [
      Expanded(child: Divider()),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text("Or continue with"),
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
          label: const Text("Google"),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.code),
          label: const Text("GitHub"),
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
      Text(text),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );
}