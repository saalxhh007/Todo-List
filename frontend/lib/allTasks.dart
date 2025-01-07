import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/taskWidget.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.isCompleted,
  });
}

class Alltasks extends StatefulWidget {
  const Alltasks({super.key});

  @override
  State<Alltasks> createState() => _AlltasksState();
}

class _AlltasksState extends State<Alltasks> {
  String? _token;
  Map<String, dynamic>? userData;
  final List<Task> alltasks = [];
  late List<Task> filteredAllTasks = [];
  @override
  void initState() {
    super.initState();
    filteredAllTasks = alltasks;
    loadUserData();
    loadUserTasks();
  }

  Future<void> loadUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    if (token == null) {
      if (mounted) {
        setState(() {
          userData = {"message": "No token found. Please log in again."};
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _token = token;
      });
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/userData"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            userData = data['data'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            userData = {"message": "Failed to fetch user data."};
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userData = {"message": "An error occurred while fetching user data."};
        });
      }
    }
  }

  Future<void> loadUserTasks() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/task/all"),
        headers: {"Content-Type": "application/json", "token": "$token"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> fetchedTasks = responseData['data'];

        if (mounted) {
          setState(() {
            alltasks.clear();
            if (fetchedTasks.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No tasks available.')),
              );
            } else {
              for (var task in fetchedTasks) {
                bool isCompleted = task['status'] != "Pending";

                final id = task['task_id'] ?? 0;
                final title = task['title'] ?? "Untitled";
                final description = task['description'] ?? "No description";
                final startDate = task['start_date'];
                final endDate = task['end_date'];

                final parsedStart =
                    startDate != null ? DateTime.parse(startDate) : null;
                final parsedStartDate = parsedStart != null
                    ? DateFormat('yyyy-MM-dd').format(parsedStart)
                    : "Unknown date";
                final parsedStartTime = parsedStart != null
                    ? DateFormat('hh:mm a').format(parsedStart)
                    : "Unknown time";

                final parsedEnd =
                    endDate != null ? DateTime.parse(endDate) : null;
                final parsedEndDate = parsedEnd != null
                    ? DateFormat('yyyy-MM-dd').format(parsedEnd)
                    : "Unknown date";
                final parsedEndTime = parsedEnd != null
                    ? DateFormat('hh:mm a').format(parsedEnd)
                    : "Unknown time";

                alltasks.add(Task(
                  id: id,
                  title: title,
                  description: description,
                  startDate: parsedStartDate,
                  startTime: parsedStartTime,
                  endDate: parsedEndDate,
                  endTime: parsedEndTime,
                  isCompleted: isCompleted,
                ));
              }
              filteredAllTasks = List.from(alltasks);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to load All tasks: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while fetching tasks.')),
        );
      }
    }
  }

  void updateTask(Task updatedTask) {
    setState(() {
      final index = alltasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        alltasks[index] = updatedTask;
      }
    });
  }

  void filterTasks(String query) {
    setState(() {
      filteredAllTasks = alltasks.where((task) {
        final titleLower = task.title.toLowerCase();
        final descriptionLower = task.description.toLowerCase();
        final queryLower = query.toLowerCase();

        return titleLower.contains(queryLower) ||
            descriptionLower.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (text) {
                filterTasks(text);
              },
            ),
          ),
        ),
      ),
      body: Expanded(
        child: filteredAllTasks.isNotEmpty
            ? ListView.builder(
                itemCount: filteredAllTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredAllTasks[index];
                  return Dismissible(
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) async {
                      final taskId = task.id;
                      try {
                        await http.post(
                          Uri.parse("http://10.0.2.2:3000/task/delete"),
                          headers: {
                            "Content-Type": "application/json",
                            "token": _token ?? "",
                          },
                          body: jsonEncode({"taskId": taskId}),
                        );

                        setState(() {
                          alltasks.removeWhere((t) => t.id == taskId);
                          filteredAllTasks.removeWhere((t) => t.id == taskId);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'An error occurred while deleting the task.'),
                          ),
                        );
                      }
                    },
                    key: Key(task.id.toString()),
                    background: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 30),
                        SizedBox(width: 8),
                        Text("Task Deleted!",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    child: TaskWidget(
                      title: task.title,
                      description: task.description,
                      start_date: task.startDate,
                      start_time: task.startTime,
                      end_date: task.endDate,
                      end_time: task.endTime,
                      isCompleted: task.isCompleted,
                      onTap: () {},
                      onCheck: (isChecked) async {
                        final taskId = task.id;
                        if (isChecked) {
                          try {
                            final response = await http.post(
                              Uri.parse(
                                  "http://10.0.2.2:3000/task/updateStatus/$taskId"),
                              headers: {
                                "Content-Type": "application/json",
                                "token": _token ?? "",
                              },
                              body: jsonEncode({"status": "Completed"}),
                            );

                            if (response.statusCode == 200) {
                              setState(() {
                                task.isCompleted = true;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to update task status: ${response.statusCode}'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'An error occurred while updating task status.')),
                            );
                          }
                        } else {
                          setState(() {
                            task.isCompleted = false;
                          });
                        }
                      },
                      task: null,
                    ),
                  );
                },
              )
            : const Center(
                child: Text("All tasks are completed!",
                    style: TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}
