// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital WijkVerpleging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Digital WijkVerpleging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _label = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Center(
                child: Image.asset(
              'assets/images/nurses.png',
              fit: BoxFit.scaleDown,
            )),
            Center(
              child: SizedBox(
                width: min(MediaQuery.of(context).size.width, 400.0),
                height: 80.0,
                child: SignInButton(
                  Buttons.google,
                  text: "Sign up with Google",
                  onPressed: _login,
                ),
              ),
            ),
            Text(_label),
          ],
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _label = '';
    });
    const List<String> scopes = <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ];

    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: scopes,
    );

    try {
      final result = await googleSignIn.signIn();
      _openMainPage(result);
    } catch (error) {
      setState(() {
        _label = '>>>$error';
      });
    }
  }

  void _openMainPage(GoogleSignInAccount? result) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MainPage(result)));
  }
}
