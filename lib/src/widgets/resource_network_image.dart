import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

/// Share the plugin's disk cache across thumbnails, preview and image dialogs.
/// Environments without filesystem plugins retain Flutter's memory image cache.
class ResourceNetworkImage extends StatefulWidget {
  const ResourceNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.memCacheWidth,
    this.placeholder,
    this.errorWidget,
    this.retryBuilder,
  });
  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;
  final int? memCacheWidth;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final Widget Function(BuildContext, String, Object, VoidCallback)?
  retryBuilder;
  static final Future<bool> _diskAvailable = _checkDisk();
  static Future<bool> _checkDisk() async {
    try {
      await getTemporaryDirectory();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> evict(String url) async {
    if (await _diskAvailable) {
      await CachedNetworkImage.evictFromCache(url);
      await ResizeImage(CachedNetworkImageProvider(url), width: 96).evict();
    } else {
      await NetworkImage(url).evict();
      await ResizeImage(NetworkImage(url), width: 96).evict();
    }
  }

  @override
  State<ResourceNetworkImage> createState() => _ResourceNetworkImageState();
}

class _ResourceNetworkImageState extends State<ResourceNetworkImage> {
  int _revision = 0;
  bool _retrying = false;
  Future<void> _retry() async {
    if (_retrying) return;
    _retrying = true;
    try {
      await ResourceNetworkImage.evict(widget.imageUrl);
    } catch (_) {
      // Cache storage failure must not prevent a fresh image request.
    } finally {
      if (mounted) {
        setState(() {
          _retrying = false;
          _revision++;
        });
      }
    }
  }

  Widget _error(BuildContext context, String url, Object error) =>
      widget.retryBuilder?.call(context, url, error, _retry) ??
      widget.errorWidget?.call(context, url, error) ??
      const Icon(CupertinoIcons.photo);

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: ResourceNetworkImage._diskAvailable,
    builder: (context, snapshot) {
      Widget loading() =>
          widget.placeholder?.call(context, widget.imageUrl) ??
          const CupertinoActivityIndicator(animating: false, radius: 8);
      if (!snapshot.hasData) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: loading(),
        );
      }
      if (snapshot.data == true) {
        return CachedNetworkImage(
          key: ValueKey((widget.imageUrl, _revision)),
          imageUrl: widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          memCacheWidth: widget.memCacheWidth,
          placeholder: widget.placeholder ?? (_, _) => loading(),
          errorWidget: _error,
        );
      }
      return Image.network(
        widget.imageUrl,
        key: ValueKey((widget.imageUrl, _revision)),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.memCacheWidth,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : loading(),
        errorBuilder: (context, error, _) =>
            _error(context, widget.imageUrl, error),
      );
    },
  );
}
