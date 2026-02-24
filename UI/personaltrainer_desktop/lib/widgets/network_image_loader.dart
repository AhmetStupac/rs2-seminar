import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/providers/blob_storage_provider.dart';

class NetworkImageLoader extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const NetworkImageLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  State<NetworkImageLoader> createState() => _NetworkImageLoaderState();
}

class _NetworkImageLoaderState extends State<NetworkImageLoader> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      print('📥 NetworkImageLoader: Loading image from: ${widget.imageUrl}');
      final blobProvider = BlobStorageProvider();
      final bytes = await blobProvider.downloadImageBytes(widget.imageUrl);

      print('📥 NetworkImageLoader: Received bytes: ${bytes?.length ?? 0}');

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      print('❌ NetworkImageLoader: Error loading image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_hasError || _imageBytes == null) {
      return widget.errorWidget ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Icon(Icons.broken_image, size: 32, color: Colors.grey[400]),
          );
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Icon(Icons.broken_image, size: 32, color: Colors.grey[400]);
      },
    );
  }
}
