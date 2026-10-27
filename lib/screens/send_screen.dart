import 'package:flutter/material.dart';

import '../logic/wallet_engine.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key, required this.engine});

  final WalletEngine engine;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _confirm() {
    final phone = phoneController.text;
    final amount = int.tryParse(amountController.text.trim());

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a whole number for the amount')),
      );
      return;
    }

    final error = widget.engine.send(phone, amount);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '0788123456',
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
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
