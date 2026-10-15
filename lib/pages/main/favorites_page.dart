import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../services/favorite_image_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<File> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final images = await FavoriteImageService.list();
    if (mounted) setState(() => _images = images);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) return;
    for (final image in picked) {
      await FavoriteImageService.add(File(image.path));
    }
    await _load();
  }

  Future<void> _openImage(int index) async {
    final removed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _FavoriteImagePreviewPage(
          images: _images,
          initialIndex: index,
        ),
      ),
    );
    if (removed == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        actions: [
          IconButton(
            tooltip: l10n.favoritesAddImages,
            onPressed: _addImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 48,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(l10n.favoritesEmpty),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _addImages,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(l10n.favoritesAddImages),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _openImage(index),
                    child: Hero(
                      tag: _images[index].path,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_images[index], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _FavoriteImagePreviewPage extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  const _FavoriteImagePreviewPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FavoriteImagePreviewPage> createState() =>
      _FavoriteImagePreviewPageState();
}

class _FavoriteImagePreviewPageState extends State<_FavoriteImagePreviewPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _remove() async {
    await FavoriteImageService.remove(widget.images[_index]);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.images.length}'),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).commonDelete,
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) => InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Center(
            child: Hero(
              tag: widget.images[index].path,
              child: Image.file(widget.images[index], fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
