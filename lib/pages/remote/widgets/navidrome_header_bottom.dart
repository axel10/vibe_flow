import 'package:flutter/material.dart';
import '../../../utils/layout_constants.dart';

class NavidromeHeaderBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final TabBar tabBar;
  final Widget? toolbar;

  const NavidromeHeaderBottom({
    super.key,
    required this.tabBar,
    this.toolbar,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        tabBar.preferredSize.height + (toolbar != null ? 52.0 : 0.0),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tabBar,
        if (toolbar != null)
          SizedBox(
            height: 52.0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kSingleColumnContentMaxWidth,
                ),
                child: toolbar!,
              ),
            ),
          ),
      ],
    );
  }
}
