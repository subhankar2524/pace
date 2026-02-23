import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/transaction.dart';
import '../services/transaction_store.dart';
import '../services/upi_service.dart';

final transactionStoreProvider = Provider<TransactionStore>((ref) {
  final box = Hive.box(transactionBoxName);
  return HiveTransactionStore(box);
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<LocalTransaction>>((ref) {
  final store = ref.watch(transactionStoreProvider);
  return TransactionsNotifier(store);
});

final upiServiceProvider = Provider<UpiService>((ref) {
  return const UpiService();
});

final installedUpiAppsProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.watch(upiServiceProvider);
  return service.getInstalledApps();
});

class TransactionsNotifier extends StateNotifier<List<LocalTransaction>> {
  TransactionsNotifier(this._store) : super(const []) {
    _load();
  }

  final TransactionStore _store;

  Future<void> _load() async {
    final items = await _store.load();
    if (mounted) {
      state = items;
    }
  }

  Future<void> add(LocalTransaction transaction) async {
    final updated = [transaction, ...state];
    state = updated;
    await _store.save(updated);
  }
}
