import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExpensePage extends StatefulWidget {
  final String transactionId;
  
  const ExpensePage({super.key, required this.transactionId});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";
  bool isLoading = true;
  Map<String, dynamic>? transactionData;

  Future<void> fetchData() async {
    final url = Uri.parse('${BASE_URL}group-expenses/view/${widget.transactionId}');
    String? token = await getKey('token');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Token $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          transactionData = data;
          isLoading = false;
        });
      } else {
        print("Failed to load data: \${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: \$e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (transactionData == null) {
      return Scaffold(body: Center(child: Text("No transaction data available")));
    }

    final groupTransaction = transactionData!["groupTransaction"];
    final splitRatio = transactionData!["splitRatio"] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text("Transaction Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Paid By: ${groupTransaction['paidBy']['first_name']} ${groupTransaction['paidBy']['last_name']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Amount: ₹${groupTransaction['paid_amount']}", style: TextStyle(fontSize: 16)),
            Text("Message: ${groupTransaction['transactionId']['message']}", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text("Split Details:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: splitRatio.length,
                itemBuilder: (context, index) {
                  final split = splitRatio[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text("${split['borrower']['first_name']} ${split['borrower']['last_name']}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text("Borrowed: ₹${split['borrowed_amount']} (${split['percentage']}%)"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
