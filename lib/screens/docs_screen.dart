import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/docs_service.dart';

/// Renders markdown docs from assets (public) or Firestore (private).
/// DocsService caches results; no repeated reads on rebuild.
class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {
  final DocsService _docsService = DocsService();
  static const List<String> _publicDocIds = ['getting-started', 'tokens-guide'];
  String? _selectedDocId;
  String _content = '';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_publicDocIds.isNotEmpty) _selectedDocId ??= _publicDocIds.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDocId != null && mounted) _loadDoc(_selectedDocId!);
    });
  }

  Future<void> _loadDoc(String docId) async {
    if (_selectedDocId == docId && _content.isNotEmpty && !_loading) return;
    setState(() {
      _selectedDocId = docId;
      _loading = true;
      _error = null;
    });

    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.id;
    final useAsset = userId == null || userId.startsWith('guest_') || _publicDocIds.contains(docId);

    final content = await _docsService.getDoc(
      docId: docId,
      useAsset: useAsset,
      userId: (userId != null && !userId.startsWith('guest_')) ? userId : null,
    );

    if (mounted && _selectedDocId == docId) {
      setState(() {
        _content = content;
        _loading = false;
        if (content.isEmpty && _error == null) _error = 'No content';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentation')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 220,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Public (assets)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ..._publicDocIds.map((id) => ListTile(
                      title: Text(id),
                      selected: _selectedDocId == id,
                      onTap: () => _loadDoc(id),
                    )),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : Markdown(
                        data: _content.isEmpty ? '_Select a doc._' : _content,
                        selectable: true,
                        padding: const EdgeInsets.all(24),
                      ),
          ),
        ],
      ),
    );
  }
}
