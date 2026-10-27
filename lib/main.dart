import 'package:flutter/material.dart';

import 'screens/wallet_screen.dart';

void main() {
  runApp(const MomoWalletApp());
}

class MomoWalletApp extends StatelessWidget {
  const MomoWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoMo Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
        useMaterial3: true,
      ),
      home: const WalletScreen(),
    );
  }
}
