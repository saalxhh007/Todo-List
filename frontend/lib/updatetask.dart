import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/boarding.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/constant.dart';

class UpdateTask extends StatefulWidget {
  final Task task;

  const UpdateTask({
    super.key,
    required this.task,
  });

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

@override
class _UpdateTaskState extends State<UpdateTask> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<String> categories = ['Work', 'Personal', 'Shopping', 'Fitness'];
  String? selectedCategory;

  List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];
  String? selectedPriority;

  List<Widget> createPriorityButtons() {
    return priorities.map((priority) {
      bool isSelected = selectedPriority == priority;
      Color backgroundColor;
      Color textColor;
      Color borderColor;

      switch (priority) {
        case 'Low':
          backgroundColor =
              isSelected ? Colors.green.shade300 : Colors.transparent;
          textColor = isSelected ? Colors.white : Colors.green;
          borderColor = Colors.green.shade300;
          break;
        case 'Medium':
          backgroundColor =
              isSelected ? Colors.yellow.shade300 : Colors.transparent;
          textColor = isSelected ? Colors.white : Colors.yellow;
          borderColor = Colors.yellow.shade300;
          break;
        case 'High':
          backgroundColor =
              isSelected ? Colors.orange.shade300 : Colors.transparent;
          textColor = isSelected ? Colors.white : Colors.orange;
          borderColor = Colors.orange.shade300;
          break;
        case 'Urgent':
          backgroundColor =
              isSelected ? Colors.red.shade300 : Colors.transparent;
          textColor = isSelected ? Colors.white : Colors.red;
          borderColor = Colors.red.shade300;
          break;
        default:
          backgroundColor = Colors.white;
          textColor = Colors.black;
          borderColor = Colors.transparent;
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = priority;
          });
        },
        child: Container(
          padding:
              const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
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

  void fetchData() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");
    startDate ??= DateTime.now();
    startTime ??= TimeOfDay.now();

    DateTime combinedStartDateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    DateTime combinedEndDateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endDate!.hour,
      endDate!.minute,
    );

    final Map<String, dynamic> taskData = {
      "taskId": widget.task.id,
      "title": nameController.text,
      "description": descriptionController.text,
      "priority": selectedPriority ?? "",
      "category": selectedCategory ?? "",
      "start_date": combinedStartDateTime.toIso8601String(),
      "end_date": combinedEndDateTime.toIso8601String()
    };
    try {
      final response = await http.post(
          Uri.parse("http://10.0.2.2:3000/task/update/${taskData["taskId"]}"),
          headers: {
            "Content-Type": "application/json",
            "token": "Bearer $token"
          },
          body: jsonEncode(taskData));
      if (response.statusCode == 201) {
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    nameController.text = widget.task.title;
    descriptionController.text = widget.task.description;

    startDate = DateTime.parse(widget.task.startDate);
    endDate = DateTime.parse(widget.task.endDate);

    startTime = TimeOfDay.fromDateTime(
        DateFormat('hh:mm a').parse(widget.task.startTime));

    endTime = TimeOfDay.fromDateTime(
        DateFormat('hh:mm a').parse(widget.task.endTime));

    selectedCategory = widget.task.category;
    selectedPriority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Update A Task"),
        ),
        body: Container(
          color: const Color.fromARGB(255, 243, 241, 241),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopSideTexts(textTheme),
                const SizedBox(height: 20),
                _buildTaskTitleField(),
                const SizedBox(height: 20),
                _buildTaskDescriptionField(),
                const SizedBox(height: 20),
                _buildStartAndEndDatePickers(context),
                const SizedBox(height: 20),
                _buildPriorityPicker(),
                const SizedBox(height: 20),
                _buildCategoryPicker(),
                const SizedBox(height: 20),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSideTexts(TextTheme textTheme) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Divider(
              thickness: 2,
            ),
          ),
          Text(
            "Update A Task",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          SizedBox(
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          cursorColor: Colors.black,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Task Title",
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: EdgeInsets.only(bottom: 6, top: 0, left: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Task Description"),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          cursorColor: Colors.black,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "",
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: EdgeInsets.only(bottom: 6, top: 0, left: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildStartAndEndDatePickers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStartDatePicker(
              context,
              title: "Start Date",
              selectedDate: startDate,
              selectedTime: startTime,
              onDatePicked: (date) => setState(() => startDate = date),
              onTimePicked: (time) => setState(() => startTime = time),
            ),
          ],
        ),
        Row(
          children: [
            _buildEndDatePicker(
              context,
              title: "End Date",
              selectedDate: endDate,
              selectedTime: endTime,
              onDatePicked: (date) => setState(() => endDate = date),
              onTimePicked: (time) => setState(() => endTime = time),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartDatePicker(
    BuildContext context, {
    required String title,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimePicked,
    required DateTime? selectedDate,
    required Function(DateTime) onDatePicked,
  }) {
    return Container(
      width: 370,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      onTimePicked(pickedTime);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedTime != null
                          ? selectedTime.format(context)
                          : TimeOfDay.now().format(context),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      onDatePicked(pickedDate);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      selectedDate != null
                          ? DateFormat("dd/MM/yyyy").format(selectedDate)
                          : DateFormat("dd/MM/yyyy").format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDatePicker(
    BuildContext context, {
    required String title,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimePicked,
    required DateTime? selectedDate,
    required Function(DateTime) onDatePicked,
  }) {
    return Container(
      width: 370,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      onTimePicked(pickedTime);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedTime != null
                          ? selectedTime.format(context)
                          : TimeOfDay.now().format(context),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      onDatePicked(pickedDate);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat("dd/MM/yyyy").format(selectedDate)
                          : DateFormat("dd/MM/yyyy").format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Priority",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: createPriorityButtons(),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            // Show the dropdown when the container is tapped
            String? selected = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a Category'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: categories.map((category) {
                        return ListTile(
                          title: Text(category),
                          onTap: () {
                            Navigator.pop(context, category);
                          },
                        );
                      }).toList()
                        ..add(
                          ListTile(
                            title: const Text('Other'),
                            onTap: () async {
                              Navigator.pop(context, 'Other');
                            },
                          ),
                        ),
                    ),
                  ),
                );
              },
            );

            if (selected == 'Other') {
              _showAddCategoryDialog();
            } else if (selected != null) {
              setState(() {
                selectedCategory = selected;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.category,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  selectedCategory ?? "Select Category",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController newCategoryController = TextEditingController();
        return AlertDialog(
          title: const Text("Add New Category"),
          content: TextField(
            controller: newCategoryController,
            decoration: const InputDecoration(hintText: "Enter new category"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newCategoryController.text.isNotEmpty) {
                  setState(() {
                    categories.add(newCategoryController.text);
                    selectedCategory = newCategoryController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  endDate == null) {
                emptyWarning(context);
              } else {
                fetchData();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Boarding()));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[300],
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            child: const Text(
              "Update Task",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
