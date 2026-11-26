import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

final exportShareProvider = Provider<Future<ShareResult> Function(ShareParams)>(
  (ref) => SharePlus.instance.share,
);
