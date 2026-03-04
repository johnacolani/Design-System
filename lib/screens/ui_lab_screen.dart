import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/responsive.dart';
import 'ui_lab_code_snippets.dart';

/// Storybook-like UI Lab: experiment with components in an interactive canvas.
/// Adapted for mobile frameworks (Flutter preview here; same concepts for SwiftUI, Compose, etc.).
class UILabScreen extends StatefulWidget {
  const UILabScreen({super.key});

  @override
  State<UILabScreen> createState() => _UILabScreenState();
}

class _UILabScreenState extends State<UILabScreen> {
  String? _selectedStoryKey; // e.g. 'buttons.primary'

  static final List<_LabCategory> _categories = [
    // ——— Core ———
    _LabCategory(
      section: 'Core',
      id: 'buttons',
      title: 'Buttons',
      icon: Icons.smart_button,
      stories: [
        _LabStory(id: 'primary', title: 'Primary', builder: _buildPrimaryButton),
        _LabStory(id: 'secondary', title: 'Secondary (Outlined)', builder: _buildOutlinedButton),
        _LabStory(id: 'text', title: 'Text Button', builder: _buildTextButton),
        _LabStory(id: 'icon', title: 'Icon Button', builder: _buildIconButton),
        _LabStory(id: 'fab', title: 'FAB', builder: _buildFAB),
        _LabStory(id: 'disabled', title: 'Disabled', builder: _buildDisabledButton),
        _LabStory(id: 'sizes', title: 'Sizes', builder: _buildButtonSizes),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'inputs',
      title: 'Inputs',
      icon: Icons.input,
      stories: [
        _LabStory(id: 'outlined', title: 'Outlined TextField', builder: _buildOutlinedInput),
        _LabStory(id: 'filled', title: 'Filled TextField', builder: _buildFilledInput),
        _LabStory(id: 'error', title: 'With Error', builder: _buildInputWithError),
        _LabStory(id: 'multiline', title: 'Multiline', builder: _buildMultilineInput),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'cards',
      title: 'Cards',
      icon: Icons.credit_card,
      stories: [
        _LabStory(id: 'elevated', title: 'Elevated Card', builder: _buildElevatedCard),
        _LabStory(id: 'outlined', title: 'Outlined Card', builder: _buildOutlinedCard),
        _LabStory(id: 'list', title: 'Card with ListTile', builder: _buildCardWithListTile),
        _LabStory(id: 'actions', title: 'Card with Actions', builder: _buildCardWithActions),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'navigation',
      title: 'Navigation',
      icon: Icons.navigation,
      stories: [
        _LabStory(id: 'appbar', title: 'App Bar', builder: _buildAppBar),
        _LabStory(id: 'bottomnav', title: 'Bottom Navigation', builder: _buildBottomNav),
        _LabStory(id: 'navrail', title: 'Navigation Rail', builder: _buildNavRail),
        _LabStory(id: 'drawer', title: 'Drawer', builder: _buildDrawer),
        _LabStory(id: 'breadcrumb', title: 'Breadcrumb', builder: _buildBreadcrumb),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'dialogs',
      title: 'Dialogs',
      icon: Icons.message,
      stories: [
        _LabStory(id: 'alert', title: 'Alert Dialog', builder: _buildAlertDialog),
        _LabStory(id: 'simple', title: 'Simple Dialog', builder: _buildSimpleDialog),
        _LabStory(id: 'confirm', title: 'Confirmation', builder: _buildConfirmDialog),
        _LabStory(id: 'bottomsheet', title: 'Bottom Sheet', builder: _buildBottomSheet),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'tabs',
      title: 'Tabs',
      icon: Icons.tab,
      stories: [
        _LabStory(id: 'tabbar', title: 'Tab Bar', builder: _buildTabBar),
        _LabStory(id: 'tabbaricons', title: 'Tab Bar with Icons', builder: _buildTabBarWithIcons),
        _LabStory(id: 'scrollable', title: 'Scrollable Tabs', builder: _buildScrollableTabs),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'dropdowns',
      title: 'Dropdowns',
      icon: Icons.arrow_drop_down,
      stories: [
        _LabStory(id: 'dropdown', title: 'Dropdown Button', builder: _buildDropdown),
        _LabStory(id: 'dropdownform', title: 'Dropdown Form', builder: _buildDropdownForm),
        _LabStory(id: 'popupmenu', title: 'Popup Menu', builder: _buildPopupMenu),
        _LabStory(id: 'menuanchor', title: 'Menu Anchor', builder: _buildMenuAnchor),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'tables',
      title: 'Tables',
      icon: Icons.table_chart,
      stories: [
        _LabStory(id: 'simple', title: 'Simple Table', builder: _buildSimpleTable),
        _LabStory(id: 'bordered', title: 'Bordered Table', builder: _buildBorderedTable),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'lists',
      title: 'Lists',
      icon: Icons.list,
      stories: [
        _LabStory(id: 'listtile', title: 'List Tiles', builder: _buildListTiles),
        _LabStory(id: 'dividers', title: 'List with Dividers', builder: _buildListWithDividers),
        _LabStory(id: 'sections', title: 'Sectioned List', builder: _buildSectionedList),
        _LabStory(id: 'dismissible', title: 'Dismissible', builder: _buildDismissibleList),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'form',
      title: 'Form Controls',
      icon: Icons.toggle_on,
      stories: [
        _LabStory(id: 'switch', title: 'Switch', builder: _buildSwitch),
        _LabStory(id: 'checkbox', title: 'Checkbox', builder: _buildCheckbox),
        _LabStory(id: 'radio', title: 'Radio', builder: _buildRadio),
        _LabStory(id: 'slider', title: 'Slider', builder: _buildSlider),
      ],
    ),
    _LabCategory(
      section: 'Core',
      id: 'feedback',
      title: 'Feedback',
      icon: Icons.notifications_active,
      stories: [
        _LabStory(id: 'chip', title: 'Chips', builder: _buildChips),
        _LabStory(id: 'snackbar', title: 'Snackbar', builder: _buildSnackbarTrigger),
        _LabStory(id: 'linear', title: 'Linear Progress', builder: _buildLinearProgress),
        _LabStory(id: 'circular', title: 'Circular Progress', builder: _buildCircularProgress),
      ],
    ),
    // ——— Advanced ———
    _LabCategory(
      section: 'Advanced',
      id: 'charts',
      title: 'Charts',
      icon: Icons.bar_chart,
      stories: [
        _LabStory(id: 'bar', title: 'Bar Chart', builder: _buildBarChart),
        _LabStory(id: 'line', title: 'Line Chart', builder: _buildLineChart),
        _LabStory(id: 'pie', title: 'Pie Chart', builder: _buildPieChart),
      ],
    ),
    _LabCategory(
      section: 'Advanced',
      id: 'datatables',
      title: 'Data Tables',
      icon: Icons.table_rows,
      stories: [
        _LabStory(id: 'datatable', title: 'DataTable', builder: _buildDataTable),
        _LabStory(id: 'sortable', title: 'Sortable Columns', builder: _buildSortableDataTable),
      ],
    ),
    _LabCategory(
      section: 'Advanced',
      id: 'dashboards',
      title: 'Dashboards',
      icon: Icons.dashboard,
      stories: [
        _LabStory(id: 'summary', title: 'Summary Cards', builder: _buildSummaryCards),
        _LabStory(id: 'metrics', title: 'Metrics Grid', builder: _buildMetricsGrid),
        _LabStory(id: 'activity', title: 'Activity Feed', builder: _buildActivityFeed),
      ],
    ),
  ];

  _LabStory? _getSelectedStory() {
    if (_selectedStoryKey == null) return null;
    final parts = _selectedStoryKey!.split('.');
    if (parts.length != 2) return null;
    final cat = _categories.cast<_LabCategory?>().firstWhere(
          (c) => c!.id == parts[0],
          orElse: () => null,
        );
    if (cat == null) return null;
    return cat.stories.cast<_LabStory?>().firstWhere(
          (s) => s!.id == parts[1],
          orElse: () => null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final selectedStory = _getSelectedStory();
    final useWideLayout = responsive.width >= 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Lab'),
        actions: [
          if (selectedStory != null && !useWideLayout)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedStoryKey = null),
              tooltip: 'Back to list',
            ),
        ],
      ),
      body: useWideLayout
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: _buildStoryList(context, selectedStory),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildCanvas(context, selectedStory)),
              ],
            )
          : selectedStory != null
              ? _buildCanvas(context, selectedStory)
              : _buildStoryList(context, null),
    );
  }

  Widget _buildStoryList(BuildContext context, _LabStory? selectedStory) {
    String? currentSection;
    final listChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Components',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Tap a story to experiment in the canvas.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
      const SizedBox(height: 12),
    ];
    for (final cat in _categories) {
      if (cat.section != currentSection) {
        currentSection = cat.section;
        listChildren.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              currentSection,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );
      }
      listChildren.add(
        ExpansionTile(
          leading: Icon(cat.icon, size: 20, color: Theme.of(context).colorScheme.primary),
          title: Text(
            cat.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: cat.stories.map((story) {
            final key = '${cat.id}.${story.id}';
            final isSelected = _selectedStoryKey == key;
            return ListTile(
              dense: true,
              selected: isSelected,
              title: Text(story.title),
              onTap: () => setState(() => _selectedStoryKey = key),
            );
          }).toList(),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: listChildren,
    );
  }

  Widget _buildCanvas(BuildContext context, _LabStory? story) {
    if (story == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Pick a component to experiment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the list to select a story, then interact with it in the canvas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final snippets = getUILabCodeSnippets()[_selectedStoryKey];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: story.builder(context),
                ),
              ),
              if (snippets != null && snippets.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCopyCodeBar(context, snippets),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCopyCodeBar(BuildContext context, Map<String, String> snippets) {
    final platforms = [
      ('Flutter', 'flutter', Icons.code),
      ('SwiftUI', 'swiftui', Icons.phone_iphone),
      ('Compose', 'compose', Icons.android),
      ('React', 'react', Icons.web),
    ];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copy code',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: platforms.map((p) {
                final code = snippets[p.$2];
                final hasCode = code != null && code.isNotEmpty;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: hasCode
                        ? () {
                            Clipboard.setData(ClipboardData(text: code));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${p.$1} code copied to clipboard'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: hasCode ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(p.$3, size: 18, color: hasCode ? Theme.of(context).colorScheme.primary : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            p.$1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: hasCode ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                            ),
                          ),
                          if (hasCode) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.copy, size: 14, color: Theme.of(context).colorScheme.primary),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ——— Story builders (interactive) ———

  static Widget _buildPrimaryButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Primary tapped!'), duration: Duration(seconds: 1)),
            );
          },
          child: const Text('Primary Button'),
        ),
      ],
    );
  }

  static Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outlined tapped!'), duration: Duration(seconds: 1)),
        );
      },
      child: const Text('Outlined Button'),
    );
  }

  static Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text button tapped!'), duration: Duration(seconds: 1)),
        );
      },
      child: const Text('Text Button'),
    );
  }

  static Widget _buildIconButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
          tooltip: 'Like',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share),
          tooltip: 'Share',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          tooltip: 'More',
        ),
      ],
    );
  }

  static Widget _buildFAB(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton.small(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  static Widget _buildDisabledButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: null, child: const Text('Disabled')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: null, child: const Text('Disabled Outlined')),
      ],
    );
  }

  static Widget _buildButtonSizes(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            minimumSize: const Size(0, 32),
          ),
          child: const Text('Small'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () {}, child: const Text('Medium (default)')),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
          child: const Text('Large'),
        ),
      ],
    );
  }

  static Widget _buildElevatedCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elevated Card',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap and scroll. This card is interactive.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOutlinedCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Outlined card with border'),
      ),
    );
  }

  static Widget _buildCardWithListTile(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('List tile title'),
            subtitle: const Text('Subtitle text'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ListTile tapped'), duration: Duration(seconds: 1)),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  static Widget _buildCardWithActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card with actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try the buttons below.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOutlinedInput(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Outlined',
        hintText: 'Type here…',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (_) {},
    );
  }

  static Widget _buildFilledInput(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Filled',
        hintText: 'Type here…',
        filled: true,
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Widget _buildInputWithError(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com',
        errorText: 'Invalid email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Widget _buildMultilineInput(BuildContext context) {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Multiline text…',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Widget _buildDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: 'option1',
      decoration: InputDecoration(
        labelText: 'Choose',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'option1', child: Text('Option 1')),
        DropdownMenuItem(value: 'option2', child: Text('Option 2')),
        DropdownMenuItem(value: 'option3', child: Text('Option 3')),
      ],
      onChanged: (_) {},
    );
  }

  static Widget _buildSwitch(BuildContext context) {
    return const _SwitchStory();
  }

  static Widget _buildCheckbox(BuildContext context) {
    return const _CheckboxStory();
  }

  static Widget _buildRadio(BuildContext context) {
    return const _RadioStory();
  }

  static Widget _buildSlider(BuildContext context) {
    return const _SliderStory();
  }

  static Widget _buildChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(label: const Text('Default')),
        Chip(
          avatar: const CircleAvatar(child: Icon(Icons.person, size: 18)),
          label: const Text('With avatar'),
        ),
        InputChip(
          label: const Text('Deletable'),
          onDeleted: () {},
        ),
        FilterChip(
          label: const Text('Filter'),
          selected: false,
          onSelected: (_) {},
        ),
        ActionChip(
          label: const Text('Action'),
          onPressed: () {},
        ),
      ],
    );
  }

  static Widget _buildSnackbarTrigger(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Snackbar from UI Lab'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          ),
        );
      },
      icon: const Icon(Icons.notifications),
      label: const Text('Show Snackbar'),
    );
  }

  static Widget _buildLinearProgress(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: 0.6,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  static Widget _buildCircularProgress(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const CircularProgressIndicator(),
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 4,
          ),
        ),
      ],
    );
  }

  // ——— Navigation ———
  static Widget _buildAppBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: const Text('Title'),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 8),
        Text('App bar preview above', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  static Widget _buildBottomNav(BuildContext context) {
    return const _BottomNavStory();
  }

  static Widget _buildNavRail(BuildContext context) {
    return const _NavRailStory();
  }

  static Widget _buildDrawer(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Header', style: TextStyle(color: Colors.white)),
        ),
        ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () {}),
        ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
      ],
    );
  }

  static Widget _buildBreadcrumb(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        TextButton(onPressed: () {}, child: const Text('Home')),
        Text(' / ', style: TextStyle(color: Colors.grey[600])),
        TextButton(onPressed: () {}, child: const Text('Products')),
        Text(' / ', style: TextStyle(color: Colors.grey[600])),
        Text('Detail', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ——— Dialogs ———
  static Widget _buildAlertDialog(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Alert'),
          content: const Text('This is an alert dialog.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      ),
      child: const Text('Show Alert Dialog'),
    );
  }

  static Widget _buildSimpleDialog(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Choose'),
          children: [
            SimpleDialogOption(onPressed: () => Navigator.pop(ctx), child: const Text('Option A')),
            SimpleDialogOption(onPressed: () => Navigator.pop(ctx), child: const Text('Option B')),
          ],
        ),
      ),
      child: const Text('Show Simple Dialog'),
    );
  }

  static Widget _buildConfirmDialog(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Do you want to continue?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
          ],
        ),
      ).then((v) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Result: $v')));
      }),
      child: const Text('Show Confirm Dialog'),
    );
  }

  static Widget _buildBottomSheet(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bottom sheet content'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ),
            ],
          ),
        ),
      ),
      child: const Text('Show Bottom Sheet'),
    );
  }

  // ——— Tabs ———
  static Widget _buildTabBar(BuildContext context) {
    return const _TabBarStory();
  }

  static Widget _buildTabBarWithIcons(BuildContext context) {
    return const _TabBarIconsStory();
  }

  static Widget _buildScrollableTabs(BuildContext context) {
    return const _ScrollableTabsStory();
  }

  // ——— Dropdowns ———
  static Widget _buildDropdownForm(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: 'a',
      decoration: InputDecoration(
        labelText: 'Select',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'a', child: Text('Option A')),
        DropdownMenuItem(value: 'b', child: Text('Option B')),
      ],
      onChanged: (_) {},
    );
  }

  static Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: $v'))),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      child: const ListTile(
        title: Text('Tap for menu'),
        trailing: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  static Widget _buildMenuAnchor(BuildContext context) {
    return MenuAnchor(
      builder: (ctx, controller, child) => ElevatedButton(
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        child: const Text('Open menu'),
      ),
      menuChildren: [
        MenuItemButton(onPressed: () {}, child: const Text('Item 1')),
        MenuItemButton(onPressed: () {}, child: const Text('Item 2')),
      ],
    );
  }

  // ——— Tables ———
  static Widget _buildSimpleTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        children: [
          TableRow(children: [padding('A1'), padding('A2'), padding('A3')]),
          TableRow(children: [padding('B1'), padding('B2'), padding('B3')]),
        ],
      ),
    );
  }

  static Widget padding(String text) => Padding(padding: const EdgeInsets.all(8), child: Text(text));

  static Widget _buildBorderedTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [padding('Header 1'), padding('Header 2')],
          ),
          TableRow(children: [padding('Cell 1'), padding('Cell 2')]),
          TableRow(children: [padding('Cell 3'), padding('Cell 4')]),
        ],
      ),
    );
  }

  // ——— Lists ———
  static Widget _buildListTiles(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(leading: const Icon(Icons.star), title: const Text('List tile'), onTap: () {}),
        ListTile(leading: const Icon(Icons.favorite), title: const Text('Another'), subtitle: const Text('Subtitle'), onTap: () {}),
      ],
    );
  }

  static Widget _buildListWithDividers(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: const Text('Item 1'), onTap: () {}),
        const Divider(height: 1),
        ListTile(title: const Text('Item 2'), onTap: () {}),
        const Divider(height: 1),
        ListTile(title: const Text('Item 3'), onTap: () {}),
      ],
    );
  }

  static Widget _buildSectionedList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Section A', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
        ),
        ListTile(title: const Text('A1'), onTap: () {}),
        ListTile(title: const Text('A2'), onTap: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Section B', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
        ),
        ListTile(title: const Text('B1'), onTap: () {}),
      ],
    );
  }

  static Widget _buildDismissibleList(BuildContext context) {
    return const _DismissibleListStory();
  }

  // ——— Charts (fl_chart) ———
  static Widget _buildBarChart(BuildContext context) {
    return const _BarChartStory();
  }

  static Widget _buildLineChart(BuildContext context) {
    return const _LineChartStory();
  }

  static Widget _buildPieChart(BuildContext context) {
    return const _PieChartStory();
  }

  // ——— Data Tables ———
  static Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Role')),
        ],
        rows: const [
          DataRow(cells: [DataCell(Text('Alice')), DataCell(Text('Admin'))]),
          DataRow(cells: [DataCell(Text('Bob')), DataCell(Text('User'))]),
        ],
      ),
    );
  }

  static Widget _buildSortableDataTable(BuildContext context) {
    return const _SortableDataTableStory();
  }

  // ——— Dashboards ———
  static Widget _buildSummaryCards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Revenue', style: Theme.of(context).textTheme.labelMedium), const SizedBox(height: 4), Text('\$12.4k', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))])))),
            const SizedBox(width: 12),
            Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Users', style: Theme.of(context).textTheme.labelMedium), const SizedBox(height: 4), Text('1,234', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))])))),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Orders', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text('89', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ],
    );
  }

  static Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _metricCard(context, 'Active', '42', Icons.people),
        _metricCard(context, 'Pending', '7', Icons.schedule),
        _metricCard(context, 'Done', '128', Icons.check_circle),
        _metricCard(context, 'Failed', '2', Icons.error),
      ],
    );
  }

  static Widget _metricCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  static Widget _buildActivityFeed(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _activityItem(context, 'New user signed up', '2 min ago', Icons.person_add),
        _activityItem(context, 'Order #1234 completed', '1 hour ago', Icons.check_circle),
        _activityItem(context, 'Payment received', '3 hours ago', Icons.payment),
      ],
    );
  }

  static Widget _activityItem(BuildContext context, String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 20, child: Icon(icon, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]))])),
        ],
      ),
    );
  }
}

