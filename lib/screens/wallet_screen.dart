import 'package:flutter/material.dart';

import '../data/wallet_store.dart';
import '../logic/wallet_engine.dart';
import '../models/transaction.dart';
import 'cash_out_screen.dart';
import 'exchange_rate_card.dart';
import 'receive_screen.dart';
import 'send_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final engine = WalletEngine();
  String filter = 'All';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final saved = await WalletStore.load();
    setState(() {
      engine.transactions
        ..clear()
        ..addAll(saved ?? WalletEngine.sampleTransactions());
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await WalletStore.save(engine.transactions);
  }

  Future<void> _openReceive() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ReceiveScreen(engine: engine)),
    );
    if (result == true) {
      setState(() {});
      _save();
    }
  }

  Future<void> _openSend() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => SendScreen(engine: engine)),
    );
    if (result == true) {
      setState(() {});
      _save();
    }
  }

  Future<void> _openCashOut() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CashOutScreen(engine: engine)),
    );
    if (result == true) {
      setState(() {});
      _save();
    }
  }

  void _deleteTransaction(MomoTransaction tx) {
    final index = engine.deleteAt(tx);
    setState(() {});
    _save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tx.description} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            engine.restore(tx, index);
            setState(() {});
            _save();
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${time.day}/${time.month}/${time.year}  ${two(time.hour)}:${two(time.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shown = engine.newestFirst.where((t) {
      if (filter == 'IN') return t.type == TxType.incoming;
      if (filter == 'OUT') return t.type == TxType.outgoing;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('MoMo Wallet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02569B),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(
                        '${engine.balance} RWF',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                          label: 'Total IN', value: '${engine.totalIn}', color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                          label: 'Total OUT', value: '${engine.totalOut}', color: Colors.red),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                          label: 'Lowest ever',
                          value: '${engine.lowestBalance()}',
                          color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const ExchangeRateCard(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openReceive,
                        icon: const Icon(Icons.call_received, size: 18),
                        label: const Text('Receive'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openSend,
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Send'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openCashOut,
                        icon: const Icon(Icons.payments, size: 18),
                        label: const Text('Cash out'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final f in ['All', 'IN', 'OUT'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: filter == f,
                          onSelected: (_) => setState(() => filter = f),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? const Center(child: Text('No transactions yet'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: shown.length,
                    itemBuilder: (context, index) {
                      final tx = shown[index];
                      final isIn = tx.type == TxType.incoming;
                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          final error = engine.canDelete(tx);
                          if (error != null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(error)));
                            return false;
                          }
                          return true;
                        },
                        onDismissed: (_) => _deleteTransaction(tx),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              isIn ? Icons.call_received : Icons.call_made,
                              color: isIn ? Colors.green : Colors.red,
                            ),
                            title: Text(tx.description),
                            subtitle: Text(_formatTime(tx.time)),
                            trailing: Text(
                              '${isIn ? '+' : '-'}${tx.amount} RWF',
                              style: TextStyle(
                                color: isIn ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
