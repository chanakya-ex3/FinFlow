import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupCodeController = TextEditingController();
  bool isLoading = false;
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";

  Future<void> createGroup() async {
    await _handleGroupAction("groups/create", {"groupName": groupNameController.text.trim()}, "Group created successfully");
  }

  Future<void> joinGroup() async {
    await _handleGroupAction("groups/join", {"groupId": groupCodeController.text.trim()}, "Joined group successfully");
  }

  Future<void> _handleGroupAction(String endpoint, Map<String, String> body, String successMessage) async {
    if (body.values.any((value) => value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fields cannot be empty")),
      );
      return;
    }

    setState(() => isLoading = true);

    String? token = await getKey('token');
    final url = Uri.parse('$BASE_URL$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.statusCode == 200 ? successMessage : "Operation failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create / Join Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildInputContainer("Group Name", "Enter group name", groupNameController),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : createGroup,
              style: _buttonStyle(Colors.green),
              icon: _buttonIcon(),
              label: const Text("Create Group", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            _buildInputContainer("Group Code", "Enter group code", groupCodeController),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : joinGroup,
              style: _buttonStyle(Colors.blue),
              icon: _buttonIcon(),
              label: const Text("Join Group", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer(String label, String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(border: InputBorder.none, hintText: hint),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) => ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
      );

  Widget _buttonIcon() => isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check, color: Colors.white);
}