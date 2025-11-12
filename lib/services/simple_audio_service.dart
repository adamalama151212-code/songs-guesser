import 'package:audioplayers/audioplayers.dart';

/// Prosty service do odtwarzania audio bez skomplikowanego cache'owania
class SimpleAudioService {
  static final SimpleAudioService _instance = SimpleAudioService._internal();
  factory SimpleAudioService() => _instance;
  SimpleAudioService._internal();

  /// Proste odtwarzanie z URL z retry logic
  Future<void> playFromUrl(AudioPlayer player, String url) async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        attempts++;
        print('🎵 Playing: ${url.split('/').last} (attempt $attempts/$maxAttempts)');
        
        await player.stop();
        await player.play(UrlSource(url));
        
        // Czekamy chwilę aby sprawdzić czy audio się załadowało
        await Future.delayed(const Duration(milliseconds: 1000));
        
        final state = player.state;
        if (state == PlayerState.playing || state == PlayerState.paused) {
          print('✅ Successfully loaded: ${url.split('/').last}');
          return; // Sukces!
        } else {
          throw Exception('Player state is $state after loading');
        }
        
      } catch (e) {
        print('❌ Attempt $attempts failed for $url: $e');
        
        if (attempts >= maxAttempts) {
          print('💀 All attempts failed for $url');
          throw e;
        } else {
          print('🔄 Retrying in 1 second...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }

  /// Podstawowe ustawienia jakości audio
  void setupPlayerQuality(AudioPlayer player) {
    player.setVolume(1.0);
    player.setBalance(0.0);
    // Ustawienia dla lepszej obsługi audio focus
    player.setPlayerMode(PlayerMode.mediaPlayer);
  }
}