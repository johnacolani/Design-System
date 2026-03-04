import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/component_repository.dart';
import '../providers/design_system_provider.dart';

/// Lazy-loaded component gallery: section content loads only when a category
/// is opened (ExpansionTile). Uses ComponentRepository pagination; no Firestore
/// reads in build()—only when user expands a category or loads more.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  final ComponentRepository _repo = ComponentRepository();

  /// Category IDs to show. In a full Firestore setup, load from repo.getCategoryIds() once.
  static const List<String> _categories = [
    'buttons',
    'cards',
    'inputs',
    'navigation',
    'avatars',
    'modals',
    'tables',
    'progress',
    'alerts',
  ];

  @override
  Widget build(BuildContext context) {
    final designSystemId = Provider.of<DesignSystemProvider>(context)
        .designSystem
        .name
        .isNotEmpty
        ? _designSystemIdFromContext(context)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Component Gallery')),
      body: designSystemId == null || designSystemId.isEmpty
          ? const Center(child: Text('Open a design system to load components.'))
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _LazyCategoryTile(
                  designSystemId: designSystemId,
                  category: _categories[index],
                  repository: _repo,
                );
              },
            ),
    );
  }

  /// Assumption: design system id might be stored in provider or route.
  /// If you use local-only projects, use a stable id (e.g. project name hash).
  String _designSystemIdFromContext(BuildContext context) {
    final name = Provider.of<DesignSystemProvider>(context).designSystem.name;
    return name.isEmpty ? '' : name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
  }
}

class _LazyCategoryTile extends StatefulWidget {
  const _LazyCategoryTile({
    required this.designSystemId,
    required this.category,
    required this.repository,
  });

  final String designSystemId;
  final String category;
  final ComponentRepository repository;

  @override
  State<_LazyCategoryTile> createState() => _LazyCategoryTileState();
}

class _LazyCategoryTileState extends State<_LazyCategoryTile> {
  List<ComponentItem> _items = [];
  bool _loaded = false;
  bool _loading = false;
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _hasMore = false;

  Future<void> _loadPage({bool append = false}) async {
    if (_loading) return;
    setState(() => _loading = true);

    final result = await widget.repository.getComponentPage(
      designSystemId: widget.designSystemId,
      category: widget.category,
      limit: ComponentRepository.defaultPageSize,
      startAfter: append ? _lastDoc : null,
    );

    if (!mounted) return;
    setState(() {
      if (append) {
        _items = [..._items, ...result.items];
      } else {
        _items = result.items;
      }
      _lastDoc = result.lastDoc;
      _hasMore = result.hasMore;
      _loaded = true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.category),
      subtitle: Text(_loaded ? '${_items.length} components' : 'Tap to load'),
      onExpansionChanged: (expanded) {
        if (expanded && !_loaded && !_loading) _loadPage();
      },
      children: [
        if (_loading && _items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_items.isEmpty && _loaded)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No components in this category')),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.data.toString()),
                      ),
                    )),
                if (_hasMore && _loaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: _loading ? null : () => _loadPage(append: true),
                      icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add),
                      label: const Text('Load more'),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
