import 'package:flutter/material.dart';

import '../logic/wallet_engine.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key, required this.engine});

  final WalletEngine engine;

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final amountController = TextEditingController();
  Map<int, int>? _breakdown;
  String? _liveError;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final amount = int.tryParse(text.trim());
    setState(() {
      if (amount == null) {
        _breakdown = null;
        _liveError = null;
        return;
      }
      final error = widget.engine.validateCashOut(amount);
      if (error != null) {
        _breakdown = null;
        _liveError = error;
      } else {
        _breakdown = widget.engine.noteBreakdown(amount);
        _liveError = null;
      }
    });
  }

  void _confirm() {
    final amount = int.tryParse(amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a whole number for the amount')),
      );
      return;
    }

    final error = widget.engine.cashOut(amount);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash out')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                labelText: 'Amount (RWF)',
                hintText: 'Multiple of 100',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_liveError != null)
              Text(_liveError!, style: const TextStyle(color: Colors.red)),
            if (_breakdown != null) ...[
              const Text('You will receive:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...WalletEngine.denominations.where((note) => _breakdown!.containsKey(note)).map(
                    (note) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('$note RWF notes  ×  ${_breakdown![note]}'),
                    ),
                  ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _breakdown != null ? _confirm : null,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
