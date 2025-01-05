import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo_list/boarding.dart';

class UpdateTask extends StatefulWidget {
  final String? existingTitle;
  final String? existingDescription;
  final DateTime? existingStartDate;
  final TimeOfDay? existingTime;
  final Color existingColor;
  final String? existingCategory;

  const UpdateTask({
    super.key,
    this.existingTitle,
    this.existingDescription,
    this.existingStartDate,
    this.existingTime,
    this.existingColor = Colors.blue,
    this.existingCategory,
    required Task task,
  });

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  final TextEditingController newCategoryController = TextEditingController();

  DateTime? startDate;
  TimeOfDay? selectedTime;
  late Color selectedColor;

  List<String> categories = ['Work', 'Personal', 'Shopping', 'Fitness'];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingTitle);
    descriptionController =
        TextEditingController(text: widget.existingDescription);
    startDate = widget.existingStartDate;
    selectedTime = widget.existingTime;
    selectedColor = widget.existingColor;
    selectedCategory = widget.existingCategory;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Update Task"),
        ),
        body: Container(
          color: const Color.fromARGB(255, 243, 241, 241),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSideTexts(textTheme),
                const SizedBox(height: 20),
                _buildTaskTitleField(),
                const SizedBox(height: 20),
                _buildTaskDescriptionField(),
                const SizedBox(height: 20),
                _buildDateAndTimePickers(context),
                const SizedBox(height: 20),
                _buildColorPicker(),
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
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
          Text(
            "Update Task",
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
          decoration: const InputDecoration(
            labelText: "Task Title",
            border: InputBorder.none,
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget _buildTaskDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: "Task Description",
            border: InputBorder.none,
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget _buildDateAndTimePickers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimePicker(
          context,
          title: "Start Date",
          selectedDate: startDate,
          onDatePicked: (date) => setState(() => startDate = date),
        ),
        const SizedBox(height: 20),
        _buildTimePicker(
          context,
          title: "Select Time",
          selectedTime: selectedTime,
          onTimePicked: (time) => setState(() => selectedTime = time),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context, {
    required String title,
    required DateTime? selectedDate,
    required Function(DateTime) onDatePicked,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
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
            child: Text(
              selectedDate != null
                  ? DateFormat("dd/MM/yyyy").format(selectedDate)
                  : "Select Date",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String title,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimePicked,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
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
            child: Text(
              selectedTime != null
                  ? "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}"
                  : "Select Time",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Task Color"),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            Color? pickedColor = await showDialog<Color>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a Color'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      showLabel: true,
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                );
              },
            );
            if (pickedColor != null) {
              setState(() {
                selectedColor = pickedColor;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [selectedColor.withOpacity(0.7), selectedColor],
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  "Pick Color",
                  style: TextStyle(
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

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Task Category"),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
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
                colors: [Colors.blue.withOpacity(0.7), Colors.blue],
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
          width: 150,
          child: ElevatedButton(
            onPressed: () {
              print(
                  "Task Updated with Color: ${selectedColor.toString()} and Category: $selectedCategory");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "Update Task",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
