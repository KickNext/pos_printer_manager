import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;
  const CardHeader({super.key, required this.leading, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(dimension: 20, child: Center(child: leading)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
