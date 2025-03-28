import 'package:flutter/material.dart';
import 'package:frontend/localstorage/localstorage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("Welcome home"),
          ElevatedButton(onPressed:()=> deleteKey('token'), child: Text("Logout"))
        ],
      ),
    );
  }
}