import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/report_model.dart';
import 'core_providers.dart';

final salesSummaryDaysProvider = StateProvider.autoDispose<int>((ref) => 30);

final salesSummaryProvider = FutureProvider.autoDispose<SalesSummaryModel>((ref) async {
  final days = ref.watch(salesSummaryDaysProvider);
  final result = await ref.watch(reportRepositoryProvider).salesSummary(days: days);
  return result.when(success: (data) => data, failure: (f) => throw f);
});