class _LabCategory {
  final String section;
  final String id;
  final String title;
  final IconData icon;
  final List<_LabStory> stories;

  const _LabCategory({
    required this.section,
    required this.id,
    required this.title,
    required this.icon,
    required this.stories,
  });
}

class _LabStory {
  final String id;
  final String title;
  final Widget Function(BuildContext context) builder;

  const _LabStory({
    required this.id,
    required this.title,
    required this.builder,
  });
}

class _SwitchStory extends StatefulWidget {
  const _SwitchStory();

  @override
  State<_SwitchStory> createState() => _SwitchStoryState();
}

class _SwitchStoryState extends State<_SwitchStory> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Enable notifications'),
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class _CheckboxStory extends StatefulWidget {
  const _CheckboxStory();

  @override
  State<_CheckboxStory> createState() => _CheckboxStoryState();
}

class _CheckboxStoryState extends State<_CheckboxStory> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text('I agree to the terms'),
      value: _checked,
      onChanged: (v) => setState(() => _checked = v ?? false),
    );
  }
}

class _RadioStory extends StatefulWidget {
  const _RadioStory();

  @override
  State<_RadioStory> createState() => _RadioStoryState();
}

class _RadioStoryState extends State<_RadioStory> {
  String _value = 'a';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: const Text('Option A'),
          value: 'a',
          groupValue: _value,
          onChanged: (v) => setState(() => _value = v!),
        ),
        RadioListTile<String>(
          title: const Text('Option B'),
          value: 'b',
          groupValue: _value,
          onChanged: (v) => setState(() => _value = v!),
        ),
      ],
    );
  }
}

