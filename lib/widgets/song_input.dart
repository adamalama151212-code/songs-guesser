import 'package:flutter/material.dart';

/// Widget for text field to enter song title
/// Styled input with placeholder and white text
class SongInput extends StatelessWidget {
  const SongInput({
    required this.controller,
    required this.onSubmitted,
    required this.onNextSong,
    required this.userAnswers,
    required this.songList,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onNextSong;
  final List<String> userAnswers;
  final List<String> songList;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return songList.where(
                (song) => song.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            fieldViewBuilder:
                (context, controllerField, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controllerField,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter song title...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
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
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    cursorColor: Colors.white,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        userAnswers.add(value.trim());
                        controller.clear();
                        onNextSong();
                      }
                      onSubmitted(value);
                    },
                  );
                },
            onSelected: (String selection) {
              controller.text = selection;
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) {
              userAnswers.add(value);
              controller.clear();
              onNextSong();
              onSubmitted(value);
            }
          },
        ),
      ],
    );
  }
}
