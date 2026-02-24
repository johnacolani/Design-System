import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class AppBarWithHome extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AppBarWithHome({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ??
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false, // Remove all previous routes
              );
            },
            tooltip: 'Home',
          ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
