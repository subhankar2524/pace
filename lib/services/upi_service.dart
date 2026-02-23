import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:uuid/uuid.dart';

import '../models/upi_payload.dart';

class UpiService {
  const UpiService();

  Future<List<ApplicationMeta>> getInstalledApps() async {
    return UpiPay.getInstalledUpiApplications();
  }

  Future<UpiTransactionResponse> pay({
    required UpiPayload payload,
    required double amount,
    required ApplicationMeta app,
  }) async {
    final transactionRef = payload.transactionRef ?? const Uuid().v4();
    return UpiPay.initiateTransaction(
      app: app.upiApplication,
      receiverUpiAddress: payload.payeeVpa,
      receiverName: payload.payeeName ?? 'Payee',
      transactionRef: transactionRef,
      amount: amount.toStringAsFixed(2),
      merchantCode: payload.merchantCode,
      transactionNote: payload.transactionNote,
    );
  }
}
