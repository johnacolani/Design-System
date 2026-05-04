import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/responsive.dart';
import '../utils/token_display_order.dart';
import '../widgets/component_preview_thumbnail.dart';

class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  String _selectedCategory = 'buttons';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final components = provider.designSystem.components;

    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Components'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedCategory = ['buttons', 'cards', 'inputs', 'navigation', 'avatars', 'modals', 'tables', 'progress', 'alerts'][index];
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.smart_button), text: 'Buttons'),
              Tab(icon: Icon(Icons.credit_card), text: 'Cards'),
              Tab(icon: Icon(Icons.input), text: 'Inputs'),
              Tab(icon: Icon(Icons.navigation), text: 'Navigation'),
              Tab(icon: Icon(Icons.person), text: 'Avatars'),
              Tab(icon: Icon(Icons.window), text: 'Modals'),
              Tab(icon: Icon(Icons.table_chart), text: 'Tables'),
              Tab(icon: Icon(Icons.track_changes), text: 'Progress'),
              Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildComponentCategoryTab(context, 'buttons', components.buttons, Icons.smart_button),
            _buildComponentCategoryTab(context, 'cards', components.cards, Icons.credit_card),
            _buildComponentCategoryTab(context, 'inputs', components.inputs, Icons.input),
            _buildComponentCategoryTab(context, 'navigation', components.navigation, Icons.navigation),
            _buildComponentCategoryTab(context, 'avatars', components.avatars, Icons.person),
            _buildComponentCategoryTab(context, 'modals', components.modals ?? {}, Icons.window),
            _buildComponentCategoryTab(context, 'tables', components.tables ?? {}, Icons.table_chart),
            _buildComponentCategoryTab(context, 'progress', components.progress ?? {}, Icons.track_changes),
            _buildComponentCategoryTab(context, 'alerts', components.alerts ?? {}, Icons.notifications),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCategoryTab(
    BuildContext context,
    String category,
    Map<String, dynamic> componentMap,
    IconData icon,
  ) {
    final narrow = MediaQuery.sizeOf(context).width < Breakpoints.mobile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (narrow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                category.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddComponentDialog(context, category);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Component'),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddComponentDialog(context, category);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Component'),
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (componentMap.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(icon, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No $category defined',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...TokenDisplayOrder.sortedDynamicMap(componentMap).map((entry) {
            return _buildComponentCard(context, category, entry.key, entry.value);
          }),
      ],
    );
  }

  Widget _buildComponentCard(
    BuildContext context,
    String category,
    String name,
    dynamic componentData,
  ) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final version = provider.getComponentVersion(category, name);
    final hasStates = componentData is Map && componentData.containsKey('states');
    final states = hasStates ? componentData['states'] as Map<String, dynamic>? : null;
    final stateInfo = hasStates ? ' • ${states?.length ?? 0} states' : '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text('v$version • $category component$stateInfo'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show component states if they exist
                if (hasStates && states != null && states.isNotEmpty) ...[
                  Text(
                    'Component States',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TokenDisplayOrder.sortedDynamicMap(states).map((stateEntry) {
                      return Chip(
                        label: Text(stateEntry.key),
                        avatar: Icon(
                          _getStateIcon(stateEntry.key),
                          size: 16,
                        ),
                        backgroundColor: _getStateColor(stateEntry.key).withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
                // Properties + Preview (preview in middle/right like design)
                Text(
                  'Properties',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (componentData is Map)
                            ...componentData.entries.where((entry) => entry.key != 'states').map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Flexible(
                                      child: Text(
                                        entry.value.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontFamily: 'monospace',
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ComponentPreviewThumbnail(category: category, name: name, data: componentData),
                          const SizedBox(height: 8),
                          ComponentPreviewSizeLabel(category: category, data: componentData),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        provider.bumpComponentVersion(category, name);
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('New version'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _showEditComponentDialog(context, category, name, componentData);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _deleteComponent(context, category, name);
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

  IconData _getStateIcon(String state) {
    switch (state.toLowerCase()) {
      case 'default':
        return Icons.circle;
      case 'hover':
        return Icons.mouse;
      case 'active':
        return Icons.touch_app;
      case 'focus':
        return Icons.center_focus_strong;
      case 'disabled':
        return Icons.block;
      case 'loading':
        return Icons.hourglass_empty;
      default:
        return Icons.label;
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'default':
        return Colors.blue;
      case 'hover':
        return Colors.green;
      case 'active':
        return Colors.orange;
      case 'focus':
        return Colors.purple;
      case 'disabled':
        return Colors.grey;
      case 'loading':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDialogLivePreviewLabel(BuildContext context) {
    return Text(
      'Live preview',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Map<String, dynamic> _previewMapModals(
    TextEditingController modalTitleCtrl,
    TextEditingController modalBodyCtrl,
    TextEditingController modalCancelCtrl,
    TextEditingController modalConfirmCtrl,
    TextEditingController modalRadiusCtrl,
    TextEditingController nameController,
  ) {
    return {
      'modalTitle': modalTitleCtrl.text.isNotEmpty ? modalTitleCtrl.text : nameController.text,
      'bodyText': modalBodyCtrl.text,
      'cancelLabel': modalCancelCtrl.text.isNotEmpty ? modalCancelCtrl.text : 'Cancel',
      'confirmLabel': modalConfirmCtrl.text.isNotEmpty ? modalConfirmCtrl.text : 'OK',
      'borderRadius': modalRadiusCtrl.text.isNotEmpty ? modalRadiusCtrl.text : '12px',
    };
  }

  Map<String, dynamic> _previewMapTables(
    TextEditingController h1,
    TextEditingController h2,
    TextEditingController c11,
    TextEditingController c12,
    TextEditingController c21,
    TextEditingController c22,
  ) {
    return {
      'col1Header': h1.text,
      'col2Header': h2.text,
      'cell11': c11.text,
      'cell12': c12.text,
      'cell21': c21.text,
      'cell22': c22.text,
    };
  }

  Map<String, dynamic> _previewMapProgress(
    TextEditingController val,
    TextEditingController caption,
    bool indeterminate,
  ) {
    return {
      'progressIndeterminate': indeterminate,
      if (!indeterminate) 'progressValue': val.text,
      'progressCaption': caption.text,
    };
  }

  Map<String, dynamic> _previewMapAlerts(
    TextEditingController title,
    TextEditingController message,
    String variant,
    TextEditingController radius,
  ) {
    return {
      'alertTitle': title.text,
      'alertMessage': message.text,
      'alertVariant': variant,
      'borderRadius': radius.text.isNotEmpty ? radius.text : '8px',
    };
  }

  void _showAddComponentDialog(BuildContext context, String category) {
    _showComponentDialog(context, category, null, null);
  }

  void _showComponentDialog(BuildContext context, String category, String? existingName, dynamic existingData) {
    final m = existingData is Map ? Map<String, dynamic>.from(existingData as Map) : <String, dynamic>{};
    String gv(String k, [String def = '']) => m[k]?.toString() ?? def;

    final nameController = TextEditingController(text: existingName ?? '');
    final labelController = TextEditingController(text: gv('label', gv('text', existingName ?? '')));
    final heightController = TextEditingController(text: gv('height'));
    final borderRadiusController = TextEditingController(text: gv('borderRadius'));
    final paddingController = TextEditingController(text: gv('padding'));
    final fontSizeController = TextEditingController(text: gv('fontSize'));
    final fontWeightController = TextEditingController(text: gv('fontWeight'));

    // Modal / table / progress / alert — fields that drive preview
    final modalTitleCtrl = TextEditingController(text: gv('modalTitle', gv('title')));
    final modalBodyCtrl = TextEditingController(text: gv('bodyText', gv('body', 'Main message shown inside the dialog.')));
    final modalCancelCtrl = TextEditingController(text: gv('cancelLabel', 'Cancel'));
    final modalConfirmCtrl = TextEditingController(text: gv('confirmLabel', gv('primaryLabel', 'OK')));
    final modalRadiusCtrl = TextEditingController(text: gv('borderRadius', '12px'));

    final tableH1Ctrl = TextEditingController(text: gv('col1Header', gv('header1', 'Name')));
    final tableH2Ctrl = TextEditingController(text: gv('col2Header', gv('header2', 'Status')));
    final tableC11Ctrl = TextEditingController(text: gv('cell11', gv('sample1a', 'Alice')));
    final tableC12Ctrl = TextEditingController(text: gv('cell12', gv('sample1b', 'Active')));
    final tableC21Ctrl = TextEditingController(text: gv('cell21', gv('sample2a', 'Bob')));
    final tableC22Ctrl = TextEditingController(text: gv('cell22', gv('sample2b', 'Pending')));

    final progressValCtrl = TextEditingController(text: gv('progressValue', gv('value', '60')));
    final progressCaptionCtrl = TextEditingController(text: gv('progressCaption', gv('caption', 'Uploading…')));

    bool progressIndeterminate = m['progressIndeterminate'] == true || m['indeterminate'] == true || gv('indeterminate') == 'true';

    final alertTitleCtrl = TextEditingController(text: gv('alertTitle'));
    final alertMessageCtrl = TextEditingController(text: gv('alertMessage', gv('message', 'Short message users should notice.')));
    String alertVariant = gv('alertVariant', gv('variant', 'info'));
    if (!['info', 'warning', 'error', 'success', 'danger'].contains(alertVariant)) alertVariant = 'info';

    void refreshPreview(void Function(void Function()) setDialogState) => setDialogState(() {});

    // State management
    final Set<String> selectedStates = {};
    if (existingData is Map && existingData.containsKey('states')) {
      selectedStates.addAll((existingData['states'] as Map<String, dynamic>).keys);
    } else if (category == 'buttons' || category == 'inputs') {
      // Default states for buttons and inputs
      selectedStates.addAll(['default', 'hover', 'active', 'focus', 'disabled']);
    }
    
    final availableStates = ['default', 'hover', 'active', 'focus', 'disabled', 'loading'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${existingName != null ? 'Edit' : 'Add'} ${category.substring(0, 1).toUpperCase()}${category.substring(1)} Component'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Component name (token, e.g. confirm_delete)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (['modals', 'tables', 'progress', 'alerts'].contains(category)) {
                      refreshPreview(setDialogState);
                    }
                  },
                ),
                if (category == 'buttons') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Button text (e.g., Login, Submit)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (category == 'modals') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Describe the dialog users see: title, body, and action labels. Preview updates as you type.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: modalTitleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dialog title',
                      hintText: 'e.g. Discard changes?',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: modalBodyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Body / message',
                      hintText: 'What the user reads in the modal',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: modalCancelCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Secondary button',
                            hintText: 'Cancel',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: modalConfirmCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Primary button',
                            hintText: 'OK / Save',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: modalRadiusCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Corner radius (e.g. 12px)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogLivePreviewLabel(context),
                  const SizedBox(height: 8),
                  Center(
                    child: ComponentPreviewThumbnail(
                      category: 'modals',
                      name: nameController.text.isEmpty ? 'preview' : nameController.text,
                      data: _previewMapModals(modalTitleCtrl, modalBodyCtrl, modalCancelCtrl, modalConfirmCtrl, modalRadiusCtrl, nameController),
                    ),
                  ),
                ] else if (category == 'tables') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Set column headers and sample cell text so the preview matches your table design.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tableH1Ctrl,
                          decoration: const InputDecoration(labelText: 'Column 1 header', border: OutlineInputBorder()),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: tableH2Ctrl,
                          decoration: const InputDecoration(labelText: 'Column 2 header', border: OutlineInputBorder()),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tableC11Ctrl,
                          decoration: const InputDecoration(labelText: 'Row 1, col 1', border: OutlineInputBorder()),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: tableC12Ctrl,
                          decoration: const InputDecoration(labelText: 'Row 1, col 2', border: OutlineInputBorder()),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tableC21Ctrl,
                          decoration: const InputDecoration(labelText: 'Row 2, col 1', border: OutlineInputBorder()),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: tableC22Ctrl,
                          decoration: const InputDecoration(labelText: 'Row 2, col 2', border: OutlineInputBorder()),
                          onChanged: (_) => refreshPreview(setDialogState),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDialogLivePreviewLabel(context),
                  const SizedBox(height: 8),
                  Center(
                    child: ComponentPreviewThumbnail(
                      category: 'tables',
                      name: nameController.text.isEmpty ? 'preview' : nameController.text,
                      data: _previewMapTables(tableH1Ctrl, tableH2Ctrl, tableC11Ctrl, tableC12Ctrl, tableC21Ctrl, tableC22Ctrl),
                    ),
                  ),
                ] else if (category == 'progress') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Show how full the task is (0–100) or indeterminate loading. Caption explains the task.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Indeterminate (spinner / unknown progress)'),
                    value: progressIndeterminate,
                    onChanged: (v) {
                      setDialogState(() {
                        progressIndeterminate = v ?? false;
                      });
                    },
                  ),
                  if (!progressIndeterminate) ...[
                    TextField(
                      controller: progressValCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Progress (0–100 or 0.0–1.0)',
                        hintText: '60',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => refreshPreview(setDialogState),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: progressCaptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Label under bar',
                      hintText: 'Uploading file…',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogLivePreviewLabel(context),
                  const SizedBox(height: 8),
                  Center(
                    child: ComponentPreviewThumbnail(
                      category: 'progress',
                      name: nameController.text.isEmpty ? 'preview' : nameController.text,
                      data: _previewMapProgress(progressValCtrl, progressCaptionCtrl, progressIndeterminate),
                    ),
                  ),
                ] else if (category == 'alerts') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Alerts surface important info: title (optional), message, and type (info, success, warning, error).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text('Type', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['info', 'success', 'warning', 'error'].map((v) {
                      final selected = (alertVariant == 'danger' ? 'error' : alertVariant) == v;
                      return ChoiceChip(
                        label: Text(v),
                        selected: selected,
                        onSelected: (_) {
                          setDialogState(() => alertVariant = v);
                          refreshPreview(setDialogState);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: alertTitleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title (optional)',
                      hintText: 'Heads up',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: alertMessageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'What the user should know',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: borderRadiusController,
                    decoration: const InputDecoration(
                      labelText: 'Corner radius (e.g. 8px)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => refreshPreview(setDialogState),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogLivePreviewLabel(context),
                  const SizedBox(height: 8),
                  Center(
                    child: ComponentPreviewThumbnail(
                      category: 'alerts',
                      name: nameController.text.isEmpty ? 'preview' : nameController.text,
                      data: _previewMapAlerts(alertTitleCtrl, alertMessageCtrl, alertVariant, borderRadiusController),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (e.g., 50px)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: borderRadiusController,
                    decoration: const InputDecoration(
                      labelText: 'Border Radius (e.g., 12px)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: paddingController,
                    decoration: const InputDecoration(
                      labelText: 'Padding (e.g., 12px 24px)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (category == 'buttons') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: fontSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Font Size (e.g., 20px)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fontWeightController,
                      decoration: const InputDecoration(
                        labelText: 'Font Weight (e.g., 500)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
                // Component States Section
                if (category == 'buttons' || category == 'inputs') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Component States',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select which states this component supports:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableStates.map((state) {
                      final isSelected = selectedStates.contains(state);
                      return FilterChip(
                        label: Text(state),
                        selected: isSelected,
                        avatar: Icon(
                          _getStateIcon(state),
                          size: 16,
                          color: isSelected ? Colors.white : null,
                        ),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedStates.add(state);
                            } else {
                              selectedStates.remove(state);
                            }
                          });
                        },
                        selectedColor: _getStateColor(state),
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ],
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
                if (nameController.text.isNotEmpty) {
                  final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                  final components = provider.designSystem.components;
                  final updatedCategory = Map<String, dynamic>.from(
                    category == 'buttons'
                        ? components.buttons
                        : category == 'cards'
                            ? components.cards
                            : category == 'inputs'
                                ? components.inputs
                                : category == 'navigation'
                                    ? components.navigation
                                    : category == 'avatars'
                                        ? components.avatars
                                        : category == 'modals'
                                            ? (components.modals ?? {})
                                            : category == 'tables'
                                                ? (components.tables ?? {})
                                                : category == 'progress'
                                                    ? (components.progress ?? {})
                                                    : (components.alerts ?? {}),
                  );

                  // Start from existing data when editing so we don't drop keys (e.g. label)
                  final componentData = <String, dynamic>{
                    if (existingData is Map) ...Map<String, dynamic>.from(existingData),
                  };
                  // Overwrite with form values so edits apply (use empty check to allow clearing)
                  if (category == 'modals') {
                    componentData['modalTitle'] = modalTitleCtrl.text;
                    componentData['bodyText'] = modalBodyCtrl.text;
                    componentData['cancelLabel'] = modalCancelCtrl.text;
                    componentData['confirmLabel'] = modalConfirmCtrl.text;
                    componentData['borderRadius'] = modalRadiusCtrl.text.isNotEmpty ? modalRadiusCtrl.text : '12px';
                  } else if (category == 'tables') {
                    componentData['col1Header'] = tableH1Ctrl.text;
                    componentData['col2Header'] = tableH2Ctrl.text;
                    componentData['cell11'] = tableC11Ctrl.text;
                    componentData['cell12'] = tableC12Ctrl.text;
                    componentData['cell21'] = tableC21Ctrl.text;
                    componentData['cell22'] = tableC22Ctrl.text;
                  } else if (category == 'progress') {
                    componentData['progressIndeterminate'] = progressIndeterminate;
                    componentData['indeterminate'] = progressIndeterminate;
                    if (!progressIndeterminate) {
                      componentData['progressValue'] = progressValCtrl.text;
                      componentData['value'] = progressValCtrl.text;
                    } else {
                      componentData.remove('progressValue');
                      componentData.remove('value');
                    }
                    componentData['progressCaption'] = progressCaptionCtrl.text;
                    componentData['caption'] = progressCaptionCtrl.text;
                  } else if (category == 'alerts') {
                    componentData['alertVariant'] = alertVariant;
                    componentData['variant'] = alertVariant;
                    componentData['alertTitle'] = alertTitleCtrl.text;
                    componentData['alertMessage'] = alertMessageCtrl.text;
                    componentData['message'] = alertMessageCtrl.text;
                    componentData['borderRadius'] = borderRadiusController.text.isNotEmpty ? borderRadiusController.text : '8px';
                  } else {
                    if (heightController.text.isNotEmpty) componentData['height'] = heightController.text;
                    if (borderRadiusController.text.isNotEmpty) componentData['borderRadius'] = borderRadiusController.text;
                    if (paddingController.text.isNotEmpty) componentData['padding'] = paddingController.text;
                    if (category == 'buttons') {
                      if (fontSizeController.text.isNotEmpty) componentData['fontSize'] = fontSizeController.text;
                      if (fontWeightController.text.isNotEmpty) componentData['fontWeight'] = int.tryParse(fontWeightController.text) ?? 400;
                      if (labelController.text.isNotEmpty) componentData['label'] = labelController.text;
                    }
                  }

                  // Add states if any are selected
                  if (selectedStates.isNotEmpty) {
                    final statesMap = <String, dynamic>{};
                    for (final state in selectedStates) {
                      statesMap[state] = {
                        'enabled': true,
                        'description': '${state.substring(0, 1).toUpperCase()}${state.substring(1)} state',
                      };
                    }
                    componentData['states'] = statesMap;
                  }

                  // If name changed when editing, remove the old key so the component is renamed
                  if (existingName != null && existingName != nameController.text) {
                    updatedCategory.remove(existingName);
                  }
                  updatedCategory[nameController.text] = componentData;

                  final updatedButtons = category == 'buttons' ? updatedCategory : components.buttons;
                  final updatedCards = category == 'cards' ? updatedCategory : components.cards;
                  final updatedInputs = category == 'inputs' ? updatedCategory : components.inputs;
                  final updatedNavigation = category == 'navigation' ? updatedCategory : components.navigation;
                  final updatedAvatars = category == 'avatars' ? updatedCategory : components.avatars;
                  final updatedModals = category == 'modals' ? updatedCategory : (components.modals ?? {});
                  final updatedTables = category == 'tables' ? updatedCategory : (components.tables ?? {});
                  final updatedProgress = category == 'progress' ? updatedCategory : (components.progress ?? {});
                  final updatedAlerts = category == 'alerts' ? updatedCategory : (components.alerts ?? {});

                  provider.updateDesignSystem(models.DesignSystem(
                    name: provider.designSystem.name,
                    version: provider.designSystem.version,
                    description: provider.designSystem.description,
                    created: provider.designSystem.created,
                    colors: provider.designSystem.colors,
                    typography: provider.designSystem.typography,
                    spacing: provider.designSystem.spacing,
                    borderRadius: provider.designSystem.borderRadius,
                    shadows: provider.designSystem.shadows,
                    effects: provider.designSystem.effects,
                    components: models.Components(
                      buttons: updatedButtons,
                      cards: updatedCards,
                      inputs: updatedInputs,
                      navigation: updatedNavigation,
                      avatars: updatedAvatars,
                      modals: updatedModals,
                      tables: updatedTables,
                      progress: updatedProgress,
                      alerts: updatedAlerts,
                    ),
                    grid: provider.designSystem.grid,
                    icons: provider.designSystem.icons,
                    gradients: provider.designSystem.gradients,
                    roles: provider.designSystem.roles,
                    semanticTokens: provider.designSystem.semanticTokens,
                    motionTokens: provider.designSystem.motionTokens,
                    lastModified: provider.designSystem.lastModified,
                    versionHistory: provider.designSystem.versionHistory,
                  ));

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${category.substring(0, 1).toUpperCase()}${category.substring(1)} component "${nameController.text}" ${existingName != null ? 'updated' : 'added'}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(existingName != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      labelController.dispose();
      heightController.dispose();
      borderRadiusController.dispose();
      paddingController.dispose();
      fontSizeController.dispose();
      fontWeightController.dispose();
      modalTitleCtrl.dispose();
      modalBodyCtrl.dispose();
      modalCancelCtrl.dispose();
      modalConfirmCtrl.dispose();
      modalRadiusCtrl.dispose();
      tableH1Ctrl.dispose();
      tableH2Ctrl.dispose();
      tableC11Ctrl.dispose();
      tableC12Ctrl.dispose();
      tableC21Ctrl.dispose();
      tableC22Ctrl.dispose();
      progressValCtrl.dispose();
      progressCaptionCtrl.dispose();
      alertTitleCtrl.dispose();
      alertMessageCtrl.dispose();
    });
  }

  void _showEditComponentDialog(
    BuildContext context,
    String category,
    String name,
    dynamic componentData,
  ) {
    _showComponentDialog(context, category, name, componentData);
  }

  void _deleteComponent(BuildContext context, String category, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Component'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final components = provider.designSystem.components;
              final updatedCategory = Map<String, dynamic>.from(
                category == 'buttons'
                    ? components.buttons
                    : category == 'cards'
                        ? components.cards
                        : category == 'inputs'
                            ? components.inputs
                            : category == 'navigation'
                                ? components.navigation
                                : category == 'avatars'
                                    ? components.avatars
                                    : category == 'modals'
                                        ? (components.modals ?? {})
                                        : category == 'tables'
                                            ? (components.tables ?? {})
                                            : category == 'progress'
                                                ? (components.progress ?? {})
                                                : (components.alerts ?? {}),
              );
              updatedCategory.remove(name);

              final updatedButtons = category == 'buttons' ? updatedCategory : components.buttons;
              final updatedCards = category == 'cards' ? updatedCategory : components.cards;
              final updatedInputs = category == 'inputs' ? updatedCategory : components.inputs;
              final updatedNavigation = category == 'navigation' ? updatedCategory : components.navigation;
              final updatedAvatars = category == 'avatars' ? updatedCategory : components.avatars;
              final updatedModals = category == 'modals' ? updatedCategory : (components.modals ?? {});
              final updatedTables = category == 'tables' ? updatedCategory : (components.tables ?? {});
              final updatedProgress = category == 'progress' ? updatedCategory : (components.progress ?? {});
              final updatedAlerts = category == 'alerts' ? updatedCategory : (components.alerts ?? {});

              provider.updateDesignSystem(models.DesignSystem(
                name: provider.designSystem.name,
                version: provider.designSystem.version,
                description: provider.designSystem.description,
                created: provider.designSystem.created,
                colors: provider.designSystem.colors,
                typography: provider.designSystem.typography,
                spacing: provider.designSystem.spacing,
                borderRadius: provider.designSystem.borderRadius,
                shadows: provider.designSystem.shadows,
                effects: provider.designSystem.effects,
                  components: models.Components(
                    buttons: updatedButtons,
                    cards: updatedCards,
                    inputs: updatedInputs,
                    navigation: updatedNavigation,
                    avatars: updatedAvatars,
                    modals: updatedModals,
                    tables: updatedTables,
                    progress: updatedProgress,
                    alerts: updatedAlerts,
                  ),
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
                semanticTokens: provider.designSystem.semanticTokens,
                motionTokens: provider.designSystem.motionTokens,
                lastModified: provider.designSystem.lastModified,
                versionHistory: provider.designSystem.versionHistory,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Component "$name" deleted!'),
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
