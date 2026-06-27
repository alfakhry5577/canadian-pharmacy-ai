import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reminder_model.dart';
import 'core_providers.dart';

final remindersProvider = FutureProvider.autoDispose<List<ReminderModel>>((ref) async {
  final result = await ref.watch(customerRepositoryProvider).listReminders();
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final loyaltyAccountProvider = FutureProvider.autoDispose<LoyaltyAccountModel>((ref) async {
  final result = await ref.watch(customerRepositoryProvider).loyalty();
  return result.when(success: (data) => data, failure: (f) => throw f);
});
