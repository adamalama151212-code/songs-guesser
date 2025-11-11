import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/artist_service.dart';
import 'services/simple_audio_service.dart';
import 'widgets/artist_header.dart';
import 'widgets/song_input.dart';
import 'widgets/back_button.dart';

class FinalGameScreen extends StatefulWidget {
  final String selectedArtist;
  final void Function() onBack;

  const FinalGameScreen({
    super.key, 
    required this.selectedArtist,
    required this.onBack,
  });

  @override
  State<FinalGameScreen> createState() => _FinalGameScreenState();
}

class _FinalGameScreenState extends State<FinalGameScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<AudioPlayer> _players = [];
  List<String> _songNames = [];
  
  // Status każdego playera
  final List<bool> _isPlaying = [false, false, false, false];
  final List<bool> _isLoading = [false, false, false, false];
  final List<Duration> _currentPosition = [Duration.zero, Duration.zero, Duration.zero, Duration.zero];
  final List<Duration> _totalDuration = [Duration.zero, Duration.zero, Duration.zero, Duration.zero];

  @override
  void initState() {
    super.initState();
    _initializePlayers();
    _loadSongs();
  }

  Future<void> _initializePlayers() async {
    // Tworzymy 4 playery (jeden na każdy instrument)
    for (int i = 0; i < 4; i++) {
      final player = AudioPlayer();
      _players.add(player);
      
      // Listener dla pozycji
      player.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition[i] = position;
          });
        }
      });
      
      // Listener dla duration
      player.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _totalDuration[i] = duration;
          });
        }
      });
      
      // Listener dla stanu
      player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying[i] = state == PlayerState.playing;
          });
        }
      });
      
      SimpleAudioService().setupPlayerQuality(player);
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
    try {
      print('🔄 Loading songs for artist: ${widget.selectedArtist}');
      
      try {
        final songList = await ArtistService.getAllSongsByArtist(widget.selectedArtist);
        setState(() {
          _songNames = songList.isNotEmpty ? songList : ['percussion.mp3', 'bass.mp3', 'rhythm.mp3', 'lead.mp3'];
        });
        print('✅ Loaded ${_songNames.length} songs: $_songNames');
      } catch (e) {
        print('⚠️ Failed to load artist songs, using defaults');
        setState(() {
          _songNames = ['percussion.mp3', 'bass.mp3', 'rhythm.mp3', 'lead.mp3'];
        });
      }
    } catch (e) {
      print('❌ Complete song loading failed: $e');
      setState(() {
        _songNames = ['percussion.mp3', 'bass.mp3', 'rhythm.mp3', 'lead.mp3'];
      });
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
    if (_isLoading[index] || index >= _songNames.length) return;
    
    setState(() {
      _isLoading[index] = true;
    });

    try {
      if (_isPlaying[index]) {
        await _players[index].pause();
      } else {
        final fileName = _songNames[index];
        final url = 'https://raw.githubusercontent.com/adamalama151212-code/songs/main/$fileName';
        
        if (_currentPosition[index] == Duration.zero) {
          await SimpleAudioService().playFromUrl(_players[index], url);
        } else {
          await _players[index].resume();
        }
      }
    } catch (e) {
      print('❌ Failed to toggle play for ${_songNames[index]}: $e');
    } finally {
      setState(() {
        _isLoading[index] = false;
      });
    }
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
        // Tutaj można dodać logikę automatycznego sprawdzania przy wciśnięciu Enter
      },
    );
  }

  Widget _buildInstrumentSlider(int index) {
    final instrumentName = _getInstrumentName(index);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nazwa instrumentu
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
          // Slider z przyciskiem
          Row(
            children: [
              // Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color.fromARGB(255, 120, 140, 255),
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: const Color.fromARGB(255, 120, 140, 255),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _totalDuration[index].inMilliseconds > 0
                        ? _currentPosition[index].inMilliseconds / _totalDuration[index].inMilliseconds
                        : 0.0,
                    onChanged: (value) {
                      if (_totalDuration[index].inMilliseconds > 0) {
                        final position = Duration(
                          milliseconds: (value * _totalDuration[index].inMilliseconds).round(),
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
          // Czas aktualny / całkowity
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
              const SizedBox(width: 64), // Odpowiada szerokości przycisku
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
          // Gradient tła - identyczne z resztą aplikacji
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
                            for (int i = 0; i < 4; i++) _buildInstrumentSlider(i),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Back button
                  CustomBackButton(
                    onPressed: widget.onBack,
                  ),
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