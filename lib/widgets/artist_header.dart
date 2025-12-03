import 'package:flutter/material.dart';

/// Widget displaying header with artist info
/// Contains image, artist name and difficulty level
class ArtistHeader extends StatelessWidget {
  const ArtistHeader({
    required this.artistName,
    required this.difficulty,
    super.key,
  });

  final String artistName;
  final String difficulty;

  /// Mapping artist names to image paths
  String _getArtistImagePath() {
    final Map<String, String> artistImages = {
      'ac/dc': 'assets/images/acdc.png',
      'john mayer': 'assets/images/john_mayer.png',
      'metallica': 'assets/images/metallica.png',
      'queen': 'assets/images/queen.png',
      'the beatles': 'assets/images/the_beatles.png',
      'pink floyd': 'assets/images/pink_floyd.png',
      'prince': 'assets/images/prince.png',
      'aerosmith': 'assets/images/aerosmith.png',
      'zz top': 'assets/images/zz_top.png',
      'gary moore': 'assets/images/gary_moore.png',
    };

    final normalizedName = artistName.toLowerCase();
    return artistImages[normalizedName] ?? 'assets/images/songGuesserLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Artist image
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

        // Artist info
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