import 'package:flutter/material.dart';

/// Live thumbnail for a component — same rendering as the Components screen preview panel.
class ComponentPreviewThumbnail extends StatelessWidget {
  const ComponentPreviewThumbnail({
    super.key,
    required this.category,
    required this.name,
    required this.data,
  });

  /// One of: `buttons`, `inputs`, `cards`, `navigation`, `avatars`, `modals`, `tables`, `progress`, `alerts`
  final String category;
  final String name;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final map = data is Map ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};
    switch (category) {
      case 'buttons':
        return _buildButtonPreview(context, name, map);
      case 'inputs':
        return _buildInputPreview(context, name, map);
      case 'cards':
        return _buildCardPreview(name, map);
      case 'avatars':
        return _buildAvatarPreview(context, name, map);
      case 'navigation':
        return _buildNavPreview(context, name);
      case 'modals':
        return _buildModalPreview(name, map);
      case 'tables':
        return _buildTablePreview(map);
      case 'progress':
        return _buildProgressPreview(name, map);
      case 'alerts':
        return _buildAlertPreview(name, map);
      default:
        return Text(name, style: TextStyle(fontSize: 12, color: Colors.grey[600]));
    }
  }

  static FontWeight _fontWeightFromInt(int w) {
    final v = w.clamp(100, 900);
    switch (v) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  static double parsePx(dynamic v) {
    if (v == null) return 8;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().toLowerCase();
    if (s.endsWith('px')) return (double.tryParse(s.replaceAll('px', '')) ?? 8);
    return (double.tryParse(s) ?? 8);
  }

  Widget _buildButtonPreview(BuildContext context, String name, Map<String, dynamic> data) {
    final height = parsePx(data['height'] ?? 36);
    final borderRadius = parsePx(data['borderRadius'] ?? 16);
    final padding = parsePx(data['padding'] ?? 16);
    final fontSize = parsePx(data['fontSize'] ?? 24);
    final fw = (int.tryParse(data['fontWeight']?.toString() ?? '600') ?? 600).clamp(100, 900);
    final fontWeight = _fontWeightFromInt(fw);
    final label = data['label']?.toString() ?? data['text']?.toString() ?? name;
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, height),
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
      child: Text(label),
    );
  }

  Widget _buildInputPreview(BuildContext context, String name, Map<String, dynamic> data) {
    final radius = parsePx(data['borderRadius'] ?? 8);
    return SizedBox(
      width: 160,
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: name,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildCardPreview(String name, Map<String, dynamic> data) {
    final radius = parsePx(data['borderRadius'] ?? 8);
    return Container(
      padding: EdgeInsets.all(parsePx(data['padding'] ?? 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildAvatarPreview(BuildContext context, String name, Map<String, dynamic> data) {
    final size = parsePx(data['size'] ?? data['height'] ?? 40).clamp(24.0, 72.0);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ClipOval(
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavPreview(BuildContext context, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.home, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(name, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildModalPreview(String name, Map<String, dynamic> data) {
    final radius = parsePx(data['borderRadius'] ?? data['modalCornerRadius'] ?? 12);
    final title = (data['modalTitle'] ?? data['title'] ?? name).toString();
    final body = (data['bodyText'] ?? data['body'] ?? 'Modal body text').toString();
    final cancel = (data['cancelLabel'] ?? 'Cancel').toString();
    final confirm = (data['confirmLabel'] ?? data['primaryLabel'] ?? 'OK').toString();
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxWidth: 168),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(body, style: TextStyle(fontSize: 9, color: Colors.grey.shade700), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(cancel, style: const TextStyle(fontSize: 9)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: const Size(0, 24),
                    textStyle: const TextStyle(fontSize: 9),
                  ),
                  child: Text(confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablePreview(Map<String, dynamic> data) {
    final h1 = (data['col1Header'] ?? data['header1'] ?? 'Name').toString();
    final h2 = (data['col2Header'] ?? data['header2'] ?? 'Status').toString();
    final c11 = (data['cell11'] ?? data['sample1a'] ?? '—').toString();
    final c12 = (data['cell12'] ?? data['sample1b'] ?? '—').toString();
    final c21 = (data['cell21'] ?? data['sample2a'] ?? '—').toString();
    final c22 = (data['cell22'] ?? data['sample2b'] ?? '—').toString();
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 0.5),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            Padding(padding: const EdgeInsets.all(4), child: Text(h1, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Padding(padding: const EdgeInsets.all(4), child: Text(h2, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        TableRow(
          children: [
            Padding(padding: const EdgeInsets.all(4), child: Text(c11, style: const TextStyle(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Padding(padding: const EdgeInsets.all(4), child: Text(c12, style: const TextStyle(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        TableRow(
          children: [
            Padding(padding: const EdgeInsets.all(4), child: Text(c21, style: const TextStyle(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Padding(padding: const EdgeInsets.all(4), child: Text(c22, style: const TextStyle(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressPreview(String name, Map<String, dynamic> data) {
    final indeterminate = data['progressIndeterminate'] == true || data['indeterminate'] == true || data['indeterminate'] == 'true';
    double? value;
    if (!indeterminate) {
      final raw = data['progressValue'] ?? data['value'];
      if (raw != null && raw.toString().isNotEmpty) {
        final n = double.tryParse(raw.toString());
        if (n != null) value = n > 1 ? (n / 100).clamp(0.0, 1.0) : n.clamp(0.0, 1.0);
      }
    }
    final caption = (data['progressCaption'] ?? data['caption'] ?? name).toString();
    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(caption, style: TextStyle(fontSize: 9, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAlertPreview(String name, Map<String, dynamic> data) {
    final radius = parsePx(data['borderRadius'] ?? 8);
    final variant = (data['alertVariant'] ?? data['variant'] ?? 'info').toString().toLowerCase();
    late final IconData ic;
    late final Color bg;
    late final Color border;
    late final Color fg;
    if (variant == 'error' || variant == 'danger') {
      ic = Icons.error_outline;
      bg = Colors.red.shade50;
      border = Colors.red.shade700;
      fg = Colors.red.shade900;
    } else if (variant == 'success') {
      ic = Icons.check_circle_outline;
      bg = Colors.green.shade50;
      border = Colors.green.shade700;
      fg = Colors.green.shade900;
    } else if (variant == 'warning') {
      ic = Icons.warning_amber_rounded;
      bg = Colors.amber.shade50;
      border = Colors.amber.shade800;
      fg = Colors.amber.shade900;
    } else {
      ic = Icons.info_outline;
      bg = Colors.blue.shade50;
      border = Colors.blue.shade700;
      fg = Colors.blue.shade900;
    }
    final title = (data['alertTitle'] ?? '').toString();
    final message = (data['alertMessage'] ?? data['message'] ?? name).toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      constraints: const BoxConstraints(maxWidth: 170),
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: border, width: 3)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ic, size: 16, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty) Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (title.isNotEmpty) const SizedBox(height: 2),
                Text(message, style: TextStyle(fontSize: 10, color: fg), maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small monospace summary under the thumbnail (dimensions / variant), matching Components screen.
class ComponentPreviewSizeLabel extends StatelessWidget {
  const ComponentPreviewSizeLabel({
    super.key,
    required this.category,
    required this.data,
    this.style,
  });

  final String category;
  final dynamic data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = sizeLabelText(category, data);
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: style ?? TextStyle(fontSize: 10, color: Colors.grey[600], fontFamily: 'monospace'),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static String sizeLabelText(String category, dynamic componentData) {
    final data = componentData is Map ? componentData : <String, dynamic>{};
    switch (category) {
      case 'buttons':
        final h = ComponentPreviewThumbnail.parsePx(data['height'] ?? 36);
        final br = ComponentPreviewThumbnail.parsePx(data['borderRadius'] ?? 16);
        final p = ComponentPreviewThumbnail.parsePx(data['padding'] ?? 16);
        final fs = ComponentPreviewThumbnail.parsePx(data['fontSize'] ?? 24);
        final fw = data['fontWeight']?.toString() ?? '600';
        return 'h:${h.toInt()}px  r:${br.toInt()}  p:${p.toInt()}  ${fs.toInt()}px/$fw';
      case 'inputs':
        if (data.containsKey('width') || data.containsKey('height')) {
          final w = data.containsKey('width') ? ComponentPreviewThumbnail.parsePx(data['width']).toInt() : null;
          final h = data.containsKey('height') ? ComponentPreviewThumbnail.parsePx(data['height']).toInt() : null;
          if (w != null && h != null) {
            return '$w×$h px';
          }
          return w != null ? 'w:${w}px' : 'h:${h}px';
        }
        return 'r:${ComponentPreviewThumbnail.parsePx(data['borderRadius'] ?? 8).toInt()}px';
      case 'cards':
        final p = ComponentPreviewThumbnail.parsePx(data['padding'] ?? 12);
        final br = ComponentPreviewThumbnail.parsePx(data['borderRadius'] ?? 8);
        return 'padding: ${p.toInt()}px  •  radius: ${br.toInt()}px';
      case 'avatars':
        return '${ComponentPreviewThumbnail.parsePx(data['size'] ?? data['height'] ?? 40).toInt()}px circle';
      case 'modals':
        return 'r:${ComponentPreviewThumbnail.parsePx(data['borderRadius'] ?? 12).toInt()}px · ${(data['modalTitle'] ?? data['title'] ?? '').toString().split('\n').first}';
      case 'tables':
        return '${data['col1Header'] ?? 'col1'} · ${data['col2Header'] ?? 'col2'}';
      case 'progress':
        if (data['progressIndeterminate'] == true || data['indeterminate'] == true) {
          return 'indeterminate';
        }
        return '${data['progressValue'] ?? data['value'] ?? '—'} · ${(data['progressCaption'] ?? data['caption'] ?? '').toString().split('\n').first}';
      case 'alerts':
        return '${data['alertVariant'] ?? data['variant'] ?? 'info'} · r:${ComponentPreviewThumbnail.parsePx(data['borderRadius'] ?? 8).toInt()}px';
      case 'navigation':
        return '';
      default:
        return '';
    }
  }
}
