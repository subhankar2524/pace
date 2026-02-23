import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

import '../models/transaction.dart';
import '../models/upi_payload.dart';
import '../providers/payment_providers.dart';
import '../widgets/primary_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.payload});

  final UpiPayload payload;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final TextEditingController _amountController;
  _SelectedUpiApp? _selectedApp;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.payload.amount ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(installedUpiAppsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Amount')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: Text(widget.payload.payeeName ?? 'UPI Payee'),
                  subtitle: Text(widget.payload.payeeVpa),
                  trailing: const Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_submitting) {
                    _handlePay();
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose UPI App',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: appsAsync.when(
                  data: (apps) {
                    final options = _buildOptions(apps);
                    if (options.isEmpty) {
                      return const Center(
                        child: Text('No UPI apps available on this device.'),
                      );
                    }
                    _selectedApp ??= options.first;
                    return ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return RadioListTile<_SelectedUpiApp>(
                          value: option,
                          groupValue: _selectedApp,
                          title: Text(option.label),
                          subtitle: option.isFallback
                              ? const Text('Try to open this app')
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _selectedApp = value;
                            });
                          },
                        );
                      },
                    );
                  },
                  error: (error, _) => Center(child: Text('Error: $error')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Pay Now',
                isLoading: _submitting,
                onPressed: _submitting ? null : _handlePay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePay() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    final app = _selectedApp;
    if (app == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a UPI app.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final service = ref.read(upiServiceProvider);
    try {
      final response = await (app.isFallback
          ? service.payWithApp(
              payload: widget.payload,
              amount: amount,
              app: app.app!,
            )
          : service.pay(
              payload: widget.payload,
              amount: amount,
              app: app.meta!,
            ));

      final status = response.status?.name ?? 'unknown';
      final transaction = LocalTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        payeeVpa: widget.payload.payeeVpa,
        payeeName: widget.payload.payeeName,
        amount: amount,
        status: status,
        createdAt: DateTime.now(),
        upiApp: app.label,
        responseCode: _safeResponseCode(response),
        txnId: _safeTxnId(response),
        rawResponse: _safeRawResponse(response),
      );
      await ref.read(transactionsProvider.notifier).add(transaction);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment status: $status')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _SelectedUpiApp {
  _SelectedUpiApp.meta(this.meta)
      : app = null,
        isFallback = false,
        label = meta!.upiApplication.getAppName();

  _SelectedUpiApp.fallback(this.app)
      : meta = null,
        isFallback = true,
        label = app!.getAppName();

  final ApplicationMeta? meta;
  final UpiApplication? app;
  final bool isFallback;
  final String label;
}

List<_SelectedUpiApp> _buildOptions(List<ApplicationMeta> installed) {
  if (installed.isNotEmpty) {
    return installed.map(_SelectedUpiApp.meta).toList();
  }
  final fallbackApps = [
    UpiApplication.googlePay,
    UpiApplication.phonePe,
    UpiApplication.paytm,
    UpiApplication.bhim,
    UpiApplication.amazonPay,
    UpiApplication.whatsApp,
  ];
  return fallbackApps.map(_SelectedUpiApp.fallback).toList();
}

String? _safeResponseCode(UpiTransactionResponse response) {
  try {
    return response.responseCode;
  } catch (_) {
    return null;
  }
}

String? _safeTxnId(UpiTransactionResponse response) {
  try {
    return response.txnId;
  } catch (_) {
    return null;
  }
}

String? _safeRawResponse(UpiTransactionResponse response) {
  try {
    return response.rawResponse;
  } catch (_) {
    return null;
  }
}
