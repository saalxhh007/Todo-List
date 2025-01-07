import 'package:flutter/material.dart';
import 'package:todo_list/Signup.dart';
import 'package:todo_list/boarding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isChecked = false;

  void fetchData() async {
    final Map<String, dynamic> userData = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final responseSucceed = jsonDecode(response.body);
        final token = responseSucceed['token'];

        final preferences = await SharedPreferences.getInstance();
        await preferences.setString("AuthToken", token);

        if (isChecked) {
          await preferences.setString("email", emailController.text);
          await preferences.setString("password", passwordController.text);
          await preferences.setBool("rememberMe", true);
        } else {
          await preferences.remove("email");
          await preferences.remove("password");
          await preferences.remove("rememberMe");
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Boarding()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed")),
      );
    }
  }

  void _loadCredentials() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = preferences.getString('email') ?? '';
      passwordController.text = preferences.getString('password') ?? '';
      isChecked = preferences.getBool('rememberMe') ?? false;
    });
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    final formGlobalKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
              key: formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Login To Your Todo Account",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(1),
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Email",
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
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(1),
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Password",
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
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) => {
                                    setState(() {
                                      isChecked = value!;
                                    })
                                  }),
                          const Text("remember me"),
                        ],
                      ),
                      const Text(
                        "Forget The Password",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formGlobalKey.currentState!.validate()) {
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
                        "Login",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Signup()))
                          },
                      child: const Text("Don't Have An Account , Sign Up"))
                ],
              )),
        ),
      ),
    );
  }
}
