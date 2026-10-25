import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ticker/models/tick.dart';
import 'package:riverpod_ticker/providers/ticker_providers.dart';
import 'package:riverpod_ticker/ticker_page.dart';

final sample = [Tick(symbol: 'BTC', price: 100, change: 1.5, at: DateTime(2026))];

void main() {
  testWidgets('loading shows spinner', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [tickerProvider.overrideWith((ref) => const Stream<List<Tick>>.empty())],
      child: const MaterialApp(home: TickerPage()),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('data shows BTC', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [tickerProvider.overrideWith((ref) => Stream.value(sample))],
      child: const MaterialApp(home: TickerPage()),
    ));
    await tester.pump();
    expect(find.text('BTC'), findsOneWidget);
    expect(find.textContaining('▲'), findsOneWidget);
  });

  testWidgets('error shows retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [tickerProvider.overrideWith((ref) => Stream<List<Tick>>.error('boom'))],
      child: const MaterialApp(home: TickerPage()),
    ));
    await tester.pump();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('error after data keeps BTC', (tester) async {
    final controller = StreamController<List<Tick>>();
    addTearDown(controller.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [tickerProvider.overrideWith((ref) => controller.stream)],
      child: const MaterialApp(home: TickerPage()),
    ));
    controller.add(sample);
    await tester.pump();
    controller.addError('boom');
    await tester.pump();
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
  });
}
