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
  List<dynamic>? tasks;
  Map<String, dynamic>? userData;
  bool _loadingTasks = false;

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
      // Load tasks after user data is fetched
      loadUserTasks();
    } else {
      setState(() {
        userData = {"message": "Failed to fetch user data."};
      });
    }
  }

  Future<void> loadUserTasks() async {
    if (_token == null || _loadingTasks) return;

    setState(() {
      _loadingTasks = true;
    });

    final response = await http.get(
      Uri.parse("http://localhost:3000/task/all"),
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        tasks = data['data'];
      });
    } else {}

    setState(() {
      _loadingTasks = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Loading..."),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(children: [
            const TextSpan(
                text: "Good Afternoon , ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextSpan(
                text: "${userData!["name"]}",
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 13))
          ]),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.notifications),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateTask(userId: userData!["userId"]))),
        },
        child: const Icon(Icons.add_circle_outline_rounded),
      ),
      body: tasks == null
          ? Center(child: CircularProgressIndicator())
          : tasks!.isEmpty
              ? Center(child: Text("No tasks found"))
              : ListView.builder(
                  itemCount: tasks!.length,
                  itemBuilder: (context, index) {
                    final task = tasks![index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text(task['title']),
                        subtitle: Text("Priority: ${task['priority']}"),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                    );
                  },
                ),
    );
  }
}
