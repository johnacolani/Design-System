import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../widgets/platform_pickers_dialogs_demo.dart';

/// Live Material + Cupertino pickers and dialogs, themed from the current app [Theme].
class PlatformPickersDialogsScreen extends StatelessWidget {
  const PlatformPickersDialogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DesignSystemProvider>(context).designSystem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickers & dialogs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Platform pickers & alerts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Material uses CalendarDatePicker, showDatePicker, and showTimePicker. '
            'Cupertino uses embedded wheels and a modal sheet. Dialogs use AlertDialog and CupertinoAlertDialog.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (ds.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Theme comes from your app; primary actions follow Material 3 / Cupertino patterns.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 24),
          const PlatformPickersDialogsDemo(),
        ],
      ),
    );
  }
}
