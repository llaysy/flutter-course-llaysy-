import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 18,
  });

  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(isLiked),
              size: size,
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }
}
