import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  final String title;
  final String description;
  final String start_date;
  final String start_time;
  final String end_date;
  final String end_time;
  final bool isCompleted;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheck;

  const TaskWidget({
    super.key,
    required this.title,
    required this.description,
    required this.start_date,
    required this.start_time,
    required this.end_date,
    required this.end_time,
    required this.isCompleted,
    required this.onTap,
    required this.onCheck,
    required task,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(milliseconds: 600),
        child: ListTile(
          leading: GestureDetector(
            onTap: () => onCheck(!isCompleted),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 0.8),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                color: Colors.white,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 3),
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.green : Colors.black,
                fontWeight: FontWeight.w500,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: TextStyle(
                  color: isCompleted ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w300,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        start_date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        start_time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
