import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'settings_providers.dart';

final formatDateProvider = Provider<String Function(DateTime)>((ref) {
  final formatAsync = ref.watch(dateFormatControllerProvider);
  final format = formatAsync.value ?? 'dd/MM/yyyy';

  return (DateTime date) {
    if (format == 'dd/MM/yyyy') {
      return DateFormat('dd/MM/yyyy').format(date);
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  };
});

final currentDateFormatStringProvider = Provider<String>((ref) {
  final formatAsync = ref.watch(dateFormatControllerProvider);
  return formatAsync.value ?? 'dd/MM/yyyy';
});
