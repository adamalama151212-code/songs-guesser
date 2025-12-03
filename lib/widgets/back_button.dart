import 'package:flutter/material.dart';

/// "Back" button with arrow icon
/// Styled button for navigation back
class CustomBackButton extends StatelessWidget {
  const CustomBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 50),
          foregroundColor: const Color.fromARGB(255, 190, 143, 252),
          backgroundColor: Colors.black.withOpacity(0.4),
          side: const BorderSide(color: Colors.white, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.arrow_back, size: 20),
        label: const Text('Back', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
