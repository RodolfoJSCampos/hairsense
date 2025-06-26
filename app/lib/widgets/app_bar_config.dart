import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/theme_controller.dart'; // Garante que esteja importando o controlador

class AppBarConfig extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onRefresh;

  const AppBarConfig({super.key, this.onRefresh});

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
                  child: const Text('Atualizar'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      if (onRefresh != null) {
                        onRefresh!();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Atualizando...')),
                        );
                      }
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Alternar tema'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      final themeController = Provider.of<ThemeController>(
                        context,
                        listen: false,
                      );
                      themeController.alternarTema();
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Sobre'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'HairSense',
                        applicationVersion: '1.0.1',
                        children: const [
                          Text('App de gestão de beleza'),
                        ],
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Sair'),
                  onTap: () {
                    Future.delayed(Duration.zero, () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.popUntil(context, (route) => route.isFirst);
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