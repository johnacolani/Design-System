import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/design_system.dart' as models;
import '../providers/design_system_provider.dart';

/// Component gallery: section content loads when a category is opened (ExpansionTile).
/// Uses the current design system's in-memory components so it works without Firestore.
class ComponentGalleryScreen extends StatelessWidget {
  const ComponentGalleryScreen({super.key});

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
    final designSystem = Provider.of<DesignSystemProvider>(context).designSystem;
    final hasDesignSystem = designSystem.name.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Component Gallery')),
      body: !hasDesignSystem
          ? const Center(child: Text('Open a design system to load components.'))
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _LazyCategoryTile(
                  category: _categories[index],
                  components: designSystem.components,
                );
              },
            ),
    );
  }
}

/// Simple item for display (name + data map).
class _GalleryItem {
  const _GalleryItem({required this.name, required this.data});
  final String name;
  final Map<String, dynamic> data;
}

class _LazyCategoryTile extends StatefulWidget {
  const _LazyCategoryTile({
    required this.category,
    required this.components,
  });

  final String category;
  final models.Components components;

  @override
  State<_LazyCategoryTile> createState() => _LazyCategoryTileState();
}

class _LazyCategoryTileState extends State<_LazyCategoryTile> {
  List<_GalleryItem> _items = [];
  bool _loaded = false;

  Map<String, dynamic> _getCategoryMap() {
    switch (widget.category) {
      case 'buttons':
        return widget.components.buttons;
      case 'cards':
        return widget.components.cards;
      case 'inputs':
        return widget.components.inputs;
      case 'navigation':
        return widget.components.navigation;
      case 'avatars':
        return widget.components.avatars;
      case 'modals':
        return widget.components.modals ?? {};
      case 'tables':
        return widget.components.tables ?? {};
      case 'progress':
        return widget.components.progress ?? {};
      case 'alerts':
        return widget.components.alerts ?? {};
      default:
        return {};
    }
  }

  void _loadFromDesignSystem() {
    if (_loaded) return;
    final map = _getCategoryMap();
    final items = map.entries.map((e) {
      final data = e.value is Map ? Map<String, dynamic>.from(e.value as Map) : <String, dynamic>{'value': e.value};
      return _GalleryItem(name: e.key, data: data);
    }).toList();
    setState(() {
      _items = items;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.category),
      subtitle: Text(_loaded ? '${_items.length} components' : 'Tap to load'),
      onExpansionChanged: (expanded) {
        if (expanded && !_loaded) _loadFromDesignSystem();
      },
      children: [
        if (_items.isEmpty && _loaded)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No components in this category')),
          )
        else if (_items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            if (item.data['description'] != null && item.data['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(item.data['description'].toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                              ),
                            const SizedBox(height: 12),
                            _ComponentPreview(category: widget.category, name: item.name, data: item.data),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
      ],
    );
  }
}

/// Renders a small drawn preview of a component (button, card, input, etc.).
class _ComponentPreview extends StatelessWidget {
  const _ComponentPreview({
    required this.category,
    required this.name,
    required this.data,
  });

  final String category;
  final String name;
  final Map<String, dynamic> data;

  double _parsePx(dynamic v) {
    if (v == null) return 8;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().toLowerCase();
    if (s.endsWith('px')) return (double.tryParse(s.replaceAll('px', '')) ?? 8);
    return (double.tryParse(s) ?? 8);
  }

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case 'buttons':
        return _buildButtonPreview();
      case 'cards':
        return _buildCardPreview();
      case 'inputs':
        return _buildInputPreview();
      case 'navigation':
        return _buildNavigationPreview();
      case 'avatars':
        return _buildAvatarPreview();
      case 'modals':
        return _buildModalPreview();
      case 'tables':
        return _buildTablePreview();
      case 'progress':
        return _buildProgressPreview();
      case 'alerts':
        return _buildAlertPreview();
      default:
        return Text(data.toString(), style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis);
    }
  }

  Widget _buildButtonPreview() {
    final label = data['label']?.toString() ?? name;
    // Final component spec: height 36, border radius 16, padding 16, font size 24, font weight
    const double specHeight = 36;
    const double specBorderRadius = 16;
    const double specPadding = 16;
    const double specFontSize = 24;
    const FontWeight specFontWeight = FontWeight.w600;

    final button = ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, specHeight),
        padding: const EdgeInsets.symmetric(horizontal: specPadding, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(specBorderRadius)),
        textStyle: const TextStyle(fontSize: specFontSize, fontWeight: specFontWeight),
      ),
      child: Text(label),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      alignment: Alignment.center,
      child: button,
    );
  }

  Widget _buildCardPreview() {
    final radius = _parsePx(data['borderRadius']);
    final padding = _parsePx(data['padding']);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 48, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Card content preview', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildInputPreview() {
    final radius = _parsePx(data['borderRadius']);
    return SizedBox(
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          labelText: name,
          hintText: 'Placeholder',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
          contentPadding: EdgeInsets.symmetric(horizontal: _parsePx(data['padding']), vertical: 8),
        ),
      ),
    );
  }

  Widget _buildNavigationPreview() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavChip(icon: Icons.home, label: 'Home'),
        const SizedBox(width: 6),
        _NavChip(icon: Icons.search, label: 'Search'),
        const SizedBox(width: 6),
        _NavChip(icon: Icons.person, label: name),
      ],
    );
  }

  Widget _buildAvatarPreview() {
    final size = _parsePx(data['size'] ?? data['height'] ?? 40);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: size / 2, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
        if (size < 56) ...[
          const SizedBox(width: 8),
          CircleAvatar(radius: 28, backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
        ],
      ],
    );
  }

  Widget _buildModalPreview() {
    final radius = _parsePx(data['borderRadius']);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Modal body content', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () {}, child: const Text('OK')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTablePreview() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 32,
        dataRowMinHeight: 28,
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Col 1', style: TextStyle(fontSize: 11))),
          DataColumn(label: Text('Col 2', style: TextStyle(fontSize: 11))),
        ],
        rows: [
          DataRow(cells: [DataCell(Text(name, style: const TextStyle(fontSize: 11))), const DataCell(Text('—', style: TextStyle(fontSize: 11)))]),
          const DataRow(cells: [DataCell(Text('Row 2', style: TextStyle(fontSize: 11))), DataCell(Text('—', style: TextStyle(fontSize: 11)))]),
        ],
      ),
    );
  }

  Widget _buildProgressPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildAlertPreview() {
    final radius = _parsePx(data['borderRadius']);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border(left: BorderSide(color: Colors.amber.shade700, width: 4)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: TextStyle(fontSize: 12, color: Colors.amber.shade900))),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {},
    );
  }
}
