import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  String BASE_URL = dotenv.env['API_URL'] ?? "localhost:8000";
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String email = '';
  String first_name = '';
  String last_name = '';

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation Controller for smooth up and down animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start from completely hidden (0)
    _animation = Tween<double>(
      begin: 0.0,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation when page opens (from 0 to 0.55)
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  void switchAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();

      // Smoothly transition based on state
      if (isLogin) {
        _animation = Tween<double>(begin: _animation.value, end: 0.4).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      } else {
        _animation = Tween<double>(begin: _animation.value, end: 0.6).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      }
      _controller.forward(from: 0); // Restart animation from current value
    });
  }

  Future<void> hitAuth() async {
    final loginUrl = Uri.parse(BASE_URL + "users/login"); // Example API

    final loginBody = jsonEncode({"username": username, "password": password});
    final signupUrl = Uri.parse(BASE_URL + "users/signup"); // Example API
    final signUpBody = jsonEncode({
      "username": username,
      "password": password,
      "first_name": first_name,
      "last_name": last_name,
      "email": email,
    });
    final response = await http.post(
      isLogin ? loginUrl : signupUrl,
      headers: {"Content-Type": "application/json"},
      body: isLogin ? loginBody : signUpBody,
    );
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message']),
          duration: Duration(seconds: 2),
        ),
      );
      setKey('token', responseData['token']);
      setKey('username',responseData['user']['username']);
      setKey('email',responseData['user']['email']);
      setKey('first_name',responseData['user']['first_name']);
      setKey('last_name',responseData['user']['last_name']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['error']),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background heading for App Name and Quote
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 200,
              ), // Adjust for positioning
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "FinFlow", // Replace with your app name
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Choose your theme color
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Split expenses, settle up, stay stress-free!.", // Small Quote
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Login / Signup Form
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * _animation.value,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isLogin ? "Login" : "Sign Up",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child:
                              isLogin
                                  ? Column(
                                    children: [
                                      TextFormField(
                                        key: const ValueKey('username'),
                                        decoration: const InputDecoration(
                                          labelText: "Username",
                                        ),
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null) {
                                            return "Enter a valid Username";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => username = value!,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        key: const ValueKey('password'),
                                        decoration: const InputDecoration(
                                          labelText: "Password",
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null ||
                                              value.length < 6) {
                                            return "Password must be at least 6 characters";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => password = value!,
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            print(
                                              'Username: $username, Password: $password',
                                            );
                                            await hitAuth();
                                          }
                                        },
                                        child: Text(
                                          isLogin ? "Login" : "Sign Up",
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      Center(
                                        child: TextButton(
                                          onPressed: switchAuthMode,
                                          child: Text(
                                            isLogin
                                                ? "Don't have an account? Sign Up"
                                                : "Already have an account? Login",
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Column(
                                    children: [
                                      TextFormField(
                                        key: const ValueKey('email'),
                                        decoration: const InputDecoration(
                                          labelText: "Email",
                                        ),
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null ||
                                              !value.contains('@')) {
                                            return "Enter a valid email";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => email = value!,
                                      ),
                                      TextFormField(
                                        key: const ValueKey('username'),
                                        decoration: const InputDecoration(
                                          labelText: "Username",
                                        ),
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null) {
                                            return "Enter a valid username";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => username = value!,
                                      ),
                                      TextFormField(
                                        key: const ValueKey('firstname'),
                                        decoration: const InputDecoration(
                                          labelText: "First Name",
                                        ),
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null) {
                                            return "Enter a name";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => first_name = value!,
                                      ),
                                      TextFormField(
                                        key: const ValueKey('lastname'),
                                        decoration: const InputDecoration(
                                          labelText: "Last Name",
                                        ),
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null) {
                                            return "Enter a name";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => last_name = value!,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        key: const ValueKey('password'),
                                        decoration: const InputDecoration(
                                          labelText: "Password",
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null ||
                                              value.length < 6) {
                                            return "Password must be at least 6 characters";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => password = value!,
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            print(
                                              'Username: $username, Password: $password, email: $email First name : $first_name, Last Name: $last_name',
                                            );
                                            await hitAuth();
                                          }
                                        },
                                        child: Text(
                                          isLogin ? "Login" : "Sign Up",
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      Center(
                                        child: TextButton(
                                          onPressed: switchAuthMode,
                                          child: Text(
                                            isLogin
                                                ? "Don't have an account? Sign Up"
                                                : "Already have an account? Login",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
