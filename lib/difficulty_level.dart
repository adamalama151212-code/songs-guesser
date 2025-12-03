import 'package:flutter/material.dart';

class DifficultyScreen extends StatefulWidget {
  // SELECTED ARTIST AND CALLBACK FUNCTIONS
  const DifficultyScreen({
    required this.selectedArtist,
    required this.onBack,
    required this.onDifficultySelected,
    super.key,
  });

  final String selectedArtist;
  final void Function() onBack;
  final void Function(String) onDifficultySelected;

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  String? _selectedDifficulty;

  String _getArtistImagePath() {
    final artistName = widget.selectedArtist;
    final cleanedName = artistName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '');

    return 'assets/images/$cleanedName.png';
  }

  // COMMON STYLE FOR DIFFICULTY BUTTONS
  ButtonStyle _difficultyButtonStyle(String level) {
    final isSelected = _selectedDifficulty == level;
    return ElevatedButton.styleFrom(
      // Fixed width for consistency
      fixedSize: const Size(200, 45),

      // Colors and border
      foregroundColor: Colors.white,
      backgroundColor: isSelected
          ? const Color.fromARGB(255, 160, 140, 187) // Purple when selected
          : Colors.black.withOpacity(0.4), // Dark when not selected
      side: BorderSide(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        width: isSelected ? 2 : 1,
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(200, 50),
      foregroundColor: const Color.fromARGB(255, 190, 143, 252),
      backgroundColor: Colors.black.withOpacity(0.4),
      side: const BorderSide(color: Colors.white, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    final imagePath = _getArtistImagePath();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Artist Selected: ${widget.selectedArtist}',
            style: const TextStyle(fontSize: 28, color: Colors.white),
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(90.0),
              border: Border.all(
                color: const Color.fromARGB(59, 190, 143, 252),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(90.0),
              child: Image.asset(imagePath, width: 200, height: 200),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            _selectedDifficulty == null
                ? 'Choose a difficulty level:'
                : 'Choosed level: $_selectedDifficulty',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20), // Dodatkowy odstęp
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDifficulty = 'Easy';
                  });
                },
                style: _difficultyButtonStyle('Easy'),
                child: const Text('Easy'),
              ),
              const SizedBox(height: 10), // Odstęp pionowy

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDifficulty = 'Medium';
                  });
                },
                style: _difficultyButtonStyle('Medium'),
                child: const Text('Medium'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDifficulty = 'Hard';
                  });
                },
                style: _difficultyButtonStyle('Hard'),
                child: const Text('Hard'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: widget.onBack,
                style: backButtonStyle,
                label: const Text('Back', style: TextStyle(fontSize: 16)),
                icon: const Icon(Icons.arrow_back, size: 20),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _selectedDifficulty != null
                    ? () => widget.onDifficultySelected(_selectedDifficulty!)
                    : null,
                style: backButtonStyle,
                label: const Text('Start', style: TextStyle(fontSize: 16)),
                icon: const Icon(Icons.star, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
