import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? selectedGroup;
  List<dynamic> groups = [];
  bool isLoading = true;
  List<dynamic> members = [];
  int? selectedGroupIndex;

  Map<String, double> memberPercentages = {};
  Map<String, TextEditingController> percentageControllers = {};
  Map<String, bool> selectedMembers = {};
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
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
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      for (var member in members) {
        final username = member['user']['username'];
        selectedMembers[username] = selectAll;
      }
      _recalculatePercentages();
    });
  }

  void _toggleMemberSelection(String username, bool? value) {
    setState(() {
      selectedMembers[username] = value ?? false;
      _recalculatePercentages();
    });
  }

  void _recalculatePercentages() {
    final selected =
        selectedMembers.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    double split = selected.isEmpty ? 0.0 : (100 / selected.length);

    for (var username in percentageControllers.keys) {
      if (selectedMembers[username] == true) {
        memberPercentages[username] = split;
        percentageControllers[username]?.text = split.toStringAsFixed(2);
      } else {
        memberPercentages[username] = 0.0;
        percentageControllers[username]?.text = "0";
      }
    }
  }

  void _submitExpense() async {
    String? token = await getKey('token');
    double? amount = double.tryParse(_amountController.text);
    String message = _messageController.text.trim();

    if (amount == null ||
        amount <= 0 ||
        selectedGroupIndex == null ||
        message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields properly")),
      );
      return;
    }

    final selected = selectedMembers.entries.where((e) => e.value).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one member")),
      );
      return;
    }

    double totalPercentage = 0.0;
    Map<String, double> splitRatio = {};
    for (var entry in selectedMembers.entries) {
      if (entry.value) {
        double percent = memberPercentages[entry.key] ?? 0.0;
        splitRatio[entry.key] = percent;
        totalPercentage += percent;
      }
    }

    if (totalPercentage != 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Total percentage must be 100%")),
      );
      return;
    }

    final groupId = groups[selectedGroupIndex!]['id']; // UUID from API response

    final payload = {
      "groupId": groupId,
      "splitRatio": splitRatio,
      "amount": amount,
      "message": message,
    };
    print(payload);
    try {
      final response = await http.post(
        Uri.parse('${BASE_URL}group-expenses/create'),
        headers: {
          "Authorization": "Token ${token}", // replace with actual token
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Expense Created")));
        _amountController.clear();
        _messageController.clear();
        setState(() {
          selectedMembers.updateAll((key, value) => false);
          memberPercentages.updateAll((key, value) => 0.0);
          percentageControllers.forEach(
            (key, controller) => controller.text = "0",
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Expense")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _styledInputCard(
                      title: "Amount",
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: "₹0.00",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _styledInputCard(
                      title: "Message",
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "What is this expense for?",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.message),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _styledInputCard(
                      title: "Select Group",
                      child: DropdownButton<int>(
                        value: selectedGroupIndex,
                        isExpanded: true,
                        hint: const Text("Choose group"),
                        items: List.generate(groups.length, (index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(groups[index]['groupName']),
                          );
                        }),
                        onChanged: (index) {
                          if (index != null) {
                            final selectedMembersList =
                                groups[index]['members'];
                            setState(() {
                              selectedGroupIndex = index;
                              members = selectedMembersList;
                              memberPercentages.clear();
                              percentageControllers.clear();
                              selectedMembers.clear();
                              for (var member in members) {
                                final username = member['user']['username'];
                                memberPercentages[username] = 0.0;
                                percentageControllers[username] =
                                    TextEditingController(text: "0");
                                selectedMembers[username] = false;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (selectedGroupIndex != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select All Members",
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch(value: selectAll, onChanged: _toggleSelectAll),
                        ],
                      ),

                    const SizedBox(height: 8),

                    ...members.map((member) {
                      final username = member['user']['username'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selectedMembers[username] ?? false,
                              onChanged:
                                  (value) =>
                                      _toggleMemberSelection(username, value),
                            ),
                            Expanded(child: Text(username)),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: percentageControllers[username],
                                enabled: false,
                                decoration: const InputDecoration(
                                  suffixText: "%",
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _submitExpense,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _styledInputCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