class _SliderStory extends StatefulWidget {
  const _SliderStory();

  @override
  State<_SliderStory> createState() => _SliderStoryState();
}

class _SliderStoryState extends State<_SliderStory> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
        Text('Value: ${(_value * 100).round()}%'),
      ],
    );
  }
}

class _BottomNavStory extends StatefulWidget {
  const _BottomNavStory();

  @override
  State<_BottomNavStory> createState() => _BottomNavStoryState();
}

class _BottomNavStoryState extends State<_BottomNavStory> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Selected: $_index', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ],
    );
  }
}

class _NavRailStory extends StatefulWidget {
  const _NavRailStory();

  @override
  State<_NavRailStory> createState() => _NavRailStoryState();
}

class _NavRailStoryState extends State<_NavRailStory> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavigationRail(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Fav')),
            NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(child: Center(child: Text('Selected: $_index'))),
      ],
    );
  }
}

class _TabBarStory extends StatefulWidget {
  const _TabBarStory();

  @override
  State<_TabBarStory> createState() => _TabBarStoryState();
}

class _TabBarStoryState extends State<_TabBarStory> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _controller,
          tabs: const [Tab(text: 'One'), Tab(text: 'Two'), Tab(text: 'Three')],
        ),
        SizedBox(
          height: 80,
          child: TabBarView(
            controller: _controller,
            children: const [
              Center(child: Text('Content 1')),
              Center(child: Text('Content 2')),
              Center(child: Text('Content 3')),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabBarIconsStory extends StatefulWidget {
  const _TabBarIconsStory();

  @override
  State<_TabBarIconsStory> createState() => _TabBarIconsStoryState();
}

class _TabBarIconsStoryState extends State<_TabBarIconsStory> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _controller,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.star), text: 'Star'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
        SizedBox(
          height: 80,
          child: TabBarView(
            controller: _controller,
            children: const [
              Center(child: Text('Home')),
              Center(child: Text('Star')),
              Center(child: Text('Profile')),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScrollableTabsStory extends StatefulWidget {
  const _ScrollableTabsStory();

  @override
  State<_ScrollableTabsStory> createState() => _ScrollableTabsStoryState();
}

class _ScrollableTabsStoryState extends State<_ScrollableTabsStory> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Tab A'),
            Tab(text: 'Tab B'),
            Tab(text: 'Tab C'),
            Tab(text: 'Tab D'),
            Tab(text: 'Tab E'),
          ],
        ),
        SizedBox(
          height: 60,
          child: TabBarView(
            controller: _controller,
            children: List.generate(5, (i) => Center(child: Text('Content ${i + 1}'))),
          ),
        ),
      ],
    );
  }
}

