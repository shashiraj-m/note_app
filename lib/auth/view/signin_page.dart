import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/auth/auth_status.dart';
import 'package:note_app/auth/cubit/auth_cubit.dart';
import 'package:note_app/auth/view/signup_page.dart';
import 'package:note_app/notes/view/notes_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SigninPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorText;
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorText = null;
    });

    final result = await context.read<AuthCubit>().login(email, password);

    if (!mounted) return;
    setState(() {
      isLoading = false;
      if (!result) {
        errorText = 'Invalid email or password';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFont(double base) => screenWidth < 600 ? base : base * 1.2;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.authenticated,
      listener: (context, state) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const NotesPage()));
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: scaleFont(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: scaleFont(14)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: scaleFont(14)),
                  ),
                  obscureText: true,
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const CircularProgressIndicator(),
                        )
                      : Text(
                          "Login",
                          style: TextStyle(fontSize: scaleFont(16)),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(fontSize: scaleFont(14)),
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
