import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ArtistService {
  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  // Resource path. We keep '/artists' separately to avoid duplicating it in base URL.
  static const String _artistsPath = '/artists';
  static const String _songsPath = '/songs';

  /// Fetches list of artists from backend
  /// Contract:
  /// - GET {baseUrl}/artists
  /// - Accepts: application/json
  /// - Timeout: 8s (so UI doesn't hang forever)
  /// - Handles two response shapes:
  ///   a) ["AC/DC", "Queen", ...]
  ///   b) { "artists": [ {"id": 1, "name": "AC/DC"}, ... ] }
  static Future<List<String>> fetchArtists() async {
    try {
      // Budujemy URI bez powielania '/artists'
      final uri = Uri.parse('${_resolveBaseUrl()}$_artistsPath');

      // Wysyłamy żądanie z nagłówkiem Accept i twardym timeoutem
      final response = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Bezpieczne dekodowanie (UTF-8), następnie JSON.parse
        final body = utf8.decode(response.bodyBytes);
        final decoded = json.decode(body);
        if (decoded is List) {
          // List -> extract names
          return _toNameList(decoded);
        } else if (decoded is Map && decoded['artists'] is List) {
          // Object with 'artists' key -> extract names
          return _toNameList(decoded['artists'] as List);
        } else {
          throw Exception('Unexpected response shape: ${decoded.runtimeType}');
        }
      }

      throw Exception(
        'Failed to load artists: ${response.statusCode} ${response.reasonPhrase}',
      );
    } catch (e) {
      // More readable errors
      if (e is TimeoutException) {
        throw Exception('Request to artists timed out.');
      }
      throw Exception('Error fetching artists: $e');
    }
  }

  // [8] Normalizacja danych -> lista samych nazw
  // Obsługuje:
  // - ["AC/DC", "Queen"]
  // - [{id: 1, name: "AC/DC"}, ...] i inne warianty (artist/title/band/bandName)
  static List<String> _toNameList(List<dynamic> list) {
    final names = <String>[];
    for (final item in list) {
      if (item is String) {
        // Backend wysłał prostą listę: ["AC/DC", "Queen"]
        names.add(item);
      } else if (item is Map) {
        // Backend wysłał obiekty: [{"id": 1, "name": "AC/DC"}]
        final name = item['name']?.toString();
        if (name != null && name.trim().isNotEmpty) {
          names.add(name.trim());
        }
      }
    }
    return names;
  }

  /// [9] Pobiera nazwę piosenki dla danego artysty
  /// Kontrakt:
  /// - POST {baseUrl}/songs/by-artist
  /// - Body: {"artist_name": "AC/DC"}
  /// - Response: {"song_name": "Back in Black"} lub {"error": "Not found"}
  static Future<String> getSongByArtist(String artistName) async {
    try {
      final uri = Uri.parse('${_resolveBaseUrl()}$_songsPath/by-artist');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'artist_name': artistName}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = json.decode(body);
        
        if (decoded is Map && decoded['song_name'] is String) {
          return decoded['song_name'] as String;
        } else if (decoded is Map && decoded['error'] is String) {
          throw Exception('Backend error: ${decoded['error']}');
        } else {
          throw Exception('Unexpected response format');
        }
      }

      throw Exception(
        'Failed to get song: ${response.statusCode} ${response.reasonPhrase}',
      );
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request to get song timed out.');
      }
      throw Exception('Error getting song: $e');
    }
  }

  /// Pobiera wszystkie piosenki dla artysty (lista)
  static Future<List<String>> getAllSongsByArtist(String artistName) async {
    try {
      final baseUrl = _resolveBaseUrl();
      final url = Uri.parse('$baseUrl$_songsPath/all-by-artist');
      
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'artist_name': artistName}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Oczekujemy: {"songs": ["song1.mp3", "song2.wav", ...]}
        if (data is Map && data.containsKey('songs')) {
          final songs = data['songs'] as List;
          return songs.map((song) => song.toString()).toList();
        }
        
        // Fallback - jeśli zwraca prostą listę
        if (data is List) {
          return data.map((song) => song.toString()).toList();
        }
        
        return [];
      }

      throw Exception(
        'Failed to get songs: ${response.statusCode} ${response.reasonPhrase}',
      );
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request to get songs timed out.');
      }
      throw Exception('Error getting songs: $e');
    }
  }

  /// Pobiera izolowane ścieżki audio dla konkretnej piosenki i artysty
  static Future<Map<String, String>> getIsolatedTracks(
    String artistName,
    String songName,
  ) async {
    try {
      final uri = Uri.parse('${_resolveBaseUrl()}/songs/isolated-tracks');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'artist_name': artistName,
          'song_name': songName,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        final data = json.decode(body);
        
        if (data is Map && data['tracks'] is Map) {
          final tracks = data['tracks'] as Map<String, dynamic>;
          return Map<String, String>.from(tracks);
        }
        
        return {};
      }

      throw Exception(
        'Failed to get isolated tracks: ${response.statusCode} ${response.reasonPhrase}',
      );
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request to get isolated tracks timed out.');
      }
      throw Exception('Error getting isolated tracks: $e');
    }
  }
}
