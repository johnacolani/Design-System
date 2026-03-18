import '../models/design_system.dart' as m;

/// Built-in demo design systems for the Demo Gallery.
class DemoDesignSystems {
  static const String mobileUiKit = 'mobile_ui_kit';
  static const String adminDashboard = 'admin_dashboard';
  static const String landingPage = 'landing_page';

  static m.DesignSystem byId(String id) {
    switch (id) {
      case adminDashboard:
        return adminDashboardDemo;
      case landingPage:
        return landingPageDemo;
      case mobileUiKit:
      default:
        return mobileUiKitDemo;
    }
  }

  static Map<String, String> get titles => const {
        mobileUiKit: 'Mobile UI Kit',
        adminDashboard: 'Admin Dashboard',
        landingPage: 'Landing Page',
      };

  /// Touch-friendly blues, compact components, mobile-first spacing.
  static final m.DesignSystem mobileUiKitDemo = _mobile();

  /// Dense tables, indigo/slate, data-tool patterns.
  static final m.DesignSystem adminDashboardDemo = _admin();

  /// Marketing gradients, bold type, wide radius.
  static final m.DesignSystem landingPageDemo = _landing();

  static Map<String, dynamic> _color(String hex, String description) => {
        'value': hex,
        'type': 'color',
        'description': description,
      };

  static m.DesignSystem _mobile() {
    final now = DateTime.now().toIso8601String();
    return m.DesignSystem(
      name: 'Mobile UI Kit (Demo)',
      version: '1.0.0',
      description:
          'Demo: buttons, cards, inputs, and tokens tuned for native mobile apps. Save as your own project to edit.',
      created: now.split('T').first,
      colors: m.Colors(
        primary: {
          'primary': _color('#2563EB', 'Brand blue'),
          'primaryDark': _color('#1D4ED8', 'Pressed / dark mode header'),
        },
        semantic: {
          'success': _color('#16A34A', 'Success'),
          'warning': _color('#CA8A04', 'Warning'),
          'error': _color('#DC2626', 'Error'),
          'surface': _color('#F8FAFC', 'Screen background'),
          'onSurface': _color('#0F172A', 'Primary text'),
        },
        grey: {
          '100': _color('#F1F5F9', 'Divider / subtle bg'),
          '500': _color('#64748B', 'Secondary text'),
        },
      ),
      typography: m.Typography(
        fontFamily: m.FontFamily(primary: 'Inter', fallback: 'system-ui'),
        fontWeights: m.Typography.empty().fontWeights,
        fontSizes: {
          ...m.Typography.empty().fontSizes,
          'display': m.FontSize(value: '34px', lineHeight: '1.15'),
          'title': m.FontSize(value: '22px', lineHeight: '1.25'),
        },
        textStyles: {},
      ),
      spacing: m.Spacing.empty(),
      borderRadius: m.BorderRadius(
        none: '0px',
        sm: '8px',
        base: '12px',
        md: '16px',
        lg: '20px',
        xl: '24px',
        full: '9999px',
      ),
      shadows: m.Shadows(values: {
        'card': m.ShadowValue(
          value: '0 2px 8px rgba(15,23,42,0.08)',
          description: 'Floating card',
        ),
        'fab': m.ShadowValue(
          value: '0 4px 14px rgba(37,99,235,0.35)',
          description: 'FAB',
        ),
      }),
      effects: m.Effects.empty(),
      components: m.Components(
        buttons: {
          'primary': {
            'height': '48px',
            'borderRadius': '12px',
            'padding': '16px',
            'fontSize': '16px',
            'fontWeight': 600,
            'label': 'Continue',
          },
          'secondary': {
            'height': '44px',
            'borderRadius': '12px',
            'padding': '14px',
            'fontSize': '15px',
            'fontWeight': 500,
            'label': 'Cancel',
          },
        },
        cards: {
          'product': {
            'borderRadius': '16px',
            'padding': '12px',
            'description': 'Product / list item card',
          },
        },
        inputs: {
          'search': {
            'borderRadius': '12px',
            'height': '44px',
            'description': 'Search field',
          },
        },
        navigation: {
          'tabBar': {'description': 'Bottom tab bar height 56px'},
        },
        avatars: {
          'user': {'size': '40px'},
        },
        modals: {
          'confirm': {
            'modalTitle': 'Discard changes?',
            'bodyText': 'Your edits will be lost.',
            'cancelLabel': 'Keep editing',
            'confirmLabel': 'Discard',
            'borderRadius': '16px',
          },
        },
        tables: {},
        progress: {
          'linear': {'progressValue': '65', 'progressCaption': 'Syncing…'},
        },
        alerts: {
          'offline': {
            'alertVariant': 'warning',
            'alertMessage': 'You are offline. Changes will sync when connected.',
            'borderRadius': '8px',
          },
        },
      ),
      grid: m.Grid(
        columns: 4,
        gutter: '16px',
        margin: '16px',
        breakpoints: const {
          'mobile': '0px',
          'tablet': '600px',
          'desktop': '900px',
        },
      ),
      icons: m.Icons.empty(),
      gradients: m.Gradients(values: {}),
      roles: m.Roles(values: {}),
      semanticTokens: m.SemanticTokens.empty(),
      motionTokens: m.MotionTokens.empty(),
      lastModified: now,
      versionHistory: [
        m.VersionHistory(
          version: '1.0.0',
          date: now,
          changes: ['Demo: Mobile UI Kit preset'],
        ),
      ],
      componentVersions: {},
    );
  }

  static m.DesignSystem _admin() {
    final now = DateTime.now().toIso8601String();
    return m.DesignSystem(
      name: 'Admin Dashboard (Demo)',
      version: '1.0.0',
      description:
          'Demo: data-dense UI — tables, side navigation, modals. Save to customize for your admin product.',
      created: now.split('T').first,
      colors: m.Colors(
        primary: {
          'primary': _color('#4F46E5', 'Primary actions'),
          'sidebar': _color('#1E1B4B', 'Sidebar background'),
        },
        semantic: {
          'success': _color('#059669', 'Positive delta'),
          'error': _color('#B91C1C', 'Errors / delete'),
          'surface': _color('#F1F5F9', 'Page background'),
          'onSurface': _color('#0F172A', 'Table text'),
          'border': _color('#E2E8F0', 'Table borders'),
        },
      ),
      typography: m.Typography(
        fontFamily: m.FontFamily(primary: 'Inter', fallback: 'system-ui'),
        fontWeights: m.Typography.empty().fontWeights,
        fontSizes: {
          ...m.Typography.empty().fontSizes,
          'body': m.FontSize(value: '14px', lineHeight: '1.45'),
          'label': m.FontSize(value: '11px', lineHeight: '1.2'),
        },
        textStyles: {},
      ),
      spacing: m.Spacing.empty(),
      borderRadius: m.BorderRadius(
        none: '0px',
        sm: '4px',
        base: '6px',
        md: '8px',
        lg: '10px',
        xl: '12px',
        full: '9999px',
      ),
      shadows: m.Shadows(values: {
        'panel': m.ShadowValue(value: '0 1px 3px rgba(15,23,42,0.06)'),
      }),
      effects: m.Effects.empty(),
      components: m.Components(
        buttons: {
          'toolbar': {
            'height': '32px',
            'borderRadius': '6px',
            'padding': '10px',
            'fontSize': '13px',
            'fontWeight': 500,
            'label': 'Export CSV',
          },
        },
        cards: {
          'metric': {'borderRadius': '8px', 'padding': '16px'},
        },
        inputs: {
          'filter': {'borderRadius': '6px', 'height': '36px'},
        },
        navigation: {
          'sidebar': {'description': '240px fixed sidebar'},
        },
        avatars: {'user': {'size': '28px'}},
        modals: {
          'deleteUser': {
            'modalTitle': 'Delete user?',
            'bodyText': 'This removes access permanently. This action cannot be undone.',
            'cancelLabel': 'Cancel',
            'confirmLabel': 'Delete user',
            'borderRadius': '8px',
          },
        },
        tables: {
          'users': {
            'col1Header': 'User',
            'col2Header': 'Role',
            'cell11': 'alex@acme.com',
            'cell12': 'Admin',
            'cell21': 'sam@acme.com',
            'cell22': 'Editor',
          },
        },
        progress: {
          'report': {'progressIndeterminate': false, 'progressValue': '82', 'progressCaption': 'Generating report…'},
        },
        alerts: {
          'session': {
            'alertVariant': 'info',
            'alertTitle': 'Session',
            'alertMessage': 'Your session expires in 10 minutes.',
            'borderRadius': '6px',
          },
        },
      ),
      grid: m.Grid(
        columns: 12,
        gutter: '24px',
        margin: '24px',
        breakpoints: m.Grid.empty().breakpoints,
      ),
      icons: m.Icons.empty(),
      gradients: m.Gradients(values: {}),
      roles: m.Roles(values: {}),
      semanticTokens: m.SemanticTokens.empty(),
      motionTokens: m.MotionTokens.empty(),
      lastModified: now,
      versionHistory: [
        m.VersionHistory(
          version: '1.0.0',
          date: now,
          changes: ['Demo: Admin Dashboard preset'],
        ),
      ],
      componentVersions: {},
    );
  }

