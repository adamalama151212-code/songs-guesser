import 'package:flutter/material.dart';

/// Widget wyświetlający nagłówek z informacjami o artyście
/// Zawiera zdjęcie, nazwę artysty i poziom trudności
class ArtistHeader extends StatelessWidget {
  const ArtistHeader({
    required this.artistName,
    required this.difficulty,
    super.key,
  });

  final String artistName;
  final String difficulty;

  /// Mapowanie nazw artystów na ścieżki do obrazów
  String _getArtistImagePath() {
    final Map<String, String> artistImages = {
      'AC/DC': 'assets/images/acdc.png',
      'John Mayer': 'assets/images/john_mayer.png',
      'Metallica': 'assets/images/metallica.png',
      'Queen': 'assets/images/queen.png',
      'The Beatles': 'assets/images/the_beatles.png',
      'Pink Floyd': 'assets/images/pink_floyd.png',
      'Nirvana': 'assets/images/nirvana.png',
      'Aerosmith': 'assets/images/aerosmith.png',
      'ZZ Top': 'assets/images/zz_top.png',
      'Gary Moore': 'assets/images/gary_moore.png',
    };

    return artistImages[artistName] ?? 'assets/images/songGuesserLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Zdjęcie artysty
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
            child: Image.asset(
              _getArtistImagePath(),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Informacje o artyście
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artistName,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Level: $difficulty',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}