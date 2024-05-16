import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim/helper/dimension.dart';
import 'package:muslim/module/auth/login/login_page.dart';
import 'package:muslim/overlay/success_overlay.dart';
import 'package:muslim/widget/auth/email_field.dart';
import 'package:muslim/widget/auth/signup_button.dart';

import '../../../widget/auth/password_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  double _elementsOpacity = 1;
  bool loadingBallAppear = false;
  double loadingBallSize = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _signupSuccess = false;

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  Future<void> _signUpWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _errorMessage = '';
        _signupSuccess = true;
      });
      Navigator.of(context).push(
        SuccessOverlay(
          message:
              "Regist Akun Dengan Email\n${userCredential.user!.email}\nBerhasil",
        ),
      );
      setState(() {});
      print('User signed up: ${userCredential.user!.email}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Sign up error: $_errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
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
                          "Register Akun\nBaru",
                          style: TextStyle(fontSize: 30),
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
                      SignUpButton(
                        elementsOpacity: _elementsOpacity,
                        onTap: () async {
                          await _signUpWithEmailAndPassword();
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
                                          const LoginScreen()));
                              setState(() {});
                            },
                            child: const Text("Klik disini untuk login"),
                          ),
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
    );
  }
}
