import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/automated_payout_service.dart';

/// Widget to initialize and manage the automated payout service
/// Add this to your main app or admin dashboard
class PayoutServiceInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const PayoutServiceInitializer({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<PayoutServiceInitializer> createState() =>
      _PayoutServiceInitializerState();
}

class _PayoutServiceInitializerState
    extends ConsumerState<PayoutServiceInitializer> {
  @override
  void initState() {
    super.initState();

    // Auto-start the service when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(automatedPayoutServiceProvider);

      // Auto-start the service on app launch
      service.startService();

      print(
          'PayoutServiceInitializer: ✅ Automated payout service started automatically');
      print(
          'PayoutServiceInitializer: 🔄 Will process pending payouts every 2 minutes');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Simple floating action button to toggle the service
class PayoutServiceToggleFAB extends ConsumerWidget {
  const PayoutServiceToggleFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isServiceRunning = ref.watch(payoutServiceStatusProvider);
    final serviceController = ref.watch(payoutServiceControllerProvider);

    return FloatingActionButton.extended(
      onPressed: () {
        if (isServiceRunning) {
          serviceController.stopService();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Automated payout processing stopped')),
          );
        } else {
          serviceController.startService();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Automated payout processing started')),
          );
        }
      },
      icon: Icon(
        isServiceRunning ? Icons.stop : Icons.play_arrow,
      ),
      label: Text(
        isServiceRunning ? 'Stop Auto Payouts' : 'Start Auto Payouts',
      ),
      backgroundColor: isServiceRunning ? Colors.red : Colors.green,
    );
  }
}

/// Quick status indicator for the app bar
class PayoutServiceStatusIndicator extends ConsumerWidget {
  const PayoutServiceStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isServiceRunning = ref.watch(payoutServiceStatusProvider);
    final serviceStats = ref.watch(payoutServiceStatsProvider);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isServiceRunning ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isServiceRunning ? 'Auto Processing' : 'Manual Only',
            style: const TextStyle(fontSize: 12),
          ),
          if (serviceStats['processed'] != null &&
              serviceStats['processed']! > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${serviceStats['processed']}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
