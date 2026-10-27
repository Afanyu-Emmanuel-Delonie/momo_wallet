import 'package:flutter/material.dart';

import '../data/exchange_rate.dart';

class ExchangeRateCard extends StatefulWidget {
  const ExchangeRateCard({super.key});

  @override
  State<ExchangeRateCard> createState() => _ExchangeRateCardState();
}

class _ExchangeRateCardState extends State<ExchangeRateCard> {
  ExchangeRate? _rate;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rate = await fetchUsdToRwf();
      if (!mounted) return;
      setState(() {
        _rate = rate;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load exchange rate.\nCheck your internet and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          : _error != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.black45),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(Icons.currency_exchange, color: Color(0xFF02569B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1 USD = ${_rate!.rwfPerUsd.toStringAsFixed(1)} RWF',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Text(
                            'Live exchange rate',
                            style: TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
                  ],
                ),
    );
  }
}
