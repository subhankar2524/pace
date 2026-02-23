import 'dart:convert';

class LocalTransaction {
  const LocalTransaction({
    required this.id,
    required this.payeeVpa,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.payeeName,
    this.upiApp,
    this.responseCode,
    this.txnId,
    this.rawResponse,
  });

  final String id;
  final String payeeVpa;
  final String? payeeName;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? upiApp;
  final String? responseCode;
  final String? txnId;
  final String? rawResponse;

  String get displayName => (payeeName == null || payeeName!.isEmpty)
      ? payeeVpa
      : '${payeeName!} ($payeeVpa)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'payeeVpa': payeeVpa,
        'payeeName': payeeName,
        'amount': amount,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'upiApp': upiApp,
        'responseCode': responseCode,
        'txnId': txnId,
        'rawResponse': rawResponse,
      };

  static LocalTransaction fromJson(Map<String, dynamic> json) {
    return LocalTransaction(
      id: json['id'] as String,
      payeeVpa: json['payeeVpa'] as String,
      payeeName: json['payeeName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      upiApp: json['upiApp'] as String?,
      responseCode: json['responseCode'] as String?,
      txnId: json['txnId'] as String?,
      rawResponse: json['rawResponse'] as String?,
    );
  }

  static List<LocalTransaction> decodeList(String encoded) {
    final list = jsonDecode(encoded) as List<dynamic>;
    return list
        .map((item) => LocalTransaction.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String encodeList(List<LocalTransaction> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }
}
