import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../styles/tokens.dart';

/// HSV color picker shared by theme and account customization.
class HsvColorPicker extends StatefulWidget {
  const HsvColorPicker({
    super.key,
    required this.onColorSelected,
    this.initialColor = Colors.blue,
  });

  final ValueChanged<Color> onColorSelected;
  final Color initialColor;

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late HSVColor currentColor = HSVColor.fromColor(widget.initialColor);

  @override
  Widget build(BuildContext context) {
    final color = currentColor.toColor();
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 320,
      height: 400,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BeeTokens.borderStrong(context)),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${color.r.round().toRadixString(16).padLeft(2, '0')}${color.g.round().toRadixString(16).padLeft(2, '0')}${color.b.round().toRadixString(16).padLeft(2, '0')}'
                  .toUpperCase(),
              style: TextStyle(
                color: currentColor.value > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _slider(
            context,
            label: l10n.personalizeHue(currentColor.hue.round()),
            value: currentColor.hue,
            max: 360,
            gradient: LinearGradient(
              colors: List.generate(
                7,
                (index) => HSVColor.fromAHSV(1, index * 60, 1, 1).toColor(),
              ),
            ),
            onChanged: (value) => setState(
              () => currentColor = currentColor.withHue(value),
            ),
          ),
          const SizedBox(height: 10),
          _slider(
            context,
            label: l10n
                .personalizeSaturation((currentColor.saturation * 100).round()),
            value: currentColor.saturation,
            max: 1,
            gradient: LinearGradient(colors: [
              HSVColor.fromAHSV(1, currentColor.hue, 0, currentColor.value)
                  .toColor(),
              HSVColor.fromAHSV(1, currentColor.hue, 1, currentColor.value)
                  .toColor(),
            ]),
            onChanged: (value) => setState(
              () => currentColor = currentColor.withSaturation(value),
            ),
          ),
          const SizedBox(height: 10),
          _slider(
            context,
            label:
                l10n.personalizeBrightness((currentColor.value * 100).round()),
            value: currentColor.value,
            max: 1,
            gradient: LinearGradient(colors: [
              HSVColor.fromAHSV(1, currentColor.hue, currentColor.saturation, 0)
                  .toColor(),
              HSVColor.fromAHSV(1, currentColor.hue, currentColor.saturation, 1)
                  .toColor(),
            ]),
            onChanged: (value) => setState(
              () => currentColor = currentColor.withValue(value),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onColorSelected(color),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor:
                    currentColor.value > 0.5 ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.personalizeSelectColor,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context, {
    required String label,
    required double value,
    required double max,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
  }) =>
      Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: BeeTokens.textPrimary(context))),
          Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), gradient: gradient),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 0,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
}