class _DismissibleListStory extends StatefulWidget {
  const _DismissibleListStory();

  @override
  State<_DismissibleListStory> createState() => _DismissibleListStoryState();
}

class _DismissibleListStoryState extends State<_DismissibleListStory> {
  final _items = ['Item 1', 'Item 2', 'Item 3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _items.map((item) {
        return Dismissible(
          key: ValueKey(item),
          background: Container(color: Colors.red, alignment: Alignment.centerLeft, child: const Padding(padding: EdgeInsets.only(left: 16), child: Icon(Icons.delete, color: Colors.white))),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => setState(() => _items.remove(item)),
          child: ListTile(title: Text(item)),
        );
      }).toList(),
    );
  }
}

class _BarChartStory extends StatelessWidget {
  const _BarChartStory();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}'))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text(v.toInt().toString()))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4, color: Colors.blue, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: Colors.green, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: Colors.orange, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]),
          ],
        ),
      ),
    );
  }
}

class _LineChartStory extends StatelessWidget {
  const _LineChartStory();

  @override
  Widget build(BuildContext context) {
    final spots = [const FlSpot(0, 2), const FlSpot(1, 4), const FlSpot(2, 3), const FlSpot(3, 5), const FlSpot(4, 4)];
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}'))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text(v.toInt().toString()))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartStory extends StatelessWidget {
  const _PieChartStory();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(value: 40, color: Colors.blue, title: '40%', showTitle: true),
            PieChartSectionData(value: 30, color: Colors.green, title: '30%', showTitle: true),
            PieChartSectionData(value: 30, color: Colors.orange, title: '30%', showTitle: true),
          ],
        ),
      ),
    );
  }
}

