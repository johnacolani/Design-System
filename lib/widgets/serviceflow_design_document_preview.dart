import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/design_system.dart' as models;
import 'platform_pickers_dialogs_demo.dart';

const String _kTypographySample = 'The quick brown fox jumps over the lazy dog.';

/// Matches [assets/docs/serviceflow-design-system.html] layout: page background,
/// hero, TOC pills, section titles with accent underline, cards, grid swatches,
/// token tables, gradient row, role mock, component grid.
class ServiceflowDesignDocumentPreview extends StatefulWidget {
  const ServiceflowDesignDocumentPreview({
    super.key,
    required this.designSystem,
  });

  final models.DesignSystem designSystem;

  @override
  State<ServiceflowDesignDocumentPreview> createState() =>
      _ServiceflowDesignDocumentPreviewState();
}

class _ServiceflowDesignDocumentPreviewState
    extends State<ServiceflowDesignDocumentPreview> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'principles': GlobalKey(),
    'color': GlobalKey(),
    'typography': GlobalKey(),
    'layout': GlobalKey(),
    'radius': GlobalKey(),
    'elevation': GlobalKey(),
    'motion': GlobalKey(),
    'gradients': GlobalKey(),
    'roles': GlobalKey(),
    'components': GlobalKey(),
    'pickers': GlobalKey(),
    'alerts': GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(String id) {
    final key = _sectionKeys[id];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.designSystem;
    final t = _SfTokens.fromDesignSystem(ds);

    return ColoredBox(
      color: t.pageBg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
            child: DefaultTextStyle.merge(
              style: GoogleFonts.roboto(
                color: t.pageFg,
                fontSize: 16,
                height: 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SfHero(ds: ds, tokens: t, onTocTap: _scrollTo),
                  const SizedBox(height: 40),
                  _SfSection(
                    id: 'principles',
                    sectionKey: _sectionKeys['principles']!,
                    title: 'Principles',
                    lead: 'Decisions locked for ${ds.name} — reference for product UI.',
                    tokens: t,
                    child: _SfPrinciplesSection(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'color',
                    sectionKey: _sectionKeys['color']!,
                    title: 'Color',
                    lead: 'Click any swatch to copy HEX to the clipboard.',
                    tokens: t,
                    child: _SfColorSection(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'typography',
                    sectionKey: _sectionKeys['typography']!,
                    title: 'Typography',
                    lead: '${ds.typography.fontFamily.primary} — sizes in logical px.',
                    tokens: t,
                    child: _SfTypographySection(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'layout',
                    sectionKey: _sectionKeys['layout']!,
                    title: 'Layout & spacing',
                    lead: '${ds.grid.columns}-column grid, ${ds.grid.gutter} gutter.',
                    tokens: t,
                    child: _SfSpacingTable(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'radius',
                    sectionKey: _sectionKeys['radius']!,
                    title: 'Border radius',
                    tokens: t,
                    child: _SfRadiusTable(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'elevation',
                    sectionKey: _sectionKeys['elevation']!,
                    title: 'Icons & elevation',
                    tokens: t,
                    child: _SfIconsElevationSection(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'motion',
                    sectionKey: _sectionKeys['motion']!,
                    title: 'Motion',
                    lead: 'Duration and easing from your motion tokens.',
                    tokens: t,
                    child: _SfMotionTable(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'gradients',
                    sectionKey: _sectionKeys['gradients']!,
                    title: 'Gradients',
                    tokens: t,
                    child: _SfGradientsRow(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'roles',
                    sectionKey: _sectionKeys['roles']!,
                    title: 'Role dashboards',
                    lead: 'Tap a role to preview app bar and body wash.',
                    tokens: t,
                    child: _SfRolesMock(ds: ds, tokens: t),
                  ),
                  _SfSection(
                    id: 'components',
                    sectionKey: _sectionKeys['components']!,
                    title: 'Components',
                    lead: 'Recommended patterns using your tokens.',
                    tokens: t,
                    child: _SfComponentsGrid(tokens: t),
                  ),
                  _SfSection(
                    id: 'pickers',
                    sectionKey: _sectionKeys['pickers']!,
                    title: 'Date & time pickers',
                    lead: 'Embedded Material calendar, showDatePicker / showTimePicker, and Cupertino wheels + modal sheet.',
                    tokens: t,
                    child: Theme(
                      data: pickerDemoThemeFromServiceflowColors(
                        primary: t.accent,
                        onPrimary: Colors.white,
                        surface: t.card,
                        onSurface: t.pageFg,
                        secondary: t.secondary,
                        tertiary: t.coral,
                        outline: t.divider,
                      ),
                      child: const PlatformPickersDialogsDemo(
                        compact: true,
                        showPickers: true,
                        showDialogs: false,
                      ),
                    ),
                  ),
                  _SfSection(
                    id: 'alerts',
                    sectionKey: _sectionKeys['alerts']!,
                    title: 'Alert dialogs',
                    lead: 'Material AlertDialog and CupertinoAlertDialog using the same token-driven theme.',
                    tokens: t,
                    child: Theme(
                      data: pickerDemoThemeFromServiceflowColors(
                        primary: t.accent,
                        onPrimary: Colors.white,
                        surface: t.card,
                        onSurface: t.pageFg,
                        secondary: t.secondary,
                        tertiary: t.coral,
                        outline: t.divider,
                      ),
                      child: const PlatformPickersDialogsDemo(
                        compact: true,
                        showPickers: false,
                        showDialogs: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Generated from Design System Builder. Export to PDF for a matching document.',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: t.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SfTokens {
  _SfTokens({
    required this.pageBg,
    required this.pageFg,
    required this.card,
    required this.cardMuted,
    required this.cardBorder,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentPressed,
    required this.accentSoft,
    required this.coral,
    required this.coralPressed,
    required this.secondary,
    required this.secondarySoft,
    required this.gold,
    required this.divider,
    required this.textOnLight,
    required this.textTealDeep,
    required this.textBodyMuted,
  });

  final Color pageBg;
  final Color pageFg;
  final Color card;
  final Color cardMuted;
  final Color cardBorder;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentPressed;
  final Color accentSoft;
  final Color coral;
  final Color coralPressed;
  final Color secondary;
  final Color secondarySoft;
  final Color gold;
  final Color divider;
  final Color textOnLight;
  final Color textTealDeep;
  final Color textBodyMuted;

  static _SfTokens fromDesignSystem(models.DesignSystem ds) {
    Color parse(String? hex, Color fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      try {
        var h = hex.replaceAll('#', '').trim();
        if (h.length == 6) h = 'FF$h';
        return Color(int.parse(h, radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    String? primaryHex;
    final p = ds.colors.primary;
    if (p['primary'] is Map && (p['primary'] as Map)['value'] != null) {
      primaryHex = (p['primary'] as Map)['value']?.toString();
    } else if (p.isNotEmpty) {
      final first = p.values.first;
      if (first is Map && first['value'] != null) {
        primaryHex = first['value']?.toString();
      }
    }
    final accent = parse(primaryHex, const Color(0xFF6FA8A1));
    final accentPressed = Color.lerp(accent, Colors.black, 0.12) ?? accent;
    final accentSoft = Color.lerp(accent, Colors.white, 0.35) ?? accent;

    return _SfTokens(
      pageBg: const Color(0xFFF5F2EB),
      pageFg: const Color(0xFF1A1917),
      card: const Color(0xFFFFFCF7),
      cardMuted: const Color(0xFFFAF7F2),
      cardBorder: const Color(0x141A1917),
      textSecondary: const Color(0xFF5C5A56),
      textTertiary: const Color(0xFF6D6A65),
      accent: accent,
      accentPressed: accentPressed,
      accentSoft: accentSoft,
      coral: const Color(0xFFD98C7A),
      coralPressed: const Color(0xFFC47A68),
      secondary: const Color(0xFF7B6F9D),
      secondarySoft: const Color(0xFF9A91B5),
      gold: const Color(0xFFC9A96E),
      divider: const Color(0xFFE8E4DC),
      textOnLight: const Color(0xFF3D3C39),
      textTealDeep: const Color(0xFF3D5C55),
      textBodyMuted: const Color(0xFF4A4844),
    );
  }
}

class _SfHero extends StatelessWidget {
  const _SfHero({
    required this.ds,
    required this.tokens,
    required this.onTocTap,
  });

  final models.DesignSystem ds;
  final _SfTokens tokens;
  final void Function(String id) onTocTap;

  @override
  Widget build(BuildContext context) {
    final slug = ds.name.replaceAll(' ', '_').toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: tokens.cardBorder.withValues(alpha: 0.5)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ds.name,
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                  color: tokens.pageFg,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: tokens.textSecondary,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: ds.description.isNotEmpty
                          ? '${ds.description} '
                          : 'Single source of truth for colors, type, layout, and components. ',
                    ),
                    const TextSpan(text: 'Tokens are authored in this project and exported as JSON. '),
                    TextSpan(
                      text: 'See ',
                      style: GoogleFonts.roboto(fontSize: 14, color: tokens.textSecondary, height: 1.45),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: _inlineCode('Preview → Color', tokens),
                    ),
                    const TextSpan(text: ' and '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: _inlineCode('Export PDF', tokens),
                    ),
                    const TextSpan(text: ' for handoff. Version '),
                    TextSpan(
                      text: ds.version,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: tokens.textSecondary,
                      ),
                    ),
                    const TextSpan(text: ' · '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: _inlineCode(slug, tokens),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _tocChip('Principles', 'principles', tokens, onTocTap),
                  _tocChip('Color', 'color', tokens, onTocTap),
                  _tocChip('Typography', 'typography', tokens, onTocTap),
                  _tocChip('Layout', 'layout', tokens, onTocTap),
                  _tocChip('Radius', 'radius', tokens, onTocTap),
                  _tocChip('Elevation', 'elevation', tokens, onTocTap),
                  _tocChip('Motion', 'motion', tokens, onTocTap),
                  _tocChip('Gradients', 'gradients', tokens, onTocTap),
                  _tocChip('Role dashboards', 'roles', tokens, onTocTap),
                  _tocChip('Components', 'components', tokens, onTocTap),
                  _tocChip('Pickers', 'pickers', tokens, onTocTap),
                  _tocChip('Alerts', 'alerts', tokens, onTocTap),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _inlineCode(String text, _SfTokens tokens) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: tokens.accent.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: GoogleFonts.robotoMono(fontSize: 12, color: tokens.textTealDeep),
    ),
  );
}

Widget _tocChip(
  String label,
  String id,
  _SfTokens tokens,
  void Function(String) onTap,
) {
  const chipBg = Color(0xFFEEF4F2);
  const chipBorder = Color(0xFFB8B5B0);
  return Material(
    color: chipBg,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      onTap: () => onTap(id),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: chipBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: tokens.pageFg,
          ),
        ),
      ),
    ),
  );
}

class _SfSection extends StatelessWidget {
  const _SfSection({
    required this.id,
    required this.sectionKey,
    required this.title,
    this.lead,
    required this.tokens,
    required this.child,
  });

  final String id;
  final GlobalKey sectionKey;
  final String title;
  final String? lead;
  final _SfTokens tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: sectionKey,
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: tokens.pageFg,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            height: 2,
            color: tokens.accent,
          ),
          if (lead != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                lead!,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF4A4844),
                  height: 1.5,
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _SfCard extends StatelessWidget {
  const _SfCard({required this.tokens, required this.child});

  final _SfTokens tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.cardBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1917).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// --- Principles (screenshot: bullet card) ---

class _SfPrinciplesSection extends StatelessWidget {
  const _SfPrinciplesSection({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    final h = _colorToHex(tokens.accent);
    final c = _colorToHex(tokens.coral);
    final p = _colorToHex(tokens.secondary);
    final g = _colorToHex(tokens.gold);
    final bgHex = _colorToHex(tokens.pageBg);
    final darkHex = _colorToHex(tokens.pageFg);

    return _SfCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _principleBullet(
            context,
            [
              const TextSpan(text: 'Tetradic anchors — '),
              const TextSpan(text: 'Primary (teal) ', style: TextStyle(fontWeight: FontWeight.w700)),
              WidgetSpan(child: _copyableHex(context, h, tokens)),
              const TextSpan(text: ' · Coral (CTA / highlights) ', style: TextStyle(fontWeight: FontWeight.w700)),
              WidgetSpan(child: _copyableHex(context, c, tokens)),
              const TextSpan(text: ' · Secondary (purple) ', style: TextStyle(fontWeight: FontWeight.w700)),
              WidgetSpan(child: _copyableHex(context, p, tokens)),
              const TextSpan(text: ' · Gold (soft accent) ', style: TextStyle(fontWeight: FontWeight.w700)),
              WidgetSpan(child: _copyableHex(context, g, tokens)),
              const TextSpan(
                text: '. Ramps use HSL lightness steps from each anchor where defined in your palette.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _principleBullet(
            context,
            [
              const TextSpan(text: 'Pairing — '),
              TextSpan(
                text: 'Use structure vs CTA contrast from your primary and accent tokens; links and focus rings often align with the primary hue.',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _principleBullet(
            context,
            [
              const TextSpan(text: 'Surfaces — '),
              const TextSpan(text: 'Light app background '),
              WidgetSpan(child: _copyableHex(context, bgHex, tokens)),
              const TextSpan(text: '. Dark scaffold '),
              WidgetSpan(child: _copyableHex(context, darkHex, tokens)),
              const TextSpan(text: ' (warm charcoal).'),
            ],
          ),
          const SizedBox(height: 12),
          _principleBullet(
            context,
            [
              const TextSpan(text: 'Staff dashboards — '),
              TextSpan(
                text: 'Gradient headers and body washes can follow role tokens in ',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => _scrollToSection(context, 'roles'),
                  child: Text(
                    'Role dashboards',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: tokens.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: ' below.',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _principleBullet(
            context,
            [
              TextSpan(
                text: 'Type — ${ds.typography.fontFamily.primary} with system-ui fallbacks; scale from ',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => _scrollToSection(context, 'typography'),
                  child: Text(
                    'Typography',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: tokens.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: '.',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _principleBullet(
            context,
            [
              TextSpan(
                text: 'Grid — ${ds.grid.columns} columns, ${ds.grid.gutter} gutter (see ',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => _scrollToSection(context, 'layout'),
                  child: Text(
                    'Layout & spacing',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: tokens.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: ').',
                style: GoogleFonts.roboto(color: tokens.textBodyMuted, fontSize: 14, height: 1.45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _principleBullet(BuildContext context, List<InlineSpan> spans) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: GoogleFonts.roboto(fontSize: 14, height: 1.45, color: tokens.pageFg)),
        Expanded(
          child: Text.rich(
            TextSpan(style: GoogleFonts.roboto(fontSize: 14, height: 1.45, color: tokens.pageFg), children: spans),
          ),
        ),
      ],
    );
  }
}

void _scrollToSection(BuildContext context, String id) {
  final state = context.findAncestorStateOfType<_ServiceflowDesignDocumentPreviewState>();
  state?._scrollTo(id);
}

Widget _copyableHex(BuildContext context, String hex, _SfTokens tokens) {
  return GestureDetector(
    onTap: () async {
      await Clipboard.setData(ClipboardData(text: hex));
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Copied $hex'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
          backgroundColor: tokens.pageFg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    },
    child: Text(
      hex,
      style: GoogleFonts.robotoMono(
        fontSize: 13,
        color: tokens.textTealDeep,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: tokens.accent.withValues(alpha: 0.6),
      ),
    ),
  );
}

String _colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

// --- Color grid (Core & surfaces + ramps + palettes) ---

class _SfColorSection extends StatelessWidget {
  const _SfColorSection({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  static final RegExp _rampDark = RegExp(r'^primary_dark\d+$');
  static final RegExp _rampLight = RegExp(r'^primary_light\d+$');

  @override
  Widget build(BuildContext context) {
    final primary = ds.colors.primary;
    if (primary.isEmpty && ds.colors.semantic.isEmpty) {
      return _SfCard(
        tokens: tokens,
        child: Text('No colors defined yet.', style: GoogleFonts.roboto(color: tokens.textSecondary)),
      );
    }

    final blocks = <Widget>[];

    final core = <String, dynamic>{};
    final ramp = <String, dynamic>{};
    for (final e in primary.entries) {
      final k = e.key.toString();
      if (_rampDark.hasMatch(k) || _rampLight.hasMatch(k) || k == 'primary') {
        ramp[k] = e.value;
      } else {
        core[k] = e.value;
      }
    }

    if (core.isNotEmpty) {
      blocks.add(_SfColorBlock(
        title: 'Core & surfaces',
        monoSubtitle: null,
        orderedEntries: core.entries.toList(),
        tokens: tokens,
        maxColumns: 5,
      ));
    }

    final rampOrdered = _orderPrimaryRamp(ramp);
    if (rampOrdered.isNotEmpty) {
      blocks.add(_SfColorBlock(
        title: 'Primary (teal) ramp',
        monoSubtitle: 'primary_dark1…10 / primary_light1…10',
        orderedEntries: rampOrdered,
        tokens: tokens,
        maxColumns: 5,
      ));
    }

    final otherPalettes = <String, Map<String, dynamic>>{
      'Semantic': ds.colors.semantic,
      'Blue': ds.colors.blue ?? {},
      'Green': ds.colors.green ?? {},
      'Orange': ds.colors.orange ?? {},
      'Purple': ds.colors.purple ?? {},
      'Red': ds.colors.red ?? {},
      'Grey': ds.colors.grey ?? {},
    };

    for (final e in otherPalettes.entries) {
      if (e.value.isEmpty) continue;
      blocks.add(_SfColorBlock(
        title: e.key,
        monoSubtitle: null,
        orderedEntries: e.value.entries.toList()..sort((a, b) => a.key.toString().compareTo(b.key.toString())),
        tokens: tokens,
        maxColumns: 5,
      ));
    }

    if (blocks.isEmpty) {
      return _SfCard(
        tokens: tokens,
        child: Text('No colors defined yet.', style: GoogleFonts.roboto(color: tokens.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map((w) => Padding(padding: const EdgeInsets.only(bottom: 16), child: w))
          .toList(),
    );
  }

  static List<MapEntry<String, dynamic>> _orderPrimaryRamp(Map<String, dynamic> ramp) {
    if (ramp.isEmpty) return [];
    int tailNum(String k) {
      final m = RegExp(r'(\d+)$').firstMatch(k);
      return m != null ? int.parse(m.group(1)!) : 0;
    }

    final dark = ramp.entries.where((e) => _rampDark.hasMatch(e.key.toString())).toList()
      ..sort((a, b) => tailNum(b.key.toString()).compareTo(tailNum(a.key.toString())));
    final mid = ramp.entries.where((e) => e.key.toString() == 'primary').toList();
    final light = ramp.entries.where((e) => _rampLight.hasMatch(e.key.toString())).toList()
      ..sort((a, b) => tailNum(a.key.toString()).compareTo(tailNum(b.key.toString())));
    return [...dark, ...mid, ...light];
  }
}

class _SfColorBlock extends StatelessWidget {
  const _SfColorBlock({
    required this.title,
    this.monoSubtitle,
    required this.orderedEntries,
    required this.tokens,
    this.maxColumns = 5,
  });

  final String title;
  final String? monoSubtitle;
  final List<MapEntry<String, dynamic>> orderedEntries;
  final _SfTokens tokens;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: tokens.textOnLight,
          ),
        ),
        if (monoSubtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            monoSubtitle!,
            style: GoogleFonts.robotoMono(fontSize: 13, color: tokens.textSecondary),
          ),
        ],
        const SizedBox(height: 12),
        _SfCard(
          tokens: tokens,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cross = (w / 180).floor().clamp(2, maxColumns);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.12,
                children: orderedEntries.map((ent) {
                  final val = ent.value is Map
                      ? (ent.value as Map)['value']?.toString() ?? ''
                      : ent.value.toString();
                  final color = _parseColor(val);
                  return _SfSwatch(name: ent.key.toString(), hex: val, color: color, tokens: tokens);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SfSwatch extends StatefulWidget {
  const _SfSwatch({
    required this.name,
    required this.hex,
    required this.color,
    required this.tokens,
  });

  final String name;
  final String hex;
  final Color color;
  final _SfTokens tokens;

  @override
  State<_SfSwatch> createState() => _SfSwatchState();
}

class _SfSwatchState extends State<_SfSwatch> {
  bool _hover = false;

  String get _clipboardHex {
    var h = widget.hex.replaceAll('#', '').trim().toUpperCase();
    if (h.length == 6) return '#$h';
    if (h.length == 8 && h.startsWith('FF')) return '#${h.substring(2)}';
    return widget.hex.startsWith('#') ? widget.hex.toUpperCase() : '#$h';
  }

  String get _displayHex => _clipboardHex;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _clipboardHex));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Copied $_clipboardHex'),
        behavior: SnackBarBehavior.floating,
        width: 280,
        duration: const Duration(milliseconds: 1600),
        backgroundColor: widget.tokens.pageFg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          color: Colors.white,
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _copy(context),
            splashColor: widget.tokens.accent.withValues(alpha: 0.2),
            child: Semantics(
              button: true,
              label: 'Copy color ${widget.name}, $_clipboardHex',
              child: Tooltip(
                message: 'Tap to copy $_clipboardHex',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 72,
                      child: ColoredBox(color: widget.color),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _displayHex,
                            style: GoogleFonts.robotoMono(fontSize: 12, color: widget.tokens.pageFg),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _parseColor(String raw) {
  try {
    var h = raw.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

// --- Typography (screenshot: purple label + LH + pangram) ---

class _SfTypographySection extends StatelessWidget {
  const _SfTypographySection({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  static FontWeight _weightForKey(String key) {
    final k = key.toUpperCase();
    if (k.contains('DISPLAY') || k.contains('HEADING')) return FontWeight.w700;
    if (k.contains('TITLE') || k.contains('SUBTITLE')) return FontWeight.w600;
    return FontWeight.w400;
  }

  @override
  Widget build(BuildContext context) {
    final t = ds.typography;
    final fontName = t.fontFamily.primary;
    final rows = <Widget>[];

    for (final e in t.fontSizes.entries) {
      final rawPx = e.value.value;
      final pxNum = _parsePx(rawPx);
      final lh = e.value.lineHeight;
      final label = '${e.key.toUpperCase()} · ${rawPx.toUpperCase()} / LH $lh';
      final lhNum = double.tryParse(lh) ?? (pxNum >= 40 ? 1.2 : 1.5);
      TextStyle sampleStyle;
      try {
        sampleStyle = GoogleFonts.getFont(
          fontName,
          fontSize: pxNum.clamp(10, 56),
          fontWeight: _weightForKey(e.key),
          height: lhNum,
          color: tokens.pageFg,
        );
      } catch (_) {
        sampleStyle = GoogleFonts.roboto(
          fontSize: pxNum.clamp(10, 56),
          fontWeight: _weightForKey(e.key),
          height: lhNum,
          color: tokens.pageFg,
        );
      }
      rows.add(
        _sfTypographyScaleRow(
          label: label,
          sampleStyle: sampleStyle,
          tokens: tokens,
        ),
      );
    }

    if (rows.isEmpty) {
      return _SfCard(
        tokens: tokens,
        child: Text(
          'Add font sizes in Typography to see the type scale (e.g. display, heading, body).',
          style: GoogleFonts.roboto(color: tokens.textSecondary, fontSize: 14),
        ),
      );
    }

    return _SfCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

Widget _sfTypographyScaleRow({
  required String label,
  required TextStyle sampleStyle,
  required _SfTokens tokens,
}) {
  return Container(
    padding: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: tokens.divider)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: tokens.secondary,
            letterSpacing: 0.06 * 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(_kTypographySample, style: sampleStyle),
      ],
    ),
  );
}

double _parsePx(String s) {
  return double.tryParse(s.replaceAll('px', '').trim()) ?? 14;
}

// --- Tables (HTML table.token-table) ---

class _SfSpacingTable extends StatelessWidget {
  const _SfSpacingTable({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    return _SfCard(
      tokens: tokens,
      child: _tokenTable(
        ['Token', 'Value'],
        ds.spacing.values.entries.map((e) => [e.key, e.value]).toList(),
        tokens,
      ),
    );
  }
}

class _SfRadiusTable extends StatelessWidget {
  const _SfRadiusTable({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    final r = ds.borderRadius;
    final data = [
      ['none', r.none],
      ['sm', r.sm],
      ['base', r.base],
      ['md', r.md],
      ['lg', r.lg],
      ['xl', r.xl],
      ['full', r.full],
    ];
    return _SfCard(
      tokens: tokens,
      child: _tokenTable(['Token', 'Value'], data, tokens),
    );
  }
}

class _SfMotionTable extends StatelessWidget {
  const _SfMotionTable({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[];
    for (final e in ds.motionTokens.duration.entries) {
      rows.add([e.key, e.value]);
    }
    for (final e in ds.motionTokens.easing.entries) {
      rows.add([e.key, e.value]);
    }
    if (rows.isEmpty) {
      return _SfCard(
        tokens: tokens,
        child: Text('No motion tokens.', style: GoogleFonts.roboto(color: tokens.textSecondary)),
      );
    }
    return _SfCard(
      tokens: tokens,
      child: _tokenTable(['Token', 'Value'], rows, tokens),
    );
  }
}

Widget _tokenTable(List<String> headers, List<List<String>> rows, _SfTokens tokens) {
  return Table(
    columnWidths: const {
      0: FlexColumnWidth(1.2),
      1: FlexColumnWidth(2),
    },
    border: TableBorder(
      horizontalInside: BorderSide(color: tokens.divider),
      bottom: BorderSide(color: tokens.divider),
    ),
    children: [
      TableRow(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: tokens.divider, width: 1)),
        ),
        children: headers
            .map(
              (h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Text(
                  h,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                    letterSpacing: 0.04 * 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      ...rows.map(
        (r) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                r[0],
                style: GoogleFonts.roboto(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                r[1],
                style: GoogleFonts.robotoMono(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// --- Icons & elevation ---

class _SfIconsElevationSection extends StatelessWidget {
  const _SfIconsElevationSection({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SfCard(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Icon sizes',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tokens.textOnLight,
                ),
              ),
              const SizedBox(height: 12),
              if (ds.icons.sizes.isEmpty)
                Text('No icon sizes.', style: GoogleFonts.roboto(color: tokens.textSecondary))
              else
                _tokenTable(
                  ['Token', 'Value'],
                  ds.icons.sizes.entries.map((e) => [e.key, e.value]).toList(),
                  tokens,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SfCard(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shadow presets',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tokens.textOnLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visual approximation of elevation tokens.',
                style: GoogleFonts.roboto(fontSize: 14, color: tokens.textSecondary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: ds.shadows.values.entries.map((e) {
                  return Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          e.key,
                          style: GoogleFonts.roboto(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: Text(
                          e.value.value,
                          style: GoogleFonts.robotoMono(fontSize: 9),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Gradients ---

class _SfGradientsRow extends StatelessWidget {
  const _SfGradientsRow({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (ds.gradients.values.isEmpty) {
      return _SfCard(
        tokens: tokens,
        child: Text('No gradients defined.', style: GoogleFonts.roboto(color: tokens.textSecondary)),
      );
    }
    return _SfCard(
      tokens: tokens,
      child: LayoutBuilder(
        builder: (context, c) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: ds.gradients.values.entries.map((e) {
              final g = e.value;
              Alignment begin = Alignment.topLeft;
              Alignment end = Alignment.bottomRight;
              if (g.direction.contains('bottom')) {
                begin = Alignment.topCenter;
                end = Alignment.bottomCenter;
              }
              return SizedBox(
                width: (c.maxWidth > 600 ? 280.0 : c.maxWidth).clamp(200.0, 400.0),
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: begin,
                            end: end,
                            colors: g.colors.map(_parseColor).toList(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                          child: Text(
                            e.key,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// --- Roles mock ---

class _SfRolesMock extends StatefulWidget {
  const _SfRolesMock({required this.ds, required this.tokens});

  final models.DesignSystem ds;
  final _SfTokens tokens;

  @override
  State<_SfRolesMock> createState() => _SfRolesMockState();
}

class _SfRolesMockState extends State<_SfRolesMock> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final entries = widget.ds.roles.values.entries.toList();
    if (entries.isEmpty) {
      return _SfCard(
        tokens: widget.tokens,
        child: Text(
          'No roles defined.',
          style: GoogleFonts.roboto(color: widget.tokens.textSecondary),
        ),
      );
    }
    final e = entries[_index.clamp(0, entries.length - 1)];
    final role = e.value;
    final c1 = _parseColor(role.primaryColor);
    final c2 = _parseColor(role.accentColor);
    return _SfCard(
      tokens: widget.tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(entries.length, (i) {
              final active = i == _index;
              return Material(
                color: active ? widget.tokens.pageFg : Colors.white,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => setState(() => _index = i),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active ? widget.tokens.pageFg : Colors.black.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      entries[i].key,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: active ? Colors.white : widget.tokens.pageFg,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Container(
                  height: 52,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c1, c2],
                    ),
                  ),
                  child: Text(
                    e.key,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(c1, Colors.black, 0.25)!,
                        Color.lerp(c2, const Color(0xFF1A1917), 0.4)!,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'App bar foreground: white. Muted text on headers: white at 75% opacity.',
            style: GoogleFonts.roboto(fontSize: 13, color: widget.tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

// --- Components grid (HTML .cmp-grid) ---

class _SfComponentsGrid extends StatelessWidget {
  const _SfComponentsGrid({required this.tokens});

  final _SfTokens tokens;

  @override
  Widget build(BuildContext context) {
    return _SfCard(
      tokens: tokens,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final cols = w >= 600 ? 2 : 1;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: cols == 1 ? 1.4 : 1.1,
            children: [
              _cmpFrame(
                tokens,
                'Actions',
                'Filled / outlined / text using your accent and coral.',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.coral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('Primary'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.textTealDeep,
                        side: BorderSide(color: tokens.accent),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('Outlined'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: tokens.textTealDeep,
                      ),
                      onPressed: () {},
                      child: const Text('Text'),
                    ),
                  ],
                ),
              ),
              _cmpFrame(
                tokens,
                'Forms',
                'Rounded field with border radius from tokens.',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, size: 20, color: tokens.textSecondary.withOpacity(0.5)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Email',
                          style: GoogleFonts.roboto(fontSize: 16, color: tokens.textTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _cmpFrame(
                tokens,
                'Feedback',
                'Dialog-style surface.',
                dark: false,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tokens.cardBorder.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Title', style: GoogleFonts.roboto(fontSize: 18, color: tokens.pageFg)),
                      const SizedBox(height: 8),
                      Text(
                        'Short message body.',
                        style: GoogleFonts.roboto(fontSize: 14, color: tokens.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('Cancel', style: TextStyle(color: tokens.textTealDeep)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: tokens.coral),
                            onPressed: () {},
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _cmpFrame(
  _SfTokens tokens,
  String label,
  String desc, {
  required Widget child,
  bool dark = false,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: dark ? null : tokens.cardMuted,
      gradient: dark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E2426), Color(0xFF1A1917), Color(0xFF1F1C24)],
            )
          : null,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: tokens.cardBorder.withOpacity(0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.07 * 11,
            color: dark ? tokens.secondarySoft : tokens.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: dark ? Colors.white.withOpacity(0.85) : tokens.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
