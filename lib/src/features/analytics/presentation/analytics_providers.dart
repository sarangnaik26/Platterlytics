import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/analytics_repository.dart';

part 'analytics_providers.g.dart';

@riverpod
Future<Map<String, dynamic>> dailyStats(DailyStatsRef ref, String date) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getDailySalesStats(date);
}

@riverpod
Future<Map<String, dynamic>> rangeStats(
  RangeStatsRef ref,
  String startDate,
  String endDate,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getRangeSalesStats(startDate, endDate);
}

@riverpod
Future<Map<String, dynamic>> itemDailyStats(
  ItemDailyStatsRef ref,
  int menuId,
  String date,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getItemDailyStats(menuId, date);
}

@riverpod
Future<Map<String, dynamic>> itemRangeStats(
  ItemRangeStatsRef ref,
  int menuId,
  String startDate,
  String endDate,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getItemRangeStats(menuId, startDate, endDate);
}
