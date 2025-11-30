import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? Theme.of(context).colorScheme.primary,
            ),
            foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
            foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          );

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: button,
    );
  }
}
