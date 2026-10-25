import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tick.dart';
import '../services/tick_feed.dart';

class FailAfter extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) => state = value;
}

final failAfterProvider = NotifierProvider<FailAfter, int?>(FailAfter.new);

final tickFeedProvider = Provider<TickFeed>((ref) {
  return TickFeed(failAfter: ref.watch(failAfterProvider));
});

final tickerProvider = StreamProvider.autoDispose<List<Tick>>((ref) {
  return ref.watch(tickFeedProvider).watch();
});
