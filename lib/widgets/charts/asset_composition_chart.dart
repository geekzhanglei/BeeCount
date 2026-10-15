import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../styles/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/ui_scale_extensions.dart';
import '../biz/biz.dart';

/// 资产构成饼图
class AssetCompositionChart extends ConsumerStatefulWidget {
  final List<
          ({int id, String name, String? backgroundColor, double totalBalance})>
      data;

  /// embedded 模式下不渲染外层 SectionCard 和标题
  final bool embedded;

  const AssetCompositionChart({
    super.key,
    required this.data,
    this.embedded = false,
  });

  @override
  ConsumerState<AssetCompositionChart> createState() =>
      _AssetCompositionChartState();
}

class _AssetCompositionChartState extends ConsumerState<AssetCompositionChart> {
  int _touchedIndex = -1;
  static const _fallbackColors = <Color>[
    Color(0xFF5B8FF9),
    Color(0xFF61DDAA),
    Color(0xFFFF9D4D),
    Color(0xFFE8684A),
    Color(0xFF9270CA),
    Color(0xFF6DC8EC),
    Color(0xFFFFD666),
    Color(0xFF7262FD),
    Color(0xFF78D3F8),
    Color(0xFF9661BC),
    Color(0xFFF6903D),
    Color(0xFF008685),
    Color(0xFFF08BB4),
    Color(0xFF5D7092),
    Color(0xFFB8A4E5),
    Color(0xFF3BA272),
    Color(0xFFFC8452),
    Color(0xFF5470C6),
  ];

  List<({int id, String name, double value, Color color})> _buildSlices() {
    // 过滤出正值项（资产构成只看正余额）
    final positiveItems = widget.data.where((d) => d.totalBalance > 0).toList()
      ..sort((a, b) => b.totalBalance.compareTo(a.totalBalance));

    return positiveItems.map((item) {
      final colorText = item.backgroundColor?.replaceFirst('#', '');
      final customColor =
          colorText == null ? null : int.tryParse(colorText, radix: 16);
      return (
        id: item.id,
        name: item.name,
        value: item.totalBalance,
        color: customColor == null
            ? _fallbackColors[item.id.abs() % _fallbackColors.length]
            : Color(0xFF000000 | customColor),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final positiveSum = widget.data
        .where((d) => d.totalBalance > 0)
        .fold(0.0, (sum, d) => sum + d.totalBalance);

    if (widget.data.isEmpty || positiveSum <= 0) {
      return const SizedBox.shrink();
    }

    final slices = _buildSlices();
    if (slices.isEmpty) return const SizedBox.shrink();

    final hasSelection = _touchedIndex >= 0 && _touchedIndex < slices.length;
    final selectedSlice = hasSelection ? slices[_touchedIndex] : null;

    final chartContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        if (_touchedIndex != -1) {
                          setState(() => _touchedIndex = -1);
                        }
                        return;
                      }
                      final idx = response.touchedSection!.touchedSectionIndex;
                      if (idx != _touchedIndex) {
                        setState(() => _touchedIndex = idx);
                      }
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 42,
                  sections: List.generate(slices.length, (i) {
                    final s = slices[i];
                    final pct = (s.value / positiveSum * 100);
                    final isTouched = i == _touchedIndex;
                    return PieChartSectionData(
                      color: s.color,
                      value: s.value,
                      title: pct >= 5 ? '${pct.toStringAsFixed(1)}%' : '',
                      radius: isTouched ? 48 : 40,
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 12 : 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedSlice != null
                        ? selectedSlice.name
                        : l10n.assetComposition,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: BeeTokens.textTertiary(context),
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AmountText(
                    value: selectedSlice?.value ?? positiveSum,
                    signed: false,
                    decimals: 0,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BeeTokens.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: slices.map((s) {
            final pct = (s.value / positiveSum * 100).toStringAsFixed(1);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  s.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: BeeTokens.textPrimary(context),
                        fontSize: 11,
                      ),
                ),
                const SizedBox(width: 2),
                Text(
                  '$pct%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: BeeTokens.textTertiary(context),
                        fontSize: 10,
                      ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );

    if (widget.embedded) {
      return chartContent;
    }

    return SectionCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12.0.scaled(context, ref)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assetComposition,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BeeTokens.textPrimary(context),
              ),
            ),
            SizedBox(height: 12.0.scaled(context, ref)),
            chartContent,
          ],
        ),
      ),
    );
  }
}
