import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/boarding.dart';
import 'package:todo_list/login.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  PhoneNumber? phoneNumber;
  final _formGlobalKey = GlobalKey<FormState>();

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

  void fetchData() async {
    final Map<String, dynamic> userData = {
      "name": nameController.text,
      "email": emailController.text,
      "dateBirth": dateController.text,
      "phone": phoneNumber?.phoneNumber,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(Uri.parse("http://10.0.2.2:3000/signup"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(userData));

      if (response.statusCode == 201) {
        final responseSucceed = jsonDecode(response.body);
        final token = responseSucceed['token'];

        final preferences = await SharedPreferences.getInstance();
        await preferences.setString("AuthToken", token);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Boarding()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign Up Failed")),
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Name Input Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(1),
                      prefixIcon: const Icon(Icons.person),
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 85, 85, 85)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 171, 171, 171)),
                      ),
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Must Enter A Valid Name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Date of Birth Input Field
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(1),
                      labelText: "Date Of Birth",
                      prefixIcon: const Icon(Icons.date_range_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    readOnly: true,
                    onTap: selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Must Enter A Valid Date";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Email Input Field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(1),
                      prefixIcon: const Icon(Icons.email_rounded),
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Must Enter A Valid Email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Phone Number Input Field
                  const SizedBox(height: 20),
                  // Password Input Field
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(1),
                      prefixIcon: const Icon(Icons.password),
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Must Enter A Password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Rewrite Password Input Field
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password),
                      labelText: "Rewrite The Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  // Sign Up Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formGlobalKey.currentState!.validate()) {
                          fetchData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()))
                          },
                      child: const Text("Already Have An Account , Login"))
                ],
              ),
            ),
          ),
        ));
  }
}
