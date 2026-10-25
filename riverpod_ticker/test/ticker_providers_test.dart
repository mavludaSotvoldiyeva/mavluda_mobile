import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ticker/providers/ticker_providers.dart';
import 'package:riverpod_ticker/services/tick_feed.dart';

void main() {
  test('starts loading then gets BTC', () async {
    final container = ProviderContainer(overrides: [
      tickFeedProvider.overrideWithValue(TickFeed(symbols: const ['BTC'])),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(tickerProvider, (previous, next) {});
    addTearDown(sub.close);
    expect(container.read(tickerProvider).isLoading, true);
    final ticks = await container.read(tickerProvider.future);
    expect(ticks.single.symbol, 'BTC');
    expect(container.read(tickerProvider).hasValue, true);
  });

  test('error after first tick', () async {
    final container = ProviderContainer(overrides: [
      tickFeedProvider.overrideWithValue(TickFeed(symbols: const ['BTC'], failAfter: 1)),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(tickerProvider, (previous, next) {});
    addTearDown(sub.close);
    await container.read(tickerProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final state = container.read(tickerProvider);
    expect(state, isA<AsyncError<List<dynamic>>>());
    expect(state.hasValue, true);
    expect(state.error, isA<FeedException>());
  });
}
