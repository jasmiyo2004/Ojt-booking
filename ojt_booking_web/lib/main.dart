import 'package:flutter/material.dart';
import 'views/landing_page.dart';

void main() {
  runApp(const GothongApp());
}

class GothongApp extends StatelessWidget {
  const GothongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LandingPage(),
    );
  }
}
