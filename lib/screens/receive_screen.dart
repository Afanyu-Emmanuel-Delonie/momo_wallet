import 'package:flutter/material.dart';

import '../logic/wallet_engine.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key, required this.engine});

  final WalletEngine engine;

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _confirm() {
    final description = descriptionController.text;
    final amount = int.tryParse(amountController.text.trim());

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a whole number for the amount')),
      );
      return;
    }

    final error = widget.engine.receive(description, amount);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive money')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Salary, Refund',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (RWF)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _confirm,
              child: const Text('Add to wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
