import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/auth/view/signin_page.dart';
import 'package:note_app/notes/view/notes_page.dart';
import '../cubit/auth_cubit.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    final success = await context.read<AuthCubit>().signup(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!success) {
      setState(() {
        error = 'Signup failed. Please try again.';
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFont(double base) => screenWidth < 600 ? base : base * 1.2;
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(fontSize: scaleFont(14)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a username' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: scaleFont(14)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter an email' : null,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: scaleFont(14)),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 20),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                  ),
                  onPressed: isLoading ? null : _signup,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const CircularProgressIndicator(),
                        )
                      : Text(
                          'Sign Up',
                          style: TextStyle(fontSize: scaleFont(16)),
                        ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SigninPage()),
                  ),
                  child: Text(
                    "Already have an account? Log in",
                    style: TextStyle(fontSize: scaleFont(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
