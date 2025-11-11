# Song Guesser

Aplikacja muzyczna do zgadywania utworów z możliwością odtwarzania różnych ścieżek instrumentalnych.

## Funkcjonalności

- 🎵 **Odtwarzanie wielościeżkowe**: 4 niezależne suwaki audio (główna ścieżka + 3 dodatkowe instrumenty)
- 🎸 **Inteligentne przypisywanie instrumentów**: Automatyczne rozpoznawanie i przypisywanie percussion, bass, rhythm guitar, lead guitar
- 👨‍🎤 **Biblioteka artystów**: AC/DC, John Mayer i inni wykonawcy
- 🎛️ **Kontrola głośności**: Indywidualna regulacja każdej ścieżki audio
- 📱 **Responsywny interfejs**: Nowoczesny UI z gradientami i animacjami

## Technologie

- **Frontend**: Flutter, Dart
- **Audio**: audioplayers package
- **Backend**: Flask (Python) + SQLite
- **Hosting audio**: GitHub raw files
- **Architektura**: Modułowe widgety, StreamBuilder pattern

## Struktura projektu

```
lib/
├── main.dart                 # Punkt wejścia aplikacji
├── app.dart                  # Główny widget i routing
├── start_screen.dart         # Ekran startowy
├── artists_screen.dart       # Wybór artysty
├── difficulty_level.dart     # Wybór poziomu trudności
├── final_game_screen.dart    # Główny ekran gry z audio
├── info_screen.dart          # Informacje o grze
├── services/
│   └── artist_service.dart   # Komunikacja z backend API
└── widgets/
    ├── additional_audio_slider.dart  # Suwak dodatkowych ścieżek audio
    ├── artist_header.dart           # Nagłówek z informacjami o artyście
    ├── back_button.dart             # Przycisk nawigacji wstecznej  
    ├── main_audio_slider.dart       # Główny suwak audio z kontrolami
    └── song_input.dart              # Pole tekstowe do wprowadzania tytułu
```

## Instalacja

1. Zainstaluj Flutter SDK
2. Sklonuj repozytorium
3. Uruchom: `flutter pub get`
4. Uruchom backend API (Flask)
5. Uruchom aplikację: `flutter run`

## Backend API

Backend wymaga Flask servera z endpointami:
- `/artists` - lista artystów
- `/songs/by-artist` - piosenki dla konkretnego artysty
- `/songs/all-by-artist` - wszystkie piosenki artysty

Pliki audio hostowane na GitHub w formacie: `[instrument][songname].mp3`
