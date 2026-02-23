class UpiPayload {
  const UpiPayload({
    required this.raw,
    required this.payeeVpa,
    this.payeeName,
    this.merchantCode,
    this.transactionRef,
    this.transactionNote,
    this.currency,
    this.amount,
  });

  final String raw;
  final String payeeVpa;
  final String? payeeName;
  final String? merchantCode;
  final String? transactionRef;
  final String? transactionNote;
  final String? currency;
  final String? amount;

  static UpiPayload? tryParse(String data) {
    final uri = Uri.tryParse(data.trim());
    if (uri == null) {
      return null;
    }
    if (uri.scheme.toLowerCase() != 'upi') {
      return null;
    }
    final path = uri.path.toLowerCase();
    if (path != 'pay') {
      return null;
    }
    final params = uri.queryParameters;
    final payeeVpa = params['pa'];
    if (payeeVpa == null || payeeVpa.isEmpty) {
      return null;
    }
    return UpiPayload(
      raw: data,
      payeeVpa: payeeVpa,
      payeeName: params['pn'],
      merchantCode: params['mc'],
      transactionRef: params['tr'],
      transactionNote: params['tn'],
      currency: params['cu'],
      amount: params['am'],
    );
  }
}
