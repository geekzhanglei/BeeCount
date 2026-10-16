import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../styles/tokens.dart';
import '../../utils/kelly_calculator.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: BeeTokens.scaffoldBackground(context),
      appBar: AppBar(title: Text(l10n.widgetsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: Text(l10n.kellyFormulaTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KellyFormulaPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KellyFormulaPage extends StatefulWidget {
  const KellyFormulaPage({super.key});

  @override
  State<KellyFormulaPage> createState() => _KellyFormulaPageState();
}

class _KellyFormulaPageState extends State<KellyFormulaPage> {
  final _winRateController = TextEditingController(text: '55');
  final _ratioController = TextEditingController(text: '1');

  @override
  void dispose() {
    _winRateController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final winRate = double.tryParse(_winRateController.text);
    final ratio = double.tryParse(_ratioController.text);
    final valid = winRate != null &&
        winRate >= 0 &&
        winRate <= 100 &&
        ratio != null &&
        ratio > 0;
    final fullKelly = valid
        ? kellyFraction(
            winProbability: winRate / 100,
            netWinPerLoss: ratio,
          )
        : null;
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: BeeTokens.scaffoldBackground(context),
      appBar: AppBar(title: Text(l10n.kellyFormulaTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _winRateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.kellyWinRate,
                      suffixText: '%',
                      errorText: winRate == null || winRate < 0 || winRate > 100
                          ? l10n.kellyWinRateError
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ratioController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.kellyWinLossRatio,
                      errorText: ratio == null || ratio <= 0
                          ? l10n.kellyWinLossRatioError
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (valid) ...[
            _KellyResultCard(
              title: l10n.kellyFullKelly,
              fraction: fullKelly!,
              color: color,
            ),
            const SizedBox(height: 10),
            _KellyResultCard(
              title: l10n.kellyHalfKelly,
              fraction: fullKelly / 2,
              color: color,
            ),
            const SizedBox(height: 12),
            if (fullKelly == 0)
              Text(l10n.kellyNoEdge,
                  style: TextStyle(color: BeeTokens.textSecondary(context))),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.kellyFormulaExplanation),
                  const SizedBox(height: 12),
                  Text(l10n.kellyRiskNote,
                      style: TextStyle(
                          color: BeeTokens.textSecondary(context),
                          height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KellyResultCard extends StatelessWidget {
  const _KellyResultCard({
    required this.title,
    required this.fraction,
    required this.color,
  });

  final String title;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(title),
          trailing: Text(
            '${(fraction * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
