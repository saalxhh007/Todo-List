import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Createtask extends StatefulWidget {
  const Createtask({super.key});

  @override
  State<Createtask> createState() => _CreatetaskState();
}

class _CreatetaskState extends State<Createtask> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String todayDate = DateFormat("dd/MM/yyyy").format(DateTime.now());

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create New Task",
          style: TextStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Task Title",
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Task Description",
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[Text("Starts :"), Text(todayDate)],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Text("End : "),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: endDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Select End Date",
                          ),
                          onTap: selectEndDate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
