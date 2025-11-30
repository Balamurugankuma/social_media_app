import 'package:flutter/material.dart';
import 'package:untitled14/presentation/repository.dart';

class reset_password extends StatefulWidget {
  const reset_password({super.key});

  @override
  State<reset_password> createState() => _reset_passwordState();
}

class _reset_passwordState extends State<reset_password> {
  final TextEditingController _emailcontroller = TextEditingController();
  bool is_loading = false;

  Future<void> Reset_password() async {
    if (_emailcontroller.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter email")));
      return;
    }

    try {
      setState(() {
        is_loading = true;
      });

      await authRepository.resetPassword(_emailcontroller.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset link sent to this email address")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        is_loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: TextField(
                controller: _emailcontroller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Enter email',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          is_loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: Reset_password,
                  child: const Text(
                    "Send",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
