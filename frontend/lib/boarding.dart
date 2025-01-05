import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo_list/createtask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/constant.dart';
import 'package:todo_list/pomodoro.dart';
import 'package:todo_list/signup.dart';
import 'package:todo_list/taskWidget.dart';
import 'package:todo_list/updatetask.dart';
import 'package:intl/intl.dart';

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

class Boarding extends StatefulWidget implements PreferredSizeWidget {
  const Boarding({super.key});

  @override
  State<Boarding> createState() => _BoardingState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BoardingState extends State<Boarding> {
  String? _token;
  Map<String, dynamic>? userData;
  String searchQuery = "";

  final List<Task> alltasks = [];
  late List<Task> pendingTasks = [];
  late List<Task> completedTasks = [];
  late List<Task> filteredAllTasks = [];
  late List<Task> filteredPendingTasks = [];
  late List<Task> filteredCompletedTasks = [];

  @override
  void initState() {
    super.initState();
    filteredAllTasks = alltasks;
    filteredPendingTasks = pendingTasks;
    filteredCompletedTasks = completedTasks;
    loadUserData();
    loadUserTasks();
    loadUserPendingTasks();
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
            bool isCompleted = false;
            for (var task in fetchedTasks) {
              isCompleted = false;
              if (task['status'] == "Pending") {
                isCompleted = false;
              } else {
                isCompleted = true;
              }

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
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to load tasks: ${response.statusCode}')),
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

  Future<void> loadUserPendingTasks() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/task/pending"),
        headers: {"Content-Type": "application/json", "token": "$token"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> fetchedPendingTasks = responseData['data'];
        if (mounted) {
          setState(() {
            pendingTasks.clear();
            bool isCompleted = false;
            for (var task in fetchedPendingTasks) {
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

              pendingTasks.add(Task(
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
            filteredPendingTasks = List.from(pendingTasks);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to load tasks: ${response.statusCode}')),
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

  Future<void> loadUserCompletedTasks() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/task/completed"),
        headers: {"Content-Type": "application/json", "token": "$token"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> fetchedCompletedTasks = responseData['data'];
        if (mounted) {
          setState(() {
            completedTasks.clear();
            bool isCompleted = true;
            for (var task in fetchedCompletedTasks) {
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

              completedTasks.add(Task(
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
            filteredCompletedTasks = List.from(completedTasks);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to load tasks: ${response.statusCode}')),
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

  // Filters tasks based on the search query.
  void filterTasks(String query) {
    setState(() {
      searchQuery = query;
      filteredAllTasks = alltasks
          .where(
              (task) => task.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Updates a specific task in the list and refreshes the filtered tasks.
  void updateTask(Task updatedTask) {
    setState(() {
      final index = alltasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        alltasks[index] = updatedTask;
        filterTasks(searchQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0x00eef4fd),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(
                text: "Good Afternoon, ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextSpan(
                text: userData?["name"] ?? "Guest",
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 15),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Pomodoro()));
            },
            icon: const Icon(
              Icons.timer,
              color: Colors.black,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () async {
              final preferences = await SharedPreferences.getInstance();
              await preferences.remove("AuthToken");

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: filterTasks,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (alltasks.isEmpty) {
                        noTaskWarning(context);
                      } else {
                        deleteAllTasks(context, () {
                          setState(() {
                            alltasks.clear();
                            filteredAllTasks.clear();
                            pendingTasks.clear();
                            filteredAllTasks.clear();
                          });
                        });
                      }
                    },
                    icon: const Icon(Icons.delete, size: 30, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Task progress bar and task count
            Container(
              decoration: BoxDecoration(
                  color: colorFromHex("#FF80C3"),
                  borderRadius: BorderRadius.circular(25)),
              margin: const EdgeInsets.only(top: 10),
              width: 350,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tasks In Progress",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text(
                          "${alltasks.where((task) => task.isCompleted).length}/${alltasks.length} tasks remaining",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: alltasks.isEmpty
                          ? 0.0
                          : alltasks.where((task) => task.isCompleted).length /
                              alltasks.length,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Divider(thickness: 2, indent: 100),
            ),
            const Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "All Tasks",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // List of tasks or message if all tasks are completed.
            Expanded(
              child: filteredAllTasks.isNotEmpty
                  ? ListView.builder(
                      itemCount: alltasks.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          direction: DismissDirection.horizontal,
                          onDismissed: (_) async {
                            final taskId = alltasks[index].id;
                            try {
                              final response = await http.post(
                                Uri.parse("http://10.0.2.2:3000/task/delete"),
                                headers: {
                                  "Content-Type": "application/json",
                                  "token": _token ?? "",
                                },
                                body: jsonEncode({"taskId": taskId}),
                              );

                              setState(() {
                                alltasks
                                    .removeWhere((task) => task.id == taskId);
                                filterTasks(searchQuery);
                              });
                            } catch (e) {
                              print("Error deleting task: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'An error occurred while deleting the task.')),
                              );
                            }
                          },
                          key: Key(alltasks[index].id.toString()),
                          background: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.red, size: 30),
                              SizedBox(width: 8),
                              Text("Task Deleted!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          child: TaskWidget(
                            title: alltasks[index].title,
                            description: alltasks[index].description,
                            date: alltasks[index].startDate,
                            time: alltasks[index].startTime,
                            isCompleted: alltasks[index].isCompleted,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateTask(task: alltasks[index]),
                                ),
                              ).then((updatedTask) {
                                if (updatedTask != null) {
                                  updateTask(updatedTask);
                                }
                              });
                            },
                            onCheck: (isChecked) async {
                              final taskId = alltasks[index].id;
                              if (isChecked) {
                                try {
                                  final response = await http.post(
                                    Uri.parse(
                                        "http://10.0.2.2:3000/task/updateStatus"),
                                    headers: {
                                      "Content-Type": "application/json",
                                      "token": _token ?? "",
                                    },
                                    body: jsonEncode({
                                      "taskId": taskId,
                                      "status": "Completed"
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    setState(() {
                                      completedTasks.add(alltasks[index]);
                                      pendingTasks.removeAt(index);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to update task status: ${response.statusCode}')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'An error occurred while updating task status.')),
                                  );
                                }
                              }
                              setState(() {
                                alltasks[index].isCompleted = isChecked;
                              });
                            },
                            task: null,
                          ),
                        );
                      },
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("All tasks are completed!",
                            style: TextStyle(fontSize: 16))
                      ],
                    ),
            ),
            const Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Pending Tasks",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // List of pending tasks tasks or message if all tasks are completed.
            Expanded(
              child: filteredPendingTasks.isNotEmpty
                  ? ListView.builder(
                      itemCount: pendingTasks.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          direction: DismissDirection.horizontal,
                          onDismissed: (_) async {
                            final taskId = pendingTasks[index].id;
                            try {
                              final response = await http.post(
                                Uri.parse("http://10.0.2.2:3000/task/delete"),
                                headers: {
                                  "Content-Type": "application/json",
                                  "token": _token ?? "",
                                },
                                body: jsonEncode({"taskId": taskId}),
                              );

                              setState(() {
                                pendingTasks
                                    .removeWhere((task) => task.id == taskId);
                                filterTasks(searchQuery);
                              });
                            } catch (e) {
                              print("Error deleting task: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'An error occurred while deleting the task.')),
                              );
                            }
                          },
                          key: Key(pendingTasks[index].id.toString()),
                          background: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.red, size: 30),
                              SizedBox(width: 8),
                              Text("Task Deleted!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          child: TaskWidget(
                            title: pendingTasks[index].title,
                            description: pendingTasks[index].description,
                            date: pendingTasks[index].startDate,
                            time: pendingTasks[index].startTime,
                            isCompleted: pendingTasks[index].isCompleted,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateTask(task: pendingTasks[index]),
                                ),
                              ).then((updatedTask) {
                                if (updatedTask != null) {
                                  updateTask(updatedTask);
                                }
                              });
                            },
                            onCheck: (isChecked) {
                              setState(() {
                                pendingTasks[index].isCompleted = isChecked;
                              });
                            },
                            task: null,
                          ),
                        );
                      },
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("All tasks are completed!",
                            style: TextStyle(fontSize: 16))
                      ],
                    ),
            ),
            const Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Completed Tasks",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: completedTasks.isNotEmpty
                  ? ListView.builder(
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          direction: DismissDirection.horizontal,
                          onDismissed: (_) async {
                            final taskId = completedTasks[index].id;
                            try {
                              final response = await http.post(
                                Uri.parse("http://10.0.2.2:3000/task/delete"),
                                headers: {
                                  "Content-Type": "application/json",
                                  "token": _token ?? "",
                                },
                                body: jsonEncode({"taskId": taskId}),
                              );

                              setState(() {
                                completedTasks
                                    .removeWhere((task) => task.id == taskId);
                                filterTasks(searchQuery);
                              });
                            } catch (e) {
                              print("Error deleting task: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'An error occurred while deleting the task.')),
                              );
                            }
                          },
                          key: Key(completedTasks[index].id.toString()),
                          background: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.red, size: 30),
                              SizedBox(width: 8),
                              Text("Task Deleted!",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          child: TaskWidget(
                            title: completedTasks[index].title,
                            description: completedTasks[index].description,
                            date: completedTasks[index].startDate,
                            time: completedTasks[index].startTime,
                            isCompleted: completedTasks[index].isCompleted,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateTask(task: completedTasks[index]),
                                ),
                              ).then((updatedTask) {
                                if (updatedTask != null) {
                                  updateTask(updatedTask);
                                }
                              });
                            },
                            onCheck: (isChecked) {
                              setState(() {
                                completedTasks[index].isCompleted = isChecked;
                              });
                            },
                            task: null,
                          ),
                        );
                      },
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No Task is completed!",
                            style: TextStyle(fontSize: 16))
                      ],
                    ),
            ),
          ],
        ),
      ),
      // Floating action button to create a new task.
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: "Create a new task",
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Createtask()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
