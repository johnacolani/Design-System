import 'package:flutter/material.dart';
import '../data/material_icons_catalog.dart';

/// Full-screen searchable grid of Material icons. Pops with selected [IconData].
class ProjectIconPickerPage extends StatefulWidget {
  const ProjectIconPickerPage({super.key});

  @override
  State<ProjectIconPickerPage> createState() => _ProjectIconPickerPageState();
}

class _ProjectIconPickerPageState extends State<ProjectIconPickerPage> {
  final TextEditingController _search = TextEditingController();
  List<IconData> _filtered = List<IconData>.from(kMaterialIconsCatalog);

  @override
  void initState() {
    super.initState();
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.removeListener(_applyFilter);
    _search.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List<IconData>.from(kMaterialIconsCatalog);
      } else {
        _filtered = kMaterialIconsCatalog
            .where((icon) => icon.toString().toLowerCase().contains(q))
            .toList();
      }
    });
  }

  static String iconName(IconData icon) {
    final s = icon.toString();
    final m = RegExp(r"'([^']+)'").firstMatch(s);
    return m?.group(1) ?? 'icon';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Material icon'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search (e.g. home, settings, add)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_filtered.length} icons',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final icon = _filtered[index];
                return Material(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, icon),
                    borderRadius: BorderRadius.circular(8),
                    child: Tooltip(
                      message: iconName(icon),
                      child: Icon(icon, size: 28),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
