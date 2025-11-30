import 'package:flutter/material.dart';
import 'homescreen.dart';

class Edit extends StatelessWidget {
  const Edit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit / Home Redirect")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Homescreen()),
            );
          },
          child: const Text("Go to Home"),
        ),
      ),
    );
  }
}
