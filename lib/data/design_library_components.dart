/// Predefined component entries for Design Library (Material / Cupertino).
/// Adding "Buttons" or "Cards" etc. merges these into the project's design system
/// so they appear in Components and Preview.
class DesignLibraryComponents {
  DesignLibraryComponents._();

  /// Material Design — button variants (Elevated, Filled, Outlined, Text, Icon).
  static Map<String, Map<String, dynamic>> get materialButtons => {
        'material_elevated': {
          'description': 'Material Elevated button — primary actions',
          'label': 'Elevated Button',
          'height': '40',
          'borderRadius': '20',
          'padding': '16',
          'fontSize': '14',
          'fontWeight': '500',
        },
        'material_filled': {
          'description': 'Material Filled button — high emphasis',
          'label': 'Filled Button',
          'height': '40',
          'borderRadius': '20',
          'padding': '16',
          'fontSize': '14',
          'fontWeight': '500',
        },
        'material_outlined': {
          'description': 'Material Outlined button — medium emphasis',
          'label': 'Outlined Button',
          'height': '40',
          'borderRadius': '20',
          'padding': '16',
          'fontSize': '14',
          'fontWeight': '500',
        },
        'material_text': {
          'description': 'Material Text button — low emphasis',
          'label': 'Text Button',
          'height': '40',
          'borderRadius': '20',
          'padding': '16',
          'fontSize': '14',
          'fontWeight': '500',
        },
        'material_icon': {
          'description': 'Material Icon button — icon-only actions',
          'label': '',
          'height': '40',
          'borderRadius': '20',
          'padding': '8',
          'fontSize': '24',
          'fontWeight': '400',
        },
      };

  /// Material Design — card variants.
  static Map<String, Map<String, dynamic>> get materialCards => {
        'material_elevated_card': {
          'description': 'Material elevated card with shadow',
          'borderRadius': '12',
          'padding': '16',
        },
        'material_filled_card': {
          'description': 'Material filled card with background',
          'borderRadius': '12',
          'padding': '16',
        },
        'material_outlined_card': {
          'description': 'Material outlined card with border',
          'borderRadius': '12',
          'padding': '16',
        },
      };

  /// Material Design — input variants.
  static Map<String, Map<String, dynamic>> get materialInputs => {
        'material_standard_input': {
          'description': 'Material standard text field with outline',
          'borderRadius': '12',
        },
        'material_filled_input': {
          'description': 'Material filled text field',
          'borderRadius': '12',
        },
        'material_text_area': {
          'description': 'Material multi-line text area',
          'borderRadius': '12',
        },
      };

  /// Cupertino (iOS) — button variants.
  static Map<String, Map<String, dynamic>> get cupertinoButtons => {
        'cupertino_button': {
          'description': 'Cupertino default button',
          'label': 'Cupertino Button',
          'height': '36',
          'borderRadius': '8',
          'padding': '16',
          'fontSize': '17',
          'fontWeight': '400',
        },
        'cupertino_filled': {
          'description': 'Cupertino filled button',
          'label': 'Filled Button',
          'height': '36',
          'borderRadius': '8',
          'padding': '16',
          'fontSize': '17',
          'fontWeight': '400',
        },
        'cupertino_destructive': {
          'description': 'Cupertino destructive (red) button',
          'label': 'Destructive',
          'height': '36',
          'borderRadius': '8',
          'padding': '16',
          'fontSize': '17',
          'fontWeight': '400',
        },
      };

  /// Cupertino — navigation components.
  static Map<String, Map<String, dynamic>> get cupertinoNavigation => {
        'cupertino_nav_bar': {
          'description': 'iOS-style navigation bar',
        },
        'cupertino_tab_bar': {
          'description': 'iOS-style tab bar',
        },
      };

  /// Cupertino — input components.
  static Map<String, Map<String, dynamic>> get cupertinoInputs => {
        'cupertino_text_field': {
          'description': 'Cupertino text field',
          'borderRadius': '8',
        },
        'cupertino_search': {
          'description': 'Cupertino search field',
          'borderRadius': '10',
        },
      };

  /// Cupertino — alerts & actions (stored as alerts so they show in Components).
  static Map<String, Map<String, dynamic>> get cupertinoAlerts => {
        'cupertino_alert': {
          'description': 'iOS-style alert dialog',
          'alertTitle': 'Alert',
          'alertMessage': 'Message text',
          'alertVariant': 'info',
          'borderRadius': '14',
        },
        'cupertino_action_sheet': {
          'description': 'iOS-style action sheet',
          'alertTitle': 'Actions',
          'alertMessage': 'Choose an option',
          'alertVariant': 'info',
          'borderRadius': '14',
        },
      };
}
