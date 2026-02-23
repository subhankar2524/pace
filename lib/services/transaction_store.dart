import 'package:hive_flutter/hive_flutter.dart';

import '../models/transaction.dart';

const transactionBoxName = 'pace';

abstract class TransactionStore {
  Future<List<LocalTransaction>> load();
  Future<void> save(List<LocalTransaction> items);
}

class HiveTransactionStore implements TransactionStore {
  HiveTransactionStore(this._box);

  final Box _box;

  static const _key = 'local_transactions';

  @override
  Future<List<LocalTransaction>> load() async {
    final raw = _box.get(_key) as String?;
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      return LocalTransaction.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<LocalTransaction> items) async {
    await _box.put(_key, LocalTransaction.encodeList(items));
  }
}
