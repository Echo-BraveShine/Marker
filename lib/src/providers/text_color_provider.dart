import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'text_color_provider.freezed.dart';

@freezed
abstract class TextColorState with _$TextColorState {
  const TextColorState._();
  const factory TextColorState({
    @Default(210) double hue,
    @Default(1) double saturation,
    @Default(.8) double brightness,
  }) = _TextColorState;
  Color get color =>
      HSVColor.fromAHSV(1, hue, saturation, brightness).toColor();
  String get hex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

final textColorProvider =
    NotifierProvider.autoDispose<TextColorNotifier, TextColorState>(
      TextColorNotifier.new,
    );

class TextColorNotifier extends Notifier<TextColorState> {
  @override
  TextColorState build() => const TextColorState();
  void setWheel(double hue, double saturation) => state = state.copyWith(
    hue: hue % 360,
    saturation: saturation.clamp(0, 1),
  );
  void setBrightness(double value) =>
      state = state.copyWith(brightness: value.clamp(0, 1));
  void setHex(String hex) {
    final color = HSVColor.fromColor(
      Color(int.parse('FF${hex.substring(1)}', radix: 16)),
    );
    state = state.copyWith(
      hue: color.saturation == 0 ? state.hue : color.hue,
      saturation: color.saturation,
      brightness: color.value,
    );
  }
}
