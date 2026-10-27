enum TxType { incoming, outgoing }

class MomoTransaction {
  final String id;
  final String description;
  final int amount;
  final TxType type;
  final DateTime time;

  MomoTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'type': type.name,
        'time': time.toIso8601String(),
      };

  factory MomoTransaction.fromJson(Map<String, dynamic> json) {
    return MomoTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: json['amount'] as int,
      type: json['type'] == 'incoming' ? TxType.incoming : TxType.outgoing,
      time: DateTime.parse(json['time'] as String),
    );
  }
}
