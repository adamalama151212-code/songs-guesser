import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            //Gradient tła
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
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Info about the game will be here',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                Positioned(
                  top: 10.0,
                  right: 10.0, // USTAWIENIE x PO PRAWEJ STRONIE
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 40.0,
                    ),
                    onPressed: () {
                      // FUNKCJA COFANIA
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
