import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import '../views/views.dart';

class AppBarConfig extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;

  const AppBarConfig({
    Key? key,
    this.title = 'HairSense',
    this.showBackButton = false,
    this.onRefresh,
    this.onSearch,
    this.onNotifications,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarConfig> createState() => _AppBarConfigState();
}

class _AppBarConfigState extends State<AppBarConfig>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gearController;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _gearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _gearController.dispose();
    super.dispose();
  }

  void _onSettingsTap() async {
    // dispara a rotação
    _gearController.forward(from: 0.0);

    // se já tiver um menu aberto, fecha
    if (_menuOpen) {
      Navigator.of(context).pop();
    }

    // abre o menu e marca estado
    setState(() => _menuOpen = true);
    await showMenu(
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
    
    setState(() => _menuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Text(widget.title, style: TextStyle(color: iconColor)),
      actions: [
        if (widget.onSearch != null)
          IconButton(
            icon: Icon(Icons.search, color: iconColor),
            onPressed: widget.onSearch,
          ),
        if (widget.onNotifications != null)
          IconButton(
            icon: Icon(Icons.notifications_none, color: iconColor),
            onPressed: widget.onNotifications,
          ),
        if (widget.onRefresh != null)
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            onPressed: () {
              widget.onRefresh!();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Atualizando…')),
              );
            },
          ),

     
        RotationTransition(
          turns: Tween<double>(begin: 0, end: 0.5).animate(
            CurvedAnimation(parent: _gearController, curve: Curves.easeInOut),
          ),
          child: IconButton(
            icon: Icon(Icons.settings, color: iconColor),
            onPressed: _onSettingsTap,
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}