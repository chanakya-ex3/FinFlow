import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import for date formatting

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";
  bool isLoading = true;
  List transactions = [];
  List filteredTransactions = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchData() async {
    final url = Uri.parse('${BASE_URL}transactions/list');
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
          filteredTransactions = transactions; // Initialize filtered list
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

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTransactions = transactions;
      } else {
        filteredTransactions = transactions
            .where((transaction) =>
                transaction['message']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                transaction['amount'].toString().contains(query))
            .toList();
      }
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredTransactions = transactions; // Reset list
      }
    });
  }

  @override
  void initState() {
    fetchData();
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
                    hintText: "Search transactions...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: filterSearch,
                )
              : const Text("Transactions"),
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
              : filteredTransactions.isEmpty
                  ? const Center(child: Text("No transactions found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return TransactionCard(transaction: transaction);
                      },
                    ),
        ),
      ],
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Map transaction;
  const TransactionCard({super.key, required this.transaction});

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.account_balance_wallet, color: Colors.white),
        ),
        title: Text(
          "₹${transaction['amount']}", // Display Amount
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          transaction['message'] ?? "No description",
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatDate(transaction['date']), // Formatted Date
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              transaction['type'].toUpperCase(), // Transaction Type
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
