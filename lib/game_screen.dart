import 'package:flutter/material.dart';
import './services/artist_service.dart';
import 'widgets/back_button.dart';

class GameScreen extends StatefulWidget {
  // Constructor still requires onArtistSelected function to pass data
  const GameScreen(this.onBack, this.onArtistSelected, {super.key});

  final void Function() onBack;
  final void Function(String artistName) onArtistSelected;

  @override
  State<GameScreen> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends State<GameScreen> {
  String? _selectedArtist;
  List<String> _artists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    try {
      final artists = await ArtistService.fetchArtists();
      setState(() {
        _artists = artists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // No fallback - rely only on API
      });
    }
  }

  void _selectArtistAndStart(String artistName) {
    setState(() {
      _selectedArtist = artistName;
    });

    widget.onArtistSelected(artistName);
  }

  @override
  Widget build(BuildContext context) {
    final backButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(200, 40),
      foregroundColor: Color.fromARGB(255, 190, 143, 252),
      backgroundColor: Colors.black.withOpacity(0.4),
      side: const BorderSide(color: Colors.white, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
    );

    // Loading state handling
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Loading artists...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Error handling - show message and retry button
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              'Failed to load artists',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _loadArtists();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.home),
              label: const Text('Back to Menu'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 190, 143, 252),
                backgroundColor: Colors.black.withOpacity(0.4),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Center(
            child: Text(
              "Choose an artist or band",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 35),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 350,
          width: 300,
          child: ListView.builder(
            itemCount: _artists.length,
            itemBuilder: (BuildContext context, int index) {
              final artistName = _artists[index];
              final isSelected = _selectedArtist == artistName;

              const defaultBorderColor = Colors.white;
              const defaultBorderWidth = 1.0;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.green : defaultBorderColor,
                    width: isSelected ? 4 : defaultBorderWidth,
                  ),

                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Center(
                    child: Stack(
                      children: [
                        Text(
                          artistName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    _selectArtistAndStart(artistName);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Back button (Home)
        ElevatedButton.icon(
          onPressed: widget.onBack,
          style: backButtonStyle,
          label: const Text('Back', style: TextStyle(fontSize: 16)),
          icon: const Icon(Icons.home, size: 20),
        ),
      ],
    );
  }
}
