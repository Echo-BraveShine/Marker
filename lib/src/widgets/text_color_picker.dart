import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show Theme;
import '../providers/text_color_provider.dart';
import '../theme/marker_colors.dart';
import 'marker_dialog.dart';
import 'package:flutter/cupertino.dart';

const textColors = <String, String>{
  '红色': '#E53935',
  '橙色': '#E67E22',
  '黄色': '#B8860B',
  '绿色': '#218838',
  '蓝色': '#0066CC',
  '紫色': '#8E44AD',
  '灰色': '#6E6E73',
  '黑色': '#1D1D1F',
};
String? normalizeTextColor(String input) {
  final value = input.trim();
  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (!RegExp(r'^(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(hex)) {
    return null;
  }
  return '#${hex.length == 3 ? hex.split('').map((v) => '$v$v').join() : hex}'
      .toUpperCase();
}

class TextColorPicker extends ConsumerStatefulWidget {
  const TextColorPicker({super.key});
  @override
  ConsumerState<TextColorPicker> createState() => _TextColorPickerState();
}

class _TextColorPickerState extends ConsumerState<TextColorPicker> {
  final _hex = TextEditingController(text: '#0066CC');
  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _syncHex() {
    final hex = ref.read(textColorProvider).hex;
    _hex.value = TextEditingValue(
      text: hex,
      selection: TextSelection.collapsed(offset: hex.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final state = ref.watch(textColorProvider);
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return MarkerDialog(
      title: Text(zh ? '文字颜色' : 'Text color'),
      width: 380,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: colors.bgEditor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: colors.separatorSoft),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bgWindow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: state.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zh ? '颜色预览' : 'Color preview',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.hex,
                      style: TextStyle(
                        fontFamily: 'Menlo',
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: 168,
              height: 168,
              child: LayoutBuilder(
                builder: (context, size) {
                  void select(Offset point) {
                    final delta =
                        point - Offset(size.maxWidth / 2, size.maxHeight / 2);
                    ref
                        .read(textColorProvider.notifier)
                        .setWheel(
                          (math.atan2(delta.dy, delta.dx) * 180 / math.pi +
                                  360) %
                              360,
                          delta.distance / (size.maxWidth / 2),
                        );
                    _syncHex();
                  }

                  return Semantics(
                    label: zh ? '拖动色盘选择颜色' : 'Drag color wheel',
                    child: GestureDetector(
                      key: const Key('text-color-wheel'),
                      onTapDown: (d) => select(d.localPosition),
                      onPanStart: (d) => select(d.localPosition),
                      onPanUpdate: (d) => select(d.localPosition),
                      child: CustomPaint(
                        painter: _ColorWheel(state),
                        size: Size.infinite,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                zh ? '亮度' : 'Brightness',
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: CupertinoSlider(
                  key: const Key('text-color-brightness'),
                  value: state.brightness,
                  onChanged: (v) {
                    ref.read(textColorProvider.notifier).setBrightness(v);
                    _syncHex();
                  },
                ),
              ),
              Text(
                '${(state.brightness * 100).round()}%',
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            zh ? '常用颜色' : 'Common colors',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              for (final entry in textColors.entries)
                CupertinoButton(
                  key: ValueKey('text-color-${entry.value}'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                  onPressed: () {
                    ref.read(textColorProvider.notifier).setHex(entry.value);
                    _syncHex();
                  },
                  child: Semantics(
                    label: entry.key,
                    selected: state.hex == entry.value,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse('FF${entry.value.substring(1)}', radix: 16),
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: state.hex == entry.value
                              ? colors.textPrimary
                              : colors.separatorSoft,
                          width: state.hex == entry.value ? 2 : 1,
                        ),
                      ),
                      child: state.hex == entry.value
                          ? Icon(
                              CupertinoIcons.checkmark,
                              size: 14,
                              color: state.color.computeLuminance() > .4
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                key: const Key('text-color-preview'),
                width: 42,
                height: 36,
                decoration: BoxDecoration(
                  color: state.color,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: colors.separatorSoft),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoTextField(
                  key: const Key('text-color-hex'),
                  controller: _hex,
                  placeholder: '#RRGGBB',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  style: TextStyle(
                    fontFamily: 'Menlo',
                    fontSize: 12,
                    color: colors.textPrimary,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bgEditor,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: colors.separatorSoft),
                  ),
                  autocorrect: false,
                  onChanged: (value) {
                    final hex = normalizeTextColor(value);
                    if (hex != null) {
                      ref.read(textColorProvider.notifier).setHex(hex);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            zh ? '支持 #RGB / #RRGGBB，选择后点击应用' : 'Use #RGB / #RRGGBB, then Apply',
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _hex,
          builder: (context, value, child) => MarkerDialogButton(
            primary: true,
            onPressed: normalizeTextColor(value.text) == null
                ? null
                : () => Navigator.pop(context, normalizeTextColor(value.text)),
            child: Text(zh ? '应用颜色' : 'Apply color'),
          ),
        ),
      ],
    );
  }
}

class _ColorWheel extends CustomPainter {
  _ColorWheel(this.state);
  final TextColorState state;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: [
            for (var hue = 0; hue <= 360; hue += 60)
              HSVColor.fromAHSV(1, hue.toDouble(), 1, 1).toColor(),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [CupertinoColors.white, Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = CupertinoColors.black.withValues(alpha: 1 - state.brightness),
    );
    final angle = state.hue * math.pi / 180;
    final marker =
        center +
        Offset(math.cos(angle), math.sin(angle)) * radius * state.saturation;
    canvas.drawCircle(
      marker,
      6,
      Paint()
        ..color = CupertinoColors.black.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      marker,
      6,
      Paint()
        ..color = CupertinoColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ColorWheel oldDelegate) =>
      oldDelegate.state != state;
}
