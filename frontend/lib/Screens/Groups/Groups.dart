import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/Widgets/GroupCard/GroupCard.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";
  bool isLoading = true;
  List groups = [];
  List filteredGroups = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchGroups() async {
    final url = Uri.parse('${BASE_URL}groups/list');
    String? token = await getKey('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Token $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          groups = data;
          filteredGroups = groups;
        });
      } else {
        print("Failed to load groups: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups = groups;
      } else {
        filteredGroups = groups
            .where((group) =>
                group['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredGroups = groups;
      }
    });
  }

  @override
  void initState() {
    fetchGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: isSearching
              ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search groups...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: filterSearch,
                )
              : const Text("Groups"),
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search),
              onPressed: toggleSearch,
            ),
          ],
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredGroups.isEmpty
                  ? const Center(child: Text("No groups found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = filteredGroups[index];
                        return GroupCard(groupData: group);
                      },
                    ),
        ),
      ],
    );
  }
}

