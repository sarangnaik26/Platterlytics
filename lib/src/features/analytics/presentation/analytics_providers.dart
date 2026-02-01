import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/analytics_repository.dart';

part 'analytics_providers.g.dart';

@riverpod
Future<Map<String, dynamic>> dailyStats(Ref ref, String date) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getDailySalesStats(date);
}

@riverpod
Future<Map<String, dynamic>> rangeStats(
  Ref ref,
  String startDate,
  String endDate,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getRangeSalesStats(startDate, endDate);
}

@riverpod
Future<Map<String, dynamic>> itemDailyStats(
  Ref ref,
  int menuId,
  String date,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getItemDailyStats(menuId, date);
}

@riverpod
Future<Map<String, dynamic>> itemRangeStats(
  Ref ref,
  int menuId,
  String startDate,
  String endDate,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getItemRangeStats(menuId, startDate, endDate);
}

@riverpod
Future<Map<String, dynamic>> weekdayStats(
  Ref ref,
  int weeksBack,
  int weekday,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getWeekdaySalesStats(weeksBack, weekday);
}

@riverpod
Future<Map<String, dynamic>> itemWeekdayStats(
  Ref ref,
  int menuId,
  int weeksBack,
  int weekday,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getItemWeekdayStats(menuId, weeksBack, weekday);
}
