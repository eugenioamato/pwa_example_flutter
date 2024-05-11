// ignore_for_file: depend_on_referenced_packages

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInButton(
              Buttons.google,
              text: "Sign up with Google",
              onPressed: _login,
            )
          ],
        ),
      ),
    );
  }

  void _login() async {
    const List<String> scopes = <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ];

    GoogleSignIn googleSignIn = GoogleSignIn(
      // Optional clientId
      // clientId: '234509107532-bq7ttddccrur7rt1c6duubv0vsmsbine.apps.googleusercontent.com',
      scopes: scopes,
    );

    try {
      final result = await googleSignIn.signIn();
      print('>>>$result');
      _openMainPage(result);
    } catch (error) {
      print('>>>$error');
    }
  }

  void _openMainPage(GoogleSignInAccount? result) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MainPage(result)));
  }
}
