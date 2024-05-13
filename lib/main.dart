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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Center(
                  child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.scaleDown,
              )),
            ),
            const Spacer(flex: 4,),
            Expanded(
              flex: 8,
              child: Column(children: [
              Center(child: Text('Hallo!',style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 40),),),
              Center(child: Text('Log in op uw account!',style: Theme.of(context).textTheme.titleSmall,),),
                const SizedBox(height: 40.0,),
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SignInButton(
                    Buttons.google,
                    text: "Sign up with Google",
                    onPressed: _login
                  ),
                ),
              ),
              Text(_label),
              ],),
            ),
            const Spacer(flex: 4,),
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
      'https://www.googleapis.com/auth/calendar.readonly',
    ];

    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: scopes,
    );

    try {
      final result = await googleSignIn.signIn();
      _openMainPage(result, googleSignIn);
    } catch (error) {
      setState(() {
        _label = '>>>$error';
      });
    }
  }

  void _openMainPage(GoogleSignInAccount? result, GoogleSignIn googleSignIn) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MainPage(result, googleSignIn)));
  }
}
