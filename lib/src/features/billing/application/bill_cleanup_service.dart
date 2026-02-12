import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/bill_repository.dart';

final billCleanupServiceProvider = Provider<BillCleanupService>((ref) {
  return BillCleanupService(ref);
});

class BillCleanupService {
  final Ref _ref;

  BillCleanupService(this._ref);

  Future<void> runCleanup() async {
    try {
      // Read settings. Use read on provider.future to get specific value once.
      // We don't watch because this is a one-off task.
      final settings = await _ref.read(
        autoDeleteBillsSettingsControllerProvider.future,
      );

      if (settings.frequency == 'never') return;

      DateTime? cutoffDate;
      final now = DateTime.now();

      switch (settings.frequency) {
        case '1_month':
          cutoffDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case '3_months':
          cutoffDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case '6_months':
          cutoffDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case '12_months':
          cutoffDate = DateTime(now.year - 1, now.month, now.day);
          break;
        case 'custom':
          if (settings.customMonths > 0) {
            cutoffDate = DateTime(
              now.year,
              now.month - settings.customMonths,
              now.day,
            );
          }
          break;
      }

      if (cutoffDate != null) {
        final count = await _ref
            .read(billRepositoryProvider)
            .deleteBillsOlderThan(cutoffDate);
        if (count > 0) {
          // print('Auto-deleted $count bills older than $cutoffDate');
        }
      }
    } catch (e) {
      // print('Error running bill cleanup: $e');
    }
  }
}
