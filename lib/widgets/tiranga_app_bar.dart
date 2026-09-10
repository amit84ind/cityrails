import 'package:flutter/material.dart';
import '../theme/tiranga_theme.dart';

class TirangaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const TirangaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom != null ? bottom!.preferredSize.height : 0) + 4);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Tiranga Color Bar (Saffron, White, Green)
        Container(
          height: 4,
          child: Row(
            children: [
              Expanded(
                child: Container(color: TirangaTheme.saffron),
              ),
              Expanded(
                child: Container(color: TirangaTheme.white),
              ),
              Expanded(
                child: Container(color: TirangaTheme.green),
              ),
            ],
          ),
        ),
        AppBar(
          backgroundColor: TirangaTheme.saffronDark,
          elevation: 2,
          leading: leading,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.train_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: actions,
          bottom: bottom,
        ),
      ],
    );
  }
}
