import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/medication_model.dart';
import 'core_providers.dart';

/// Raw search box text — updated on every keystroke via [searchQueryProvider.notifier].
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced query (350ms after typing stops), implemented as a small
/// StateNotifier with a manual Timer — simpler and more predictable than
/// wiring a StreamController through a provider's lifecycle.
class DebouncedQueryNotifier extends StateNotifier<String> {
  DebouncedQueryNotifier(this.ref) : super('') {
    ref.listen<String>(searchQueryProvider, (previous, next) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 350), () {
        if (mounted) state = next;
      });
    });
  }

  final Ref ref;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final debouncedSearchQueryProvider = StateNotifierProvider<DebouncedQueryNotifier, String>(
  (ref) => DebouncedQueryNotifier(ref),
);

final medicationSearchResultsProvider = FutureProvider<List<MedicationSearchResultModel>>((ref) async {
  final query = ref.watch(debouncedSearchQueryProvider).trim();
  if (query.length < 2) return [];

  final result = await ref.watch(medicationRepositoryProvider).search(query);
  return result.when(success: (data) => data, failure: (f) => throw f);
});
