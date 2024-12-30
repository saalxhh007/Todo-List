import 'package:flutter/material.dart';
import 'package:frontend/Signup.dart';
import 'package:frontend/boarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AuthHandler());
  }
}

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  State<AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("AuthToken");

    setState(() {
      _hasToken = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _hasToken ? const Boarding() : const Signup();
  }
}
