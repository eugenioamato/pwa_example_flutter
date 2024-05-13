import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  final GoogleSignInAccount? user;
  final GoogleSignIn googleSignIn;
  const MainPage(this.user, this.googleSignIn, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SliverGridDelegateWithMaxCrossAxisExtent _gridDelegate =
      const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300);

  @override
  void initState() {
    super.initState();
    _loadCalendar(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user?.displayName?.split(" ").first ?? '?';
    String photoUrl = '';
    if (widget.user?.photoUrl != null &&
        (widget.user?.photoUrl ?? '').isNotEmpty) {
      photoUrl = widget.user!.photoUrl!;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Image.network(photoUrl),
        backgroundColor: Colors.brown.shade100.withOpacity(0.4),
        title: Row(
          children: [
            Text(
              'Goedemorgen, $name',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Image.asset('assets/images/Hand.png'),
          ],
        ),
        actions: [
          Center(
            child: GestureDetector(
              onTap: () => _logout(widget.googleSignIn),
              child: const Text('  Logout  '),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.orange.shade100.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: GridView(
              gridDelegate: _gridDelegate,
              children: _events.map((e) {
                String meetingPersonName = '?';
                if (e['organizer'] != null && e['organizer'].isNotEmpty) {
                  if (e['organizer']['displayName'] != null &&
                      e['organizer']['displayName'].isNotEmpty) {
                    meetingPersonName = e['organizer']['displayName'];
                  } else {
                    meetingPersonName = e['organizer']['email'];
                  }
                }
                DateTime dateTime = DateTime.parse(e['start']['dateTime']);
                var meetingUrl = '';
                if (e['hangoutLink'] != null && e['hangoutLink'].isNotEmpty) {
                  meetingUrl = e['hangoutLink'];
                }

                return GestureDetector(
                  onTap: () => launchUrl(Uri.parse(meetingUrl)),
                  child: Card(
                    child: Center(
                      child: Text(
                        'Eerst volgende afspraak met $meetingPersonName at $dateTime',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  _loadCalendar(GoogleSignInAccount? user) async {
    if (user == null) return;
    final authResult = await user.authentication;
    final String accessToken = authResult.accessToken ?? '';
    if (accessToken.isEmpty) return;

    const String url =
        'https://www.googleapis.com/calendar/v3/users/me/calendarList';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken'
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    Map<String, dynamic>? mainCalendar;

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
      DateTime nextMeetingTime = DateTime.now().add(const Duration(days: 3650));

      for (final event in data['items']) {
        print('>>> $event');
        if (event['hangoutLink'] == null) continue;

        print('has start ${event['start']}');
        print('has starttime ${event['start']['dateTime']}');

        DateTime eventTime = DateTime.parse(event['start']['dateTime']);
        if (eventTime.isBefore(nextMeetingTime)) {
          _events.clear();
          _events.add(event);
        }
      }
      setState(() {});
    } else {
      print('error ${response.statusCode}');
      print(response.body);
      print(response.reasonPhrase);
    }
  }

  final List<Map<String, dynamic>> _events = [];

  void _logout(GoogleSignIn googleSignIn) async {
    await googleSignIn.signOut();
    _pop();
  }

  void _pop() {
    Navigator.of(context).pop();
  }
}
