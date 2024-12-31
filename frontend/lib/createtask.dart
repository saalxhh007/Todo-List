import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/boarding.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateTask extends StatefulWidget {
  final int userId;
  const CreateTask({super.key, required this.userId});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String? selectedCategory;
  String? selectedPriority;

  final _formGlobalKey = GlobalKey<FormState>();

  List<String> categories = ['Personal', 'Work', 'Health'];
  String todayDate = DateFormat("dd/MM/yyyy").format(DateTime.now());

  Future<void> selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        endDateController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  List<Widget> createPriorityButtons() {
    List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];
    return priorities.map((priority) {
      bool isSelected = selectedPriority == priority;
      Color backgroundColor;
      Color textColor;

      switch (priority) {
        case 'Low':
          backgroundColor = isSelected ? Colors.green : Colors.white;
          textColor = isSelected ? Colors.white : Colors.green;
          break;
        case 'Medium':
          backgroundColor = isSelected ? Colors.yellow : Colors.white;
          textColor = isSelected ? Colors.black : Colors.yellow;
          break;
        case 'High':
          backgroundColor = isSelected ? Colors.orange : Colors.white;
          textColor = isSelected ? Colors.white : Colors.orange;
          break;
        case 'Urgent':
          backgroundColor = isSelected ? Colors.red : Colors.white;
          textColor = isSelected ? Colors.white : Colors.red;
          break;
        default:
          backgroundColor = Colors.white;
          textColor = Colors.black;
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: backgroundColor),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            priority,
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }).toList();
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateFormat("dd/MM/yyyy").parse(date);
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  void fetchData() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    final Map<String, dynamic> taskData = {
      'title': nameController.text,
      'description': descriptionController.text,
      'end_date': formatDate(endDateController.text),
      'priority': selectedPriority,
      'status': 'Pending',
    };

    if (taskData.values.contains(null) || taskData.values.contains("")) {
      return;
    }

    print("Task Data: $taskData");

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/task/create"),
        headers: {
          "Content-Type": "application/json",
          "token": "Bearer $token",
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode != 201) {
        print("Error: $response");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Create New Task",
          style: TextStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formGlobalKey,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Task Title",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a task title.";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Task Description"),
                    SizedBox(height: 5),
                    Divider(color: Colors.grey, thickness: 1),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: descriptionController,
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Task Description",
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a task description.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    const Text(
                      "End: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: endDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Select End Date",
                        ),
                        onTap: selectEndDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select an end date.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          "Category",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: categories.map((category) {
                        bool isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, right: 20, left: 20),
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.blue,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          "Priority",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: createPriorityButtons(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 360,
                margin: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formGlobalKey.currentState!.validate()) {
                      fetchData();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Boarding()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Create Task",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
