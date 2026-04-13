import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared demo: embedded Material/Cupertino pickers and platform dialogs.
/// Use inside [Theme] (e.g. app theme on the dashboard, token-derived theme in preview).
class PlatformPickersDialogsDemo extends StatefulWidget {
  const PlatformPickersDialogsDemo({
    super.key,
    this.compact = false,
    this.showPickers = true,
    this.showDialogs = true,
  });

  final bool compact;
  final bool showPickers;
  final bool showDialogs;

  @override
  State<PlatformPickersDialogsDemo> createState() => _PlatformPickersDialogsDemoState();
}

class _PlatformPickersDialogsDemoState extends State<PlatformPickersDialogsDemo> {
  DateTime _materialDate = DateTime.now();
  TimeOfDay _materialTime = TimeOfDay.now();
  DateTime _cupertinoDateTime = DateTime.now();

  double get _gap => widget.compact ? 12 : 20;
  double get _sectionGap => widget.compact ? 20 : 28;
  EdgeInsets get _pad => EdgeInsets.all(widget.compact ? 12 : 16);

  TextStyle _sectionTitle(BuildContext context) {
    final base = Theme.of(context).textTheme.titleSmall ?? const TextStyle();
    return base.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
  }

  Future<void> _openMaterialDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _materialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) setState(() => _materialDate = picked);
  }

  Future<void> _openMaterialTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _materialTime,
    );
    if (picked != null && mounted) setState(() => _materialTime = picked);
  }

  void _openMaterialAlert() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Material alert'),
        content: const Text('This is AlertDialog — actions use your theme’s color scheme.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _openCupertinoAlert() {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cupertino alert'),
        content: const Text('CupertinoAlertDialog for iOS-style surfaces.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    if (widget.showPickers) {
      children.add(Text('Material', style: _sectionTitle(context)));
      children.add(SizedBox(height: _gap));
      children.add(
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: _pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Embedded calendar',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                CalendarDatePicker(
                  initialDate: _materialDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  onDateChanged: (d) => setState(() => _materialDate = d),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _openMaterialDatePicker,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('showDatePicker'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openMaterialTimePicker,
                      icon: const Icon(Icons.schedule, size: 18),
                      label: Text(
                        'showTimePicker (${_materialTime.format(context)})',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      children.add(SizedBox(height: _sectionGap));
      children.add(Text('Cupertino (iOS style)', style: _sectionTitle(context)));
      children.add(SizedBox(height: _gap));
      children.add(
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: _pad,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                primaryColor: theme.colorScheme.primary,
                brightness: theme.brightness,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Embedded wheels (date & time)',
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: widget.compact ? 180 : 216,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: _cupertinoDateTime,
                      use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                      onDateTimeChanged: (d) => setState(() => _cupertinoDateTime = d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showCupertinoModalPopup<DateTime>(
                        context: context,
                        builder: (ctx) => Container(
                          height: 280,
                          color: CupertinoColors.systemBackground.resolveFrom(ctx),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CupertinoButton(
                                    child: const Text('Done'),
                                    onPressed: () => Navigator.pop(ctx, _cupertinoDateTime),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: _cupertinoDateTime,
                                  onDateTimeChanged: (d) => setState(() => _cupertinoDateTime = d),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (picked != null && mounted) setState(() => _cupertinoDateTime = picked);
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Modal Cupertino date sheet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (widget.showDialogs) {
      if (widget.showPickers) children.add(SizedBox(height: _sectionGap));
      children.add(Text('Dialogs', style: _sectionTitle(context)));
      children.add(SizedBox(height: _gap));
      children.add(
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: _pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fullscreen modal dialogs (tap to open).',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _openMaterialAlert,
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Material AlertDialog'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openCupertinoAlert,
                      icon: const Icon(Icons.phone_iphone, size: 18),
                      label: const Text('Cupertino alert'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// Theme for picker/dialog demos to match ServiceFlow preview tokens.
ThemeData pickerDemoThemeFromServiceflowColors({
  required Color primary,
  required Color onPrimary,
  required Color surface,
  required Color onSurface,
  required Color secondary,
  required Color tertiary,
  required Color outline,
}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      outline: outline,
    ),
    dialogTheme: DialogThemeData(backgroundColor: surface),
  );
}
