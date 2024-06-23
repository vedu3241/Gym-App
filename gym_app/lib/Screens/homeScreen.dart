import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DashBoard"),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(child: Text("Coming soon..")),
    );
  }
}
