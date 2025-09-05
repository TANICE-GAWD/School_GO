

import 'package:flutter/material.dart';
import 'package:school_go/features/button2.dart'; 

void main() {
  runApp(const PokemonGoApp());
}

class PokemonGoApp extends StatelessWidget {
  const PokemonGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1E2A38),
        appBar: AppBar(
          title: const Text(
            'Buttons',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF4A90E2),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (index) {
                return PokemonGoButton(
                  text: 'button${index + 1}',
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class PokemonGoButton extends StatelessWidget {
  final String text;

  const PokemonGoButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const buttonColor = Color(0xFF4A90E2);
    const borderColor = Color(0xFF00408B);
    const shadowColor = Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          
          if (text == 'button2') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Button2Screen()),
            );
          } else {
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$text was pressed!'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
          
        },
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(
              color: borderColor,
              width: 4.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: shadowColor,
                offset: Offset(0, 5),
                blurRadius: 5.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: shadowColor,
                    offset: Offset(2, 2),
                    blurRadius: 4.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}