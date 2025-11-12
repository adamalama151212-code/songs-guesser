import 'package:flutter/material.dart';

/// Widget dla pola tekstowego do wprowadzania tytułu piosenki
/// Stylowany input z placeholderem i białym tekstem
class SongInput extends StatelessWidget {
  const SongInput({
    required this.controller,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter song title...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.white,
            onSubmitted: onSubmitted,
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            /// fsfsdfsd
          },
        ),
      ],
    );
  }
}
