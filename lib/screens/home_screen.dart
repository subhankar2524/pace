import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/upi_payload.dart';
import '../providers/payment_providers.dart';
import '../screens/payment_screen.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pace Pay'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                title: 'Scan & Pay',
                subtitle:
                    'Scan a UPI QR code, enter amount, and pay with your UPI app.',
                child: PrimaryButton(
                  label: 'Scan UPI QR',
                  icon: Icons.qr_code_scanner,
                  onPressed: () async {
                    final payload = await Navigator.of(context)
                        .push<UpiPayload>(MaterialPageRoute(
                      builder: (_) => const ScannerScreen(),
                    ));
                    if (payload == null || !context.mounted) {
                      return;
                    }
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(payload: payload),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: transactions.isEmpty
                    ? const EmptyState(
                        message:
                            'No transactions yet. Scan a QR to get started.',
                      )
                    : ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = transactions[index];
                          final createdAt = formatDateTime(item.createdAt);
                          return ListTile(
                            title: Text(item.displayName),
                            subtitle: Text('$createdAt · ${item.status}'),
                            trailing: Text(
                              '₹${item.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _handled = false;

  void _handleDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) {
      return;
    }
    final payload = UpiPayload.tryParse(raw);
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a valid UPI QR code.')),
      );
      return;
    }
    _handled = true;
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan UPI QR')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Align the UPI QR code within the frame to scan.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
