import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pace/main.dart';
import 'package:pace/models/transaction.dart';
import 'package:pace/providers/payment_providers.dart';
import 'package:pace/services/transaction_store.dart';

class InMemoryTransactionStore implements TransactionStore {
  List<LocalTransaction> _items = const [];

  @override
  Future<List<LocalTransaction>> load() async => _items;

  @override
  Future<void> save(List<LocalTransaction> items) async {
    _items = items;
  }
}

void main() {
  testWidgets('App widget builds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionStoreProvider.overrideWithValue(InMemoryTransactionStore()),
        ],
        child: const PaceApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Pace Pay'), findsOneWidget);
    expect(find.text('Scan UPI QR'), findsOneWidget);
  });
}
