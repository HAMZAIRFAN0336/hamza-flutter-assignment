import 'package:flutter/material.dart';

/// Full-width primary button with an optional loading spinner.
/// Pass `onPressed: null` to render it disabled. Color, shape, and
/// padding all come from the app's ElevatedButtonTheme.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: onPrimary),
              )
            : Text(label),
      ),
    );
  }
}
