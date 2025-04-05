import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalSpent = 0.0;
  double totalBorrowed = 0.0;
  double totalLent = 0.0;
  bool isLoading = true;
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";
  List<dynamic> recentExpenses = [];
  List<dynamic> topContributors = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    String? token = await getKey('token');
    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}users/dashboard'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          totalSpent = data['total_spent'] ?? 0.0;
          totalBorrowed = data['total_borrowed'] ?? 0.0;
          totalLent = data['total_lent'] ?? 0.0;
          recentExpenses = data['recent_expenses'] ?? [];
          topContributors = data['top_contributors'] ?? [];
        });
        setState(() {
          isLoading = false;
        });
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppBar(title: const Text("Dashboard"), centerTitle: true),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Spending Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 40,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total Spent",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "₹${totalSpent.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                      
                    const SizedBox(height: 16),
                      
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    "Borrowed",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${totalBorrowed.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    "Lent",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${totalLent.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                      
                    const SizedBox(height: 24),
                      
                    const Text(
                      "Recent Expenses",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...recentExpenses.map((e) {
                      final transaction = e['transactionId'];
                      final payer = e['paidBy'];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          title: Text(transaction['message']),
                          subtitle: Text(
                            "Paid by ${payer['first_name']} ${payer['last_name']} on ${transaction['date'].split('T')[0]}",
                          ),
                          trailing: Text(
                            "₹${transaction['amount']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                      
                    const SizedBox(height: 24),
                      
                    const Text(
                      "Top Contributors",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...topContributors.map((contributor) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(contributor['name'][0]),
                          ),
                          title: Text(contributor['name']),
                          trailing: Text(
                            "₹${contributor['total_paid']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
