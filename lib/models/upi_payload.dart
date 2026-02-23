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
    final raw = data.trim();
    if (raw.isEmpty) {
      return null;
    }
    if (_looksLikeVpa(raw)) {
      return UpiPayload(raw: raw, payeeVpa: raw);
    }
    final uri = _extractUpiUri(raw);
    if (uri == null) {
      return null;
    }
    if (uri.scheme.toLowerCase() != 'upi') {
      return null;
    }
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final isPayIntent = host == 'pay' || path == 'pay' || path == '/pay';
    if (!isPayIntent) {
      return null;
    }
    final params = uri.queryParameters;
    final payeeVpa = params['pa'];
    if (payeeVpa == null || payeeVpa.isEmpty) {
      // Some QR codes only encode VPA directly.
      if (_looksLikeVpa(raw)) {
        return UpiPayload(raw: raw, payeeVpa: raw);
      }
      return null;
    }
    return UpiPayload(
      raw: raw,
      payeeVpa: payeeVpa,
      payeeName: params['pn'],
      merchantCode: params['mc'],
      transactionRef: params['tr'],
      transactionNote: params['tn'],
      currency: params['cu'],
      amount: params['am'],
    );
  }

  static Uri? _extractUpiUri(String raw) {
    final direct = Uri.tryParse(raw);
    if (direct != null && direct.scheme.toLowerCase() == 'upi') {
      return direct;
    }
    final index = raw.toLowerCase().indexOf('upi://');
    if (index == -1) {
      return null;
    }
    final candidate = raw.substring(index).split(RegExp(r'\s')).first;
    return Uri.tryParse(candidate);
  }

  static bool _looksLikeVpa(String value) {
    if (value.contains('://') || value.contains('?')) {
      return false;
    }
    return value.contains('@') && value.split('@').length == 2;
  }
}