class _SortableDataTableStory extends StatefulWidget {
  const _SortableDataTableStory();

  @override
  State<_SortableDataTableStory> createState() => _SortableDataTableStoryState();
}

class _SortableDataTableStoryState extends State<_SortableDataTableStory> {
  bool _sortAsc = true;
  int _sortCol = 0;
  final List<List<String>> _data = [
    ['Alice', 'Admin', '10'],
    ['Bob', 'User', '5'],
    ['Carol', 'Admin', '8'],
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = List<List<String>>.from(_data);
    sorted.sort((a, b) {
      final aVal = a[_sortCol];
      final bVal = b[_sortCol];
      final cmp = _sortCol == 2 ? (int.tryParse(aVal) ?? 0).compareTo(int.tryParse(bVal) ?? 0) : aVal.compareTo(bVal);
      return _sortAsc ? cmp : -cmp;
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortCol,
        sortAscending: _sortAsc,
        columns: [
          DataColumn(label: const Text('Name'), onSort: (_, asc) => setState(() { _sortCol = 0; _sortAsc = asc; })),
          DataColumn(label: const Text('Role'), onSort: (_, asc) => setState(() { _sortCol = 1; _sortAsc = asc; })),
          DataColumn(label: const Text('Score'), onSort: (_, asc) => setState(() { _sortCol = 2; _sortAsc = asc; })),
        ],
        rows: sorted.map((row) => DataRow(cells: row.map((c) => DataCell(Text(c))).toList())).toList(),
      ),
    );
  }
}
