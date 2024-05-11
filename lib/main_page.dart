import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  final GoogleSignInAccount? user;
  final GoogleSignIn googleSignIn;
  const MainPage(this.user, this.googleSignIn, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Center(
              child: Card(
                child: Column(
                  children: [
                    Text('Welcome ${widget.user?.displayName}'),
                    if (widget.user?.photoUrl != null &&
                        (widget.user?.photoUrl ?? '').isNotEmpty)
                      CircleAvatar(
                        child: Image.network(widget.user!.photoUrl!),
                      ),
                    TextButton(
                        onPressed: () => _loadCalendar(widget.user),
                        child: const Text('LOAD CALENDAR')),
                  ],
                ),
              ),
            ),
            Column(
              children: _events
                  .map((e) => Card(
                        child: Text(
                          e,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black),
                        ),
                      ))
                  .toList(),
            ),
            Card(
              child: Center(
                child: GestureDetector(
                  child: Text('logout'),
                  onTap: () => _logout(widget.googleSignIn),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _loadCalendar(GoogleSignInAccount? user) async {
    print('LOADING CCALENDAR FOR $user');
    if (user == null) return;
    final authResult = await user.authentication;
    print('auth is $authResult');
    final String accessToken = authResult.accessToken ?? '';
    print('accessToken is $accessToken');
    if (accessToken.isEmpty) return;

    // Construct the GET request URL
    const String url =
        'https://www.googleapis.com/calendar/v3/users/me/calendarList';

    // Set up headers with authorization
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken'
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    var mainCalendar;

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(response.body);
      final items = data['items'];
      for (final calendar in items) {
        if (calendar.containsKey('primary') && calendar['primary'] == true) {
          mainCalendar = calendar;
          break;
        }
      }
    } else {
      // Handle error (e.g., print error message)
      print('Error fetching calendar list: ${response.statusCode}');
      return;
    }
    _loadEvents(mainCalendar, accessToken);
  }

  void _loadEvents(mainCalendar, accessToken) async {
    if (mainCalendar == null) return;
    final calendarId = mainCalendar['id'];
    final DateTime startTime = DateTime.now();
    final DateTime endTime = DateTime.now().add(const Duration(days: 356));

    final DateFormat rfc3339 = DateFormat('yyyy-MM-ddTHH:mm:ssZ');
// Format times in RFC 3339 format
    final String formattedStartTime = '${rfc3339.format(startTime.toUtc())}Z';
    final String formattedEndTime = '${rfc3339.format(endTime.toUtc())}Z';

    final String url =
        'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?timeMin=$formattedStartTime&timeMax=$formattedEndTime';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken'
    };
    print('starting query at ');
    print(url);
    print(headers);

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('RESPONSE from LOADEVENTS:');
      for (final event in data['items']) {
        print(event);
        _events.add(event.toString());
      }
      setState(() {});
    } else {
      print('error ${response.statusCode}');
      print(response.body);
      print(response.reasonPhrase);
    }
  }

  final List<String> _events = [];

  void _logout(GoogleSignIn googleSignIn) async {
    await googleSignIn.signOut();
    _pop();
  }

  void _pop() {
    Navigator.of(context).pop();
  }
}
