import 'package:audioplayers/audioplayers.dart';

/// Prosty service do odtwarzania audio bez skomplikowanego cache'owania
class SimpleAudioService {
  static final SimpleAudioService _instance = SimpleAudioService._internal();
  factory SimpleAudioService() => _instance;
  SimpleAudioService._internal();

  /// Proste odtwarzanie z URL
  Future<void> playFromUrl(AudioPlayer player, String url) async {
    try {
      print('🎵 Playing: ${url.split('/').last}');
      await player.stop();
      await player.play(UrlSource(url));
    } catch (e) {
      print('❌ Failed to play $url: $e');
      throw e;
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