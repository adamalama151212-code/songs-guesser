import 'package:flutter/material.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                    'Content of Artists page will be here',
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
