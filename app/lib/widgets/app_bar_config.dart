import 'package:flutter/material.dart';

class AppBarConfig extends StatelessWidget implements PreferredSizeWidget {
  const AppBarConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
              items: [
                PopupMenuItem(
                  child: const Text('Sobre'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'HairSense',
                        applicationVersion: '1.0.0',
                        children: const [Text('App de gestão de beleza')],
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Sair'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      // Ou chame FirebaseAuth.instance.signOut();
                    });
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