  static m.DesignSystem _landing() {
    final now = DateTime.now().toIso8601String();
    return m.DesignSystem(
      name: 'Landing Page (Demo)',
      version: '1.0.0',
      description:
          'Demo: marketing site tokens — hero gradient, bold CTAs, generous spacing. Save to adapt for your brand.',
      created: now.split('T').first,
      colors: m.Colors(
        primary: {
          'primary': _color('#0D9488', 'CTA / links'),
          'accent': _color('#F97316', 'Highlight / secondary CTA'),
        },
        semantic: {
          'surface': _color('#FFFFFF', 'Sections'),
          'surfaceAlt': _color('#F0FDFA', 'Alternate band'),
          'onSurface': _color('#134E4A', 'Headings'),
          'muted': _color('#5EEAD4', 'Subhead muted'),
        },
      ),
      typography: m.Typography(
        fontFamily: m.FontFamily(primary: 'DM Sans', fallback: 'system-ui'),
        fontWeights: m.Typography.empty().fontWeights,
        fontSizes: {
          'display': m.FontSize(value: '56px', lineHeight: '1.05'),
          'heading': m.FontSize(value: '40px', lineHeight: '1.1'),
          'title': m.FontSize(value: '28px', lineHeight: '1.2'),
          'body': m.FontSize(value: '18px', lineHeight: '1.6'),
          'caption': m.FontSize(value: '16px', lineHeight: '1.5'),
        },
        textStyles: {},
      ),
      spacing: m.Spacing.empty(),
      borderRadius: m.BorderRadius(
        none: '0px',
        sm: '12px',
        base: '16px',
        md: '20px',
        lg: '28px',
        xl: '40px',
        full: '9999px',
      ),
      shadows: m.Shadows(values: {
        'cta': m.ShadowValue(value: '0 8px 24px rgba(13,148,136,0.25)'),
      }),
      effects: m.Effects.empty(),
      components: m.Components(
        buttons: {
          'heroCta': {
            'height': '52px',
            'borderRadius': '9999px',
            'padding': '28px',
            'fontSize': '18px',
            'fontWeight': 600,
            'label': 'Start free trial',
          },
          'secondaryCta': {
            'height': '52px',
            'borderRadius': '9999px',
            'padding': '24px',
            'fontSize': '17px',
            'fontWeight': 600,
            'label': 'Watch demo',
          },
        },
        cards: {
          'pricing': {'borderRadius': '24px', 'padding': '32px'},
        },
        inputs: {
          'newsletter': {
            'borderRadius': '9999px',
            'height': '52px',
            'description': 'Email capture',
          },
        },
        navigation: {
          'header': {'description': 'Sticky header 72px'},
        },
        avatars: {},
        modals: {},
        tables: {},
        progress: {},
        alerts: {
          'promo': {
            'alertVariant': 'success',
            'alertMessage': 'New: Team plans now include SSO.',
            'borderRadius': '12px',
          },
        },
      ),
      grid: m.Grid(
        columns: 12,
        gutter: '32px',
        margin: 'max(24px, 5vw)',
        breakpoints: const {
          'mobile': '0px',
          'tablet': '768px',
          'desktop': '1024px',
        },
      ),
      icons: m.Icons.empty(),
      gradients: m.Gradients(values: {
        'hero': m.GradientValue(
          type: 'linear',
          direction: '135deg',
          colors: ['#0F766E', '#14B8A6', '#5EEAD4'],
          stops: [0, 50, 100],
        ),
      }),
      roles: m.Roles(values: {}),
      semanticTokens: m.SemanticTokens.empty(),
      motionTokens: m.MotionTokens.empty(),
      lastModified: now,
      versionHistory: [
        m.VersionHistory(
          version: '1.0.0',
          date: now,
          changes: ['Demo: Landing Page preset'],
        ),
      ],
      componentVersions: {},
    );
  }
}
