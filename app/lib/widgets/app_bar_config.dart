// lib/widgets/app_bar_config.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../views/views.dart';

class AppBarConfig extends StatelessWidget implements PreferredSizeWidget {
  final String title;            // ← novo
  final bool showBackButton;     // ← novo
  final VoidCallback? onRefresh;

  const AppBarConfig({
    Key? key,
    this.title = 'HairSense',    
    this.showBackButton = false, 
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: Icon(Icons.refresh,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              onRefresh!();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Atualizando…')),
              );
            },
          ),
        IconButton(
          icon: Icon(Icons.settings,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => _openMenu(context),
        ),
      ],
    );
  }

  void _openMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      items: [
        PopupMenuItem(
          child: const Text('Alternar tema'),
          onTap: () {
            Future.delayed(Duration.zero, () {
              final themeCtrl =
                  Provider.of<ThemeController>(context, listen: false);
              themeCtrl.alternarTema(!themeCtrl.isDarkMode);
            });
          },
        ),
        PopupMenuItem(
          child: const Text('Sobre'),
          onTap: () => Future.delayed(Duration.zero, () {
            showAboutDialog(
              context: context,
              applicationName: 'HairSense',
              applicationVersion: '1.0.1',
              children: const [Text('App de gestão de beleza')],
            );
          }),
        ),
        PopupMenuItem(
          child: const Text('Sair'),
          onTap: () => Future.delayed(Duration.zero, () async {
            await FirebaseAuth.instance.signOut();
            final themeCtrl =
                Provider.of<ThemeController>(context, listen: false);
            await themeCtrl.alternarTema(false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginView()),
              (_) => false,
            );
          }),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}