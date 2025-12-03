import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/artist_service.dart';
import 'widgets/artist_header.dart';
import 'widgets/song_input.dart';
import 'widgets/back_button.dart';
import 'dart:math';

class FinalGameScreen extends StatefulWidget {
  final String selectedArtist;
  final String selectedDifficulty;
  final void Function() onBack;

  const FinalGameScreen({
    super.key,
    required this.selectedArtist,
    required this.selectedDifficulty,
    required this.onBack,
  });

  @override
  State<FinalGameScreen> createState() => _FinalGameScreenState();
}

class _FinalGameScreenState extends State<FinalGameScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<AudioPlayer> _players = [];
  List<String> _songNames = [];
  List<String> _songTitles = [];
  Map<String, String> _isolatedTracks = {}; // track_type -> filename
  String _currentSong = '';
  final List<String> userAnswers = [];

  // Status każdego playera
  final List<bool> _isPlaying = [false, false, false, false];
  final List<bool> _isLoading = [false, false, false, false];
  final List<Duration> _currentPosition = [
    Duration.zero,
    Duration.zero,
    Duration.zero,
    Duration.zero,
  ];
  final List<Duration> _totalDuration = [
    Duration.zero,
    Duration.zero,
    Duration.zero,
    Duration.zero,
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayers();
    _loadSongs();
  }

  Future<void> _initializePlayers() async {
    // Clear existing players before creating new ones
    for (final player in _players) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        print('⚠️ Error disposing player: $e');
      }
    }
    _players.clear();

    // Reset state arrays
    for (int i = 0; i < _isLoading.length; i++) {
      _isLoading[i] = false;
      _isPlaying[i] = false;
      _currentPosition[i] = Duration.zero;
      _totalDuration[i] = Duration.zero;
    }

    // Create 4 players (one for each instrument)
    for (int i = 0; i < 4; i++) {
      final player = AudioPlayer();
      _players.add(player);

      // Listener for position
      player.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition[i] = position;
          });
        }
      });

      // Listener for duration
      player.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _totalDuration[i] = duration;
          });
        }
      });

      // Listener for state
      player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying[i] = state == PlayerState.playing;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var player in _players) {
      player.stop();
      player.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    // Reset loading state when switching songs/artists
    setState(() {
      for (int i = 0; i < _isLoading.length; i++) {
        _isLoading[i] = false;
      }
    });

    try {
      print('🔄 Loading songs for artist: ${widget.selectedArtist}');

      try {
        // 1. download song list for the artist
        final songList = await ArtistService.getAllSongsByArtist(
          widget.selectedArtist,
        );

        if (songList.isNotEmpty) {
          setState(() {
            _songTitles = songList;
          });
          // 2. choose a random song
          final selectedSong = (songList..shuffle()).first;

          // 3. download isolated tracks for this song
          final tracks = await ArtistService.getIsolatedTracks(
            widget.selectedArtist,
            selectedSong,
          );

          // Check if all required tracks are available
          final requiredTracks = ['percussion', 'bass', 'rhythm', 'lead'];
          final missingTracks = requiredTracks
              .where((track) => tracks[track] == null || tracks[track]!.isEmpty)
              .toList();

          if (missingTracks.isNotEmpty) {
            // Show alert about missing tracks
            _showMissingTracksDialog(selectedSong, missingTracks);
            return;
          }

          setState(() {
            _currentSong = selectedSong;
            _isolatedTracks = tracks;
            // IMPORTANT: Order must match UI buttons!
            // UI: ['Percussion', 'Bass Line', 'Rhythm Guitar', 'Lead Guitar']
            _songNames = [
              tracks['percussion']!, // Index 0 = Percussion button
              tracks['bass']!, // Index 1 = Bass Line button
              tracks['rhythm']!, // Index 2 = Rhythm Guitar button
              tracks['lead']!, // Index 3 = Lead Guitar button
            ];
          });
          print(
            '🎵 Mapped tracks: Percussion=${_songNames[0]}, Bass=${_songNames[1]}, Rhythm=${_songNames[2]}, Lead=${_songNames[3]}',
          );
          print('✅ Loaded song "$selectedSong" with tracks: $tracks');

          // Preload audio sources to help emulator
          _preloadAllAudioSources();
        } else {
          _showNoSongsDialog();
          return;
        }
      } catch (e) {
        print('⚠️ Failed to load from database: $e');
        _showDatabaseErrorDialog(e.toString());
        return;
      }
    } catch (e) {
      print('❌ Complete song loading failed: $e');
      _showDatabaseErrorDialog(e.toString());
      return;
    }
  }

  String _getInstrumentName(int index) {
    if (index < _songNames.length) {
      final fileName = _songNames[index];
      if (fileName.contains('percussion') || fileName.contains('drum')) {
        return 'Percussion';
      } else if (fileName.contains('bass')) {
        return 'Bass Line';
      } else if (fileName.contains('rhythm') || fileName.contains('rythm')) {
        return 'Rhythm Guitar';
      } else if (fileName.contains('lead')) {
        return 'Lead Guitar';
      }
    }

    final names = ['Percussion', 'Bass Line', 'Rhythm Guitar', 'Lead Guitar'];
    return names[index % names.length];
  }

  Future<void> _togglePlay(int index) async {
    if (!mounted ||
        _isLoading[index] ||
        index >= _songNames.length ||
        index >= _players.length) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading[index] = true;
      });
    }

    try {
      if (_isPlaying[index]) {
        await _players[index].pause().timeout(const Duration(seconds: 5));
      } else {
        final fileName = _songNames[index];
        final url =
            'https://pub-6c7ccaaab93b4b0493dc62cfb6c8ab91.r2.dev/$fileName';

        // if the track has finished playing, restart from beginning
        if (_currentPosition[index] >= _totalDuration[index] &&
            _totalDuration[index] > Duration.zero) {
          await _players[index].stop();
          await _players[index].setSource(UrlSource(url));
          await _players[index].seek(Duration.zero);
          await _players[index]
              .play(UrlSource(url))
              .timeout(const Duration(seconds: 30));
        } else if (_currentPosition[index] == Duration.zero) {
          await _players[index].stop();
          await _players[index].setSource(UrlSource(url));
          await _players[index]
              .play(UrlSource(url))
              .timeout(const Duration(seconds: 30));
        } else {
          await _players[index].resume().timeout(const Duration(seconds: 5));
        }
      }
    } catch (e) {
      print('❌ Failed to toggle play for ${_songNames[index]}: $e');
      if (mounted) {
        setState(() {
          _isLoading[index] = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading[index] = false;
        });
      }
    }
  }

  /// Preload all audio sources to help emulator
  void _preloadAllAudioSources() async {
    print('🔄 Preloading audio sources...');
    for (int i = 0; i < _songNames.length; i++) {
      final fileName = _songNames[i];
      final url =
          'https://pub-6c7ccaaab93b4b0493dc62cfb6c8ab91.r2.dev/$fileName';
      try {
        print('📡 Preloading: $fileName');
        // Set source without playing to cache it
        await _players[i]
            .setSource(UrlSource(url))
            .timeout(Duration(seconds: 5));
        print('✅ Preloaded: $fileName');
      } catch (e) {
        print('⚠️ Preload failed for $fileName: $e');
      }
      // Small delay between preloads
      await Future.delayed(Duration(milliseconds: 500));
    }
    print('🎯 Audio preloading complete');
  }

  /// Shows a dialog about missing audio tracks
  void _showMissingTracksDialog(String songName, List<String> missingTracks) {
    final trackNames = {
      'percussion': 'Perkusja',
      'bass': 'Bas',
      'rhythm': 'Gitara rytmiczna',
      'lead': 'Gitara prowadząca',
    };

    final missingNames = missingTracks
        .map((track) => trackNames[track] ?? track)
        .join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 30, 30, 45),
          title: const Text(
            'Brak ścieżek audio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Dla utworu "$songName" brakuje następujących ścieżek:\n\n$missingNames\n\nSkontaktuj się z administratorem lub wybierz inny utwór.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally: go back to the previous screen
                widget.onBack();
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Color.fromARGB(255, 120, 140, 255)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color.fromARGB(255, 120, 140, 255)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog when there are no songs for the artist
  void _showNoSongsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 30, 30, 45),
          title: const Text(
            'Brak utworów',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Nie znaleziono utworów dla artysty "${widget.selectedArtist}".\n\nMożliwe przyczyny:\n• Artysta nie ma dodanych utworów\n• Problem z połączeniem z bazą danych\n• Błąd serwera',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onBack();
              },
              child: const Text(
                'Wróć do wyboru artysty',
                style: TextStyle(color: Color.fromARGB(255, 120, 140, 255)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for database connection errors
  void _showDatabaseErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 30, 30, 45),
          title: const Text(
            'Błąd połączenia',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Wystąpił problem z połączeniem z bazą danych.\n\nBłąd: $error\n\nSpróbuj ponownie za chwilę lub skontaktuj się z administratorem.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try reloading
                _loadSongs();
              },
              child: const Text(
                'Try again',
                style: TextStyle(color: Color.fromARGB(255, 120, 140, 255)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onBack();
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Color.fromARGB(255, 120, 140, 255)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds % 60)}';
  }

  Widget _buildHeader() {
    return ArtistHeader(
      artistName: widget.selectedArtist,
      difficulty: 'Medium',
    );
  }

  Widget _buildTextInput() {
    return SongInput(
      controller: _textController,
      onSubmitted: (value) {
        // You can add additional logic, e.g., validation
      },
      onNextSong: _loadSongs,
      userAnswers: userAnswers,
      songList: _songTitles,
    );
  }

  Widget _buildInstrumentSlider(int index) {
    final instrumentName = _getInstrumentName(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name of instrument
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              instrumentName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Slider with button
          Row(
            children: [
              // Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color.fromARGB(255, 120, 140, 255),
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: const Color.fromARGB(255, 120, 140, 255),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _totalDuration[index].inMilliseconds > 0
                        ? min(
                            _currentPosition[index].inMilliseconds /
                                _totalDuration[index].inMilliseconds,
                            1.0,
                          )
                        : 0.0,
                    onChanged: (value) {
                      if (_totalDuration[index].inMilliseconds > 0) {
                        final position = Duration(
                          milliseconds:
                              (value * _totalDuration[index].inMilliseconds)
                                  .round(),
                        );
                        _players[index].seek(position);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Play button
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 120, 140, 255),
                  shape: BoxShape.circle,
                ),
                child: _isLoading[index]
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () => _togglePlay(index),
                        icon: Icon(
                          _isPlaying[index] ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
              ),
            ],
          ),
          // Current / total time
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition[index]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration[index]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 64), // Corresponds to button width
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          // gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(121, 212, 209, 209),
                  Color.fromARGB(221, 7, 41, 114),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with artist info
                  _buildHeader(),
                  const SizedBox(height: 30),

                  // Text input
                  _buildTextInput(),
                  const SizedBox(height: 30),

                  // Audio players
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0; i < 4; i++)
                              _buildInstrumentSlider(i),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  CustomBackButton(onPressed: widget.onBack),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
