
import 'package:flutter/material.dart';
import 'package:untitled3/screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashier System',
    //  home: TableSelection(),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
