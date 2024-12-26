import 'package:flutter/material.dart';
import 'package:frontend/signup.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Signup());
  }
}
