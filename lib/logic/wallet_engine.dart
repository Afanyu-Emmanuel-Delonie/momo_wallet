import 'dart:math';

import '../models/transaction.dart';

class WalletEngine {
  static const int startingBalance = 10000;
  static const List<int> denominations = [5000, 2000, 1000, 500, 100];

  final List<MomoTransaction> transactions;

  WalletEngine({List<MomoTransaction>? transactions})
      : transactions = transactions ?? [];

  static List<MomoTransaction> sampleTransactions() {
    final now = DateTime.now();
    return [
      MomoTransaction(
        id: 't1',
        description: 'Salary',
        amount: 5000,
        type: TxType.incoming,
        time: now.subtract(const Duration(days: 3)),
      ),
      MomoTransaction(
        id: 't2',
        description: 'Sent to 0788111222',
        amount: 2000,
        type: TxType.outgoing,
        time: now.subtract(const Duration(days: 2)),
      ),
      MomoTransaction(
        id: 't3',
        description: 'Refund',
        amount: 1000,
        type: TxType.incoming,
        time: now.subtract(const Duration(days: 1)),
      ),
      MomoTransaction(
        id: 't4',
        description: 'Cash out',
        amount: 1500,
        type: TxType.outgoing,
        time: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<MomoTransaction> get newestFirst {
    final list = List<MomoTransaction>.from(transactions);
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  int get totalIn => transactions
      .where((t) => t.type == TxType.incoming)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalOut => transactions
      .where((t) => t.type == TxType.outgoing)
      .fold(0, (sum, t) => sum + t.amount);

  int get balance => startingBalance + totalIn - totalOut;

  int lowestBalance() => _lowestBalanceFor(transactions);

  int _lowestBalanceFor(List<MomoTransaction> txs) {
    final ordered = List<MomoTransaction>.from(txs)
      ..sort((a, b) => a.time.compareTo(b.time));
    int running = startingBalance;
    int lowest = running;
    for (final t in ordered) {
      running += t.type == TxType.incoming ? t.amount : -t.amount;
      if (running < lowest) lowest = running;
    }
    return lowest;
  }

  String? receive(String description, int amount) {
    final cleanDesc = description.trim();
    if (cleanDesc.isEmpty) return 'Description cannot be empty';
    if (amount <= 0) return 'Amount must be a whole number above 0';
    transactions.add(MomoTransaction(
      id: _newId(),
      description: cleanDesc,
      amount: amount,
      type: TxType.incoming,
      time: DateTime.now(),
    ));
    return null;
  }

  String? send(String phone, int amount) {
    final cleanPhone = phone.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!cleanPhone.startsWith('078') && !cleanPhone.startsWith('079')) {
      return 'Phone number must start with 078 or 079';
    }
    if (amount < 100) return 'Amount must be at least 100 RWF';
    if (amount > balance) return 'Insufficient balance';
    transactions.add(MomoTransaction(
      id: _newId(),
      description: 'Sent to $cleanPhone',
      amount: amount,
      type: TxType.outgoing,
      time: DateTime.now(),
    ));
    return null;
  }

  Map<int, int>? noteBreakdown(int amount) {
    if (amount <= 0 || amount % 100 != 0) return null;
    final breakdown = <int, int>{};
    int remaining = amount;
    for (final note in denominations) {
      final count = remaining ~/ note;
      if (count > 0) breakdown[note] = count;
      remaining -= count * note;
    }
    return breakdown;
  }

  String? validateCashOut(int amount) {
    if (amount <= 0 || amount % 100 != 0) {
      return 'Amount must be a multiple of 100 RWF';
    }
    if (amount > balance) return 'Insufficient balance';
    return null;
  }

  String? cashOut(int amount) {
    final error = validateCashOut(amount);
    if (error != null) return error;
    transactions.add(MomoTransaction(
      id: _newId(),
      description: 'Cash out',
      amount: amount,
      type: TxType.outgoing,
      time: DateTime.now(),
    ));
    return null;
  }

  String? canDelete(MomoTransaction tx) {
    final remaining = transactions.where((t) => t.id != tx.id).toList();
    if (_lowestBalanceFor(remaining) < 0) {
      return 'Deleting this would make the balance go negative';
    }
    return null;
  }

  int deleteAt(MomoTransaction tx) {
    final index = transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) transactions.removeAt(index);
    return index;
  }

  void restore(MomoTransaction tx, int index) {
    if (index < 0 || index > transactions.length) {
      transactions.add(tx);
    } else {
      transactions.insert(index, tx);
    }
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
}
