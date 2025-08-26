import 'package:flutter/material.dart';
import 'package:scoreboard_app/MyTextField.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: emailController,
                  isNumeric: false,
                  label: 'Email',
                ),
                MyTextField(
                  controller: passwordController,
                  isNumeric: false,
                  label: 'Password',
                ),
                const SizedBox(height: 16),
                // validates login
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signInWithPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed: $e')),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signUp(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign up failed: $e')),
                      );
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
