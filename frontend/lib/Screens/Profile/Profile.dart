import 'package:flutter/material.dart';
import 'package:frontend/localstorage/localstorage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(child:Column(
      children: [
        Text("Profile Page"),
        ElevatedButton(onPressed:()=> deleteKey('token'), child: Text("Logout"))
      ],
    ),);
  }
}