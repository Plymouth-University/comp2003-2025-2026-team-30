import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  

  const CustomScaffold({ super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset('assets/images/bgLogn.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          ),
          SafeArea(child: child)
        ],
      ),
    );
  }
}