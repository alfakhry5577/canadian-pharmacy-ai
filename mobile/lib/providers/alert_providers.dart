import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alert_model.dart';
import 'core_providers.dart';

final activeAlertsProvider = FutureProvider.autoDispose<List<AlertModel>>((ref) async {
  final result = await ref.watch(alertRepositoryProvider).list(resolved: false);
  return result.when(success: (data) => data, failure: (f) => throw f);
});
