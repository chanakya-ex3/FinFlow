import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String BASE_URL = dotenv.env['API_URL'] ?? "http://localhost:8000/";

  Future<void> addTransaction(String message, double amount) async {
    final url = Uri.parse('${BASE_URL}transactions/create');
    String? token = await getKey('token'); // Fetch stored token

    if (message.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid transaction details")),
      );
      return;
    }

    final body = jsonEncode({
      "message": message,
      "amount": amount.toStringAsFixed(2), // Ensure 2 decimal places
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction Added Successully")),
        );
        print("Transaction Added: ${message} - ₹$amount");
      } else {
        print("Failed to add transaction: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  void _submitTransaction() {
    if (_amountController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter all details")));
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    addTransaction(_messageController.text, amount);
    FocusScope.of(context).unfocus();

    // Clear fields after submission
    _messageController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Amount Input (Big Number Style)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$'),
                      ),
                    ],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "₹0.00",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "What's this for?",
                  prefixIcon: Icon(Icons.message, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _submitTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 32,
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                "Save",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
