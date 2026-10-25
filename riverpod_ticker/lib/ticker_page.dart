import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/tick.dart';
import 'providers/ticker_providers.dart';
import 'widgets/tick_row.dart';

class TickerPage extends ConsumerWidget {
  const TickerPage({super.key});

  Widget rows(List<Tick> ticks, WidgetRef ref) {
    if (ticks.isEmpty) return const Center(child: Text('No symbols subscribed'));
    if (ticks.length == 1) return Center(child: TickRow(ticks.first));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(tickerProvider.future).then<void>((_) {}),
      child: ListView(children: [for (final tick in ticks) TickRow(tick, key: ValueKey(tick.symbol))]),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticks = ref.watch(tickerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ticker'),
        actions: [
          IconButton(tooltip: 'Force error', icon: const Icon(Icons.warning_amber),
            onPressed: () => ref.read(failAfterProvider.notifier).set(5)),
          IconButton(tooltip: 'Normal feed', icon: const Icon(Icons.check_circle_outline),
            onPressed: () => ref.read(failAfterProvider.notifier).set(null)),
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tickerProvider)),
        ],
      ),
      body: switch (ticks) {
        AsyncError(:final error, :final value?) => Column(children: [
          MaterialBanner(
            content: Text('Feed error: $error — showing last prices'),
            actions: [TextButton(onPressed: () => ref.invalidate(tickerProvider), child: const Text('Retry'))],
          ),
          Expanded(child: Opacity(opacity: 0.5, child: rows(value, ref))),
        ]),
        AsyncError(:final error) => Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load ticker\n$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => ref.invalidate(tickerProvider), child: const Text('Retry')),
          ],
        )),
        AsyncValue(:final value?, isLoading: true) => Column(children: [
          const LinearProgressIndicator(),
          Expanded(child: rows(value, ref)),
        ]),
        AsyncData(:final value) => rows(value, ref),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
