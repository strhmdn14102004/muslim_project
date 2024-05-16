import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim/helper/dimension.dart';
import 'package:muslim/module/auth/signup/signup_page.dart';
import 'package:muslim/module/home/home_page.dart';
import 'package:muslim/overlay/error_overlay.dart';
import 'package:muslim/widget/auth/email_field.dart';
import 'package:muslim/widget/auth/login_button.dart';

import '../../../widget/auth/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double _elementsOpacity = 1;
  bool loadingBallAppear = false;
  double loadingBallSize = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _errorMessage = '';
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      print('User signed in: ${userCredential.user!.email}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      // Show error message using ScaffoldMessenger
      Navigator.of(context).push(
        ErrorOverlay(
          message: "Login Gagal, Periksa Kembali Password Kamu",
        ),
      );

      print('Sign in error: $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 1, end: _elementsOpacity),
                    builder: (_, value, __) => Opacity(
                      opacity: value,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.mosque_outlined,
                              size: 60, color: Colors.blue),
                          SizedBox(height: 25),
                          Text(
                            "Selamat Datang",
                            style: TextStyle(fontSize: 35),
                          ),
                          Text(
                            "Login untuk melanjutkan",
                            style: TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        EmailField(
                            fadeEmail: _elementsOpacity == 0,
                            emailController: _emailController),
                        const SizedBox(height: 40),
                        PasswordField(
                            fadePassword: _elementsOpacity == 0,
                            passwordController: _passwordController),
                        SizedBox(height: Dimensions.size40),
                        LoginButton(
                          elementsOpacity: _elementsOpacity,
                          onTap: () async {
                            await _signInWithEmailAndPassword(context);
                            setState(() {
                              loadingBallAppear = true;
                            });
                          },
                        ),
                        const SizedBox(height: 300),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUp()));
                                  setState(() {});
                                },
                                child: const Text("Klik disini untuk daftar")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
