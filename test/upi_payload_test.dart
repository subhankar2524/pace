import 'package:flutter_test/flutter_test.dart';
import 'package:pace/models/upi_payload.dart';

void main() {
  test('Parses upi://pay with host pay', () {
    final payload = UpiPayload.tryParse(
      'upi://pay?pa=subhankarg2524-1@oksbi&pn=Subhankar%20Ghosh',
    );

    expect(payload, isNotNull);
    expect(payload!.payeeVpa, 'subhankarg2524-1@oksbi');
  });

  test('Parses upi://pay with path pay', () {
    final payload = UpiPayload.tryParse(
      'upi:pay?pa=subhankarg2524-1@oksbi&pn=Subhankar%20Ghosh',
    );

    expect(payload, isNotNull);
    expect(payload!.payeeVpa, 'subhankarg2524-1@oksbi');
  });

  test('Accepts raw VPA', () {
    final payload = UpiPayload.tryParse('subhankarg2524-1@oksbi');

    expect(payload, isNotNull);
    expect(payload!.payeeVpa, 'subhankarg2524-1@oksbi');
  });
}
