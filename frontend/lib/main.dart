import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/Screens/AuthScreen/Auth.dart';
import 'package:frontend/localstorage/Screens/HomeScreen/Home.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:async';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(FinFlow());
}

class FinFlow extends StatelessWidget {
  const FinFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final StreamController<String?> _authStreamController =
      StreamController<String?>.broadcast();

  @override
  void initState() {
    super.initState();
    _listenForTokenChanges();
  }

  Future<void> _listenForTokenChanges() async {
    while (true) {
      String? token = await getKey("token");
      _authStreamController.add(token);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _authStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          ); 
        }

        final token = snapshot.data;
        return token != null
            ? Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(title: Text("FinFlow"),),
              body: HomePage(),
            )
            : Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: AuthPage(),
            ); 
      },
    );
  }

  @override
  void dispose() {
    _authStreamController.close();
    super.dispose();
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.indigo.shade200, // Light indigo shade
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigoAccent,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.indigo[900], // Darkest indigo shade
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigoAccent,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);
