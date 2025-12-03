import 'package:flutter/material.dart';
import './artists_screen.dart';
import './info_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen(this.startApp, {super.key});

  final void Function() startApp;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Color.fromARGB(255, 190, 143, 252),
      backgroundColor: Colors.black.withOpacity(0.4),
      side: const BorderSide(color: Colors.white, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      fixedSize: const Size(220, 50),
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/songGuesserLogo.png', width: 280),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: startApp,
            style: buttonStyle,
            child: const Text('PLAY'),
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const ArtistsScreen()),
              );
            },
            style: buttonStyle,
            child: const Text('Artists'),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const InfoScreen()),
              );
            },
            style: buttonStyle,
            child: const Text('Info'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
