import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/createtask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Boarding extends StatefulWidget {
  const Boarding({super.key});

  @override
  State<Boarding> createState() => _BoardingState();
}

class _BoardingState extends State<Boarding> {
  String? _token;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    if (token == null) {
      setState(() {
        userData = {"message": "No token found. Please log in again."};
      });
      return;
    }
    setState(() {
      _token = token;
    });

    final response = await http.post(
      Uri.parse("http://localhost:3000/userData"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userData = data['data'];
      });
    } else {
      setState(() {
        userData = {"message": "Failed to fetch user data."};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "Good Afternoon , ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(
              text: "${userData!["name"]}",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13))
        ])),
        actions: <Widget>[
          IconButton(
            onPressed: () => {},
            icon: Icon(Icons.notifications),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Createtask()))
        },
        child: Icon(Icons.add_circle_outline_rounded),
      ),
    );
  }
}
