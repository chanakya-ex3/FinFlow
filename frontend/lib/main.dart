import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:frontend/Screens/AddTransaction/AddTransaction.dart';
import 'package:frontend/Screens/AuthScreen/Auth.dart';
import 'package:frontend/Screens/Groups/Groups.dart';
import 'package:frontend/Screens/HomeScreen/Home.dart';
import 'package:frontend/Screens/Profile/Profile.dart';
import 'package:frontend/Screens/Transactions/Transactions.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:async';

void main() async {
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

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _listenForTokenChanges();
  }

  List<Widget> pages = [
    HomePage(),
    GroupsPage(),
    AddTransactionPage(),
    TransactionsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          return Center(child: CircularProgressIndicator());
        }

        final token = snapshot.data;
        return token != null
            ? Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: pages[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type:
                    BottomNavigationBarType
                        .fixed, // Ensures proper layout with more than 3 items
                elevation: 10, // Adds depth effect
                selectedItemColor:
                    Theme.of(
                      context,
                    ).colorScheme.primary, // Highlighted item color
                unselectedItemColor:
                    Colors.grey.shade500, // Non-selected item color
                // backgroundColor: , // Background color
                showUnselectedLabels: true, // Show labels for all items
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: 28),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group, size: 28),
                    label: "Groups",
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 60, // Adjust size
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Theme.of(context)
                                .colorScheme
                                .primary, // Use theme color or a custom one
                      ),
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.white,
                      ), // Adjust size & color
                    ),
                    label: "Add Transaction",
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.payment, size: 28),
                    label: "Transactions",
                  ),
                  BottomNavigationBarItem(
                    icon: CircleAvatar(
                      radius: 15, // Keeps profile icon size similar to others
                      backgroundColor:
                          Colors
                              .white, // Background to contrast with black navbar
                      child: ProfilePicture(
                        name: "Name",
                        radius: 14,
                        fontsize: 16,
                      ),
                    ),
                    label: "Profile",
                  ),
                ],
              ),
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
  primaryColorDark: Colors.white,
  primaryColorLight: Colors.black,
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
  primaryColorDark:Colors.black ,
  primaryColorLight: Colors.white,
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
