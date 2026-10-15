import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beecount/l10n/app_localizations.dart';
import 'package:beecount/widgets/charts/asset_composition_chart.dart';

void main() {
  testWidgets('资产构成按账户拆分扇区，且不把第九个及之后账户合并', (tester) async {
    final accounts = List.generate(
      10,
      (index) => (
        id: index + 1,
        name: '账户${index + 1}',
        backgroundColor: null,
        totalBalance: (index + 1) * 100.0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: Scaffold(body: AssetCompositionChart(data: accounts)),
        ),
      ),
    );

    final chart = tester.widget<PieChart>(find.byType(PieChart));
    expect(chart.data.sections, hasLength(10));
    expect(chart.data.sections.map((section) => section.value),
        containsAll([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]));
    expect(find.text('账户10'), findsOneWidget);
  });
}
