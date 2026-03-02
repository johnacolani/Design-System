import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class SemanticTokensScreen extends StatefulWidget {
  const SemanticTokensScreen({super.key});

  @override
  State<SemanticTokensScreen> createState() => _SemanticTokensScreenState();
}

class _SemanticTokensScreenState extends State<SemanticTokensScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'color';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = ['color', 'typography', 'spacing', 'shadow', 'borderRadius'][_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final semanticTokens = provider.designSystem.semanticTokens;

    Map<String, dynamic> currentCategory = {};
    switch (_selectedCategory) {
      case 'color':
        currentCategory = semanticTokens.color;
        break;
      case 'typography':
        currentCategory = semanticTokens.typography;
        break;
      case 'spacing':
        currentCategory = semanticTokens.spacing;
        break;
      case 'shadow':
        currentCategory = semanticTokens.shadow;
        break;
      case 'borderRadius':
        currentCategory = semanticTokens.borderRadius;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Semantic Tokens'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Color'),
            Tab(icon: Icon(Icons.text_fields), text: 'Typography'),
            Tab(icon: Icon(Icons.space_bar), text: 'Spacing'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Shadow'),
            Tab(icon: Icon(Icons.rounded_corner), text: 'Radius'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddSemanticTokenDialog(context, _selectedCategory);
            },
            tooltip: 'Add Semantic Token',
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: Column(
          children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Semantic tokens map purpose-driven names to base tokens. Use them for theme switching and better abstraction.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade900,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: currentCategory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(_selectedCategory),
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No semantic tokens for $_selectedCategory',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddSemanticTokenDialog(context, _selectedCategory);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Semantic Token'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentCategory.length,
                    itemBuilder: (context, index) {
                      final entry = currentCategory.entries.elementAt(index);
                      return _buildSemanticTokenCard(context, _selectedCategory, entry.key, entry.value);
                    },
                  ),
          ),
        ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'color':
        return Icons.palette;
      case 'typography':
        return Icons.text_fields;
      case 'spacing':
        return Icons.space_bar;
      case 'shadow':
        return Icons.auto_awesome;
      case 'borderRadius':
        return Icons.rounded_corner;
      default:
        return Icons.label;
    }
  }

  Widget _buildSemanticTokenCard(
    BuildContext context,
    String category,
    String name,
    dynamic tokenData,
  ) {
    final baseTokenRef = tokenData is Map ? (tokenData['baseTokenReference'] as String? ?? '') : '';
    final description = tokenData is Map ? (tokenData['description'] as String?) : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text('Maps to: $baseTokenRef'),
        leading: Icon(_getCategoryIcon(category), color: _getCategoryColor(category)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Category', category),
                _buildInfoRow('Base Token', baseTokenRef),
                if (description != null && description.isNotEmpty) _buildInfoRow('Description', description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showEditSemanticTokenDialog(context, category, name, tokenData);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _deleteSemanticToken(context, category, name);
                      },
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: label == 'Base Token' ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'color':
        return Colors.deepPurple;
      case 'typography':
        return Colors.blue;
      case 'spacing':
        return Colors.green;
      case 'shadow':
        return Colors.purple;
      case 'borderRadius':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAddSemanticTokenDialog(BuildContext context, String category) {
    _showSemanticTokenDialog(context, category, null, null);
  }

  void _showSemanticTokenDialog(
    BuildContext context,
    String category,
    String? existingName,
    dynamic existingTokenData,
  ) {
    final nameController = TextEditingController(text: existingName ?? '');
    final baseTokenRef = existingTokenData is Map ? (existingTokenData['baseTokenReference'] as String? ?? '') : '';
    final desc = existingTokenData is Map ? (existingTokenData['description'] as String? ?? '') : '';
    final baseTokenController = TextEditingController(text: baseTokenRef);
    final descriptionController = TextEditingController(text: desc);

    // Get available base tokens for reference
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final designSystem = provider.designSystem;
    final List<String> availableBaseTokens = _getAvailableBaseTokens(category, designSystem);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${existingName != null ? 'Edit' : 'Add'} Semantic Token'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Semantic Token Name',
                  hintText: _getExampleName(category),
                  border: const OutlineInputBorder(),
                  helperText: 'Purpose-driven name (e.g., text-primary, surface-elevated)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: baseTokenController,
                decoration: InputDecoration(
                  labelText: 'Base Token Reference',
                  hintText: _getExampleReference(category),
                  border: const OutlineInputBorder(),
                  helperText: 'Reference to base token (e.g., primary.primary or spacing.4)',
                ),
              ),
              if (availableBaseTokens.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Available base tokens:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: availableBaseTokens.take(10).map((token) {
                    return ActionChip(
                      label: Text(token, style: const TextStyle(fontSize: 11)),
                      onPressed: () {
                        baseTokenController.text = token;
                      },
                    );
                  }).toList(),
                ),
                if (availableBaseTokens.length > 10)
                  Text(
                    '... and ${availableBaseTokens.length - 10} more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && baseTokenController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final semanticTokens = provider.designSystem.semanticTokens;

                final tokenData = <String, dynamic>{
                  'name': nameController.text,
                  'category': category,
                  'baseTokenReference': baseTokenController.text,
                  if (descriptionController.text.isNotEmpty) 'description': descriptionController.text,
                };

                final updatedColor = Map<String, dynamic>.from(semanticTokens.color);
                final updatedTypography = Map<String, dynamic>.from(semanticTokens.typography);
                final updatedSpacing = Map<String, dynamic>.from(semanticTokens.spacing);
                final updatedShadow = Map<String, dynamic>.from(semanticTokens.shadow);
                final updatedBorderRadius = Map<String, dynamic>.from(semanticTokens.borderRadius);

                switch (category) {
                  case 'color':
                    updatedColor[nameController.text] = tokenData;
                    break;
                  case 'typography':
                    updatedTypography[nameController.text] = tokenData;
                    break;
                  case 'spacing':
                    updatedSpacing[nameController.text] = tokenData;
                    break;
                  case 'shadow':
                    updatedShadow[nameController.text] = tokenData;
                    break;
                  case 'borderRadius':
                    updatedBorderRadius[nameController.text] = tokenData;
                    break;
                }

                provider.updateSemanticTokens(models.SemanticTokens(
                  color: updatedColor,
                  typography: updatedTypography,
                  spacing: updatedSpacing,
                  shadow: updatedShadow,
                  borderRadius: updatedBorderRadius,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Semantic token "${nameController.text}" ${existingName != null ? 'updated' : 'added'}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(existingName != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  String _getExampleName(String category) {
    switch (category) {
      case 'color':
        return 'text-primary';
      case 'typography':
        return 'heading-large';
      case 'spacing':
        return 'spacing-container';
      case 'shadow':
        return 'shadow-elevated';
      case 'borderRadius':
        return 'radius-card';
      default:
        return 'token-name';
    }
  }

  String _getExampleReference(String category) {
    switch (category) {
      case 'color':
        return 'primary.primary';
      case 'typography':
        return 'textStyles.heading';
      case 'spacing':
        return 'spacing.4';
      case 'shadow':
        return 'shadows.medium';
      case 'borderRadius':
        return 'borderRadius.medium';
      default:
        return 'category.token';
    }
  }

  List<String> _getAvailableBaseTokens(String category, models.DesignSystem designSystem) {
    final List<String> tokens = [];
    switch (category) {
      case 'color':
        // Add all color tokens
        designSystem.colors.primary.forEach((key, value) {
          tokens.add('primary.$key');
        });
        designSystem.colors.semantic.forEach((key, value) {
          tokens.add('semantic.$key');
        });
        break;
      case 'typography':
        // Add typography tokens
        designSystem.typography.textStyles.forEach((key, value) {
          tokens.add('textStyles.$key');
        });
        designSystem.typography.fontSizes.forEach((key, value) {
          tokens.add('fontSizes.$key');
        });
        break;
      case 'spacing':
        // Add spacing tokens
        designSystem.spacing.values.forEach((key, value) {
          tokens.add('spacing.$key');
        });
        break;
      case 'shadow':
        // Add shadow tokens
        designSystem.shadows.values.forEach((key, value) {
          tokens.add('shadows.$key');
        });
              break;
      case 'borderRadius':
        // Add border radius tokens
        tokens.add('borderRadius.none');
        tokens.add('borderRadius.small');
        tokens.add('borderRadius.base');
        tokens.add('borderRadius.medium');
        tokens.add('borderRadius.large');
        tokens.add('borderRadius.xl');
        tokens.add('borderRadius.full');
        break;
    }
    return tokens;
  }

  void _showEditSemanticTokenDialog(
    BuildContext context,
    String category,
    String name,
    dynamic tokenData,
  ) {
    _showSemanticTokenDialog(context, category, name, tokenData);
  }

  void _deleteSemanticToken(BuildContext context, String category, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semantic Token'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final semanticTokens = provider.designSystem.semanticTokens;

              final updatedColor = Map<String, dynamic>.from(semanticTokens.color);
              final updatedTypography = Map<String, dynamic>.from(semanticTokens.typography);
              final updatedSpacing = Map<String, dynamic>.from(semanticTokens.spacing);
              final updatedShadow = Map<String, dynamic>.from(semanticTokens.shadow);
              final updatedBorderRadius = Map<String, dynamic>.from(semanticTokens.borderRadius);

              switch (category) {
                case 'color':
                  updatedColor.remove(name);
                  break;
                case 'typography':
                  updatedTypography.remove(name);
                  break;
                case 'spacing':
                  updatedSpacing.remove(name);
                  break;
                case 'shadow':
                  updatedShadow.remove(name);
                  break;
                case 'borderRadius':
                  updatedBorderRadius.remove(name);
                  break;
              }

              provider.updateSemanticTokens(models.SemanticTokens(
                color: updatedColor,
                typography: updatedTypography,
                spacing: updatedSpacing,
                shadow: updatedShadow,
                borderRadius: updatedBorderRadius,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Semantic token "$name" deleted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
