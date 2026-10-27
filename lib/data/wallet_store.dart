import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class WalletStore {
  static const _key = 'momo_wallet_transactions';

  static Future<List<MomoTransaction>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MomoTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<MomoTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
