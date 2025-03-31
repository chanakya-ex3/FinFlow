import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/Widgets/GroupExpenseCard/GroupExpense.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupDetailsPage extends StatefulWidget {
  final Map<dynamic, dynamic> groupData;

  const GroupDetailsPage({super.key, required this.groupData});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";
  bool isLoading = true;
  String username = "";
  List<dynamic> transactions = [];
  List<dynamic> debts = [];

  Future<void> fetchData() async {
    username = await getKey('username') ?? '';
    String groupId = widget.groupData['id'];
    final url = Uri.parse('${BASE_URL}group-expenses/list/$groupId');
    String? token = await getKey('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Token $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          transactions = data['transactions'];
          debts = data['debts'].where((debt) {
  return debt['from'] == username || debt['to'] == username;
}).toList();
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

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    print(debts);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupData['groupName'] ?? "Group Details"),
      ),
      body: Column(
        children: [
          debts.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        return  ListTile(
                          leading: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.red,
                          ),
                          title: Text(
                            debt['from']== username?"You owe ${debt['to']} ₹${debt['amount']}":"${debt['from']} owes you ₹${debt['amount']}",
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
              : Container(),
          const Divider(), // Adds a separator
          Expanded(
            child:
                transactions.isEmpty
                    ? Center(child: Text("No transactions found"))
                    : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            title: Text(
                              "${transaction['transactionId']['message']}",
                            ),
                            subtitle: Text(
                              "Paid ₹${transaction['paid_amount']} by ${transaction['paidBy']['first_name']}",
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              // Navigate to transaction details screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ExpensePage(
                                        transactionId:
                                            transaction['transactionId']['id'],
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
