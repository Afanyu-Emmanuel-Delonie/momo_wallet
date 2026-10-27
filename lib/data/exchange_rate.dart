import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRate {
  final double rwfPerUsd;
  final String updatedAt;

  ExchangeRate({required this.rwfPerUsd, required this.updatedAt});
}

Future<ExchangeRate> fetchUsdToRwf() async {
  final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
  final response = await http.get(url).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Server error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data['result'] != 'success') {
    throw Exception('Exchange rate unavailable');
  }

  final rates = data['rates'] as Map<String, dynamic>;
  final rwf = (rates['RWF'] as num).toDouble();
  return ExchangeRate(
    rwfPerUsd: rwf,
    updatedAt: data['time_last_update_utc'] as String? ?? '',
  );
}
