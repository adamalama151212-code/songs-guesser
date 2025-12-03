import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'start_screen.dart';
import 'game_screen.dart';
import 'difficulty_level.dart';
import 'final_game_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  var activeScreen = 'start-screen';
  String? _selectedArtistForGame;
  String? _selectedDifficulty;

  void switchScreen() {
    setState(() {
      activeScreen = 'game-screen';
    });
  }

  void goBackToStart() {
    setState(() {
      activeScreen = 'start-screen';
    });
  }

  void goBackToGame() {
    setState(() {
      activeScreen = 'game-screen';
    });
  }

  void goBackToArtistSelection() {
    setState(() {
      activeScreen = 'game-screen';
    });
  }

  void onArtistSelected(String artistName) {
    setState(() {
      _selectedArtistForGame = artistName;
      activeScreen = 'difficulty-level-screen';
    });
  }

  void onDifficultySelected(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      activeScreen = 'final-game-screen';
    });
  }

  void goBackToDifficulty() {
    setState(() {
      activeScreen = 'difficulty-level-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = StartScreen(switchScreen);

    if (activeScreen == 'game-screen') {
      screenWidget = GameScreen(goBackToStart, onArtistSelected);
    } else if (activeScreen == 'difficulty-level-screen') {
      screenWidget = DifficultyScreen(
        selectedArtist: _selectedArtistForGame!,
        onBack: goBackToArtistSelection,
        onDifficultySelected: onDifficultySelected,
      );
    } else if (activeScreen == 'final-game-screen') {
      screenWidget = FinalGameScreen(
        selectedArtist: _selectedArtistForGame!,
        selectedDifficulty: _selectedDifficulty!,
        onBack: goBackToDifficulty,
      );
    }

    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.russoOne().fontFamily,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(121, 212, 209, 209),
                const Color.fromARGB(221, 7, 41, 114),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
