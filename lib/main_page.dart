import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainPage extends StatefulWidget {
  final GoogleSignInAccount? user;
  const MainPage(this.user, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Text('Welcome ${widget.user?.displayName}'),
      ],
    ));
  }
}
