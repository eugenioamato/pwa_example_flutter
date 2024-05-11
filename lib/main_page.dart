import 'package:flutter/material.dart';
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
    return Card(
      child: Column(
        children: [
          Text('Welcome ${widget.user?.displayName}'),
          if (widget.user?.photoUrl != null &&
              (widget.user?.photoUrl ?? '').isNotEmpty)
            CircleAvatar(
              child: Image.network(widget.user!.photoUrl!),
            ),
        ],
      ),
    );
  }
}
