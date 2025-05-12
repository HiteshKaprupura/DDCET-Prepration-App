import 'package:flutter/material.dart';
// Assuming your imports are correct for these chapter pages
import 'package:ddcet_preparation/Phy/units_and_measurement.dart';
import 'package:ddcet_preparation/Phy/wave_motion_optics_acoustics.dart';
import '../PhysicsQuizPage.dart';
import 'classical_mechanics.dart';
import 'electric_current.dart';
import 'heat_thermometry.dart';

class PhysicsPage extends StatelessWidget {
  const PhysicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chapters = [
      // (Keep the same chapter list structure as in Option 1)
      {
        'title': 'Units & Measurement',
        'icon': Icons.straighten_rounded,
        'page': QuizScreen(),
        'colors': [Colors.blue.shade400, Colors.blue.shade200],
      },
      {
        'title': 'Classical Mechanics',
        'icon': Icons.speed_rounded,
        'page': Chapter_2(),
        'colors': [Colors.green.shade400, Colors.green.shade200],
      },
      // ... Add other chapters with their colors
      {
        'title': 'Electric Current',
        'icon': Icons.bolt_rounded,
        'page': Chapter_3(),
        'colors': [Colors.orange.shade400, Colors.orange.shade200],
      },
      {
        'title': 'Heat & Thermometry',
        'icon': Icons.thermostat_rounded,
        'page': Chapter_4(),
        'colors': [Colors.red.shade400, Colors.red.shade200],
      },
      {
        'title': 'Wave Motion, Optics, Acoustics',
        'icon': Icons.waves_rounded,
        'page': Chapter_5(),
        'colors': [Colors.purple.shade400, Colors.purple.shade200],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Physics Chapters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.purple,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Adjust padding for Card
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final gradientColors = chapter['colors'] as List<Color>? ?? [Colors.deepPurple.shade300, Colors.deepPurple.shade100];

          return Card( // Use Card as the main container
            elevation: 5, // Card provides elevation
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias, // Clip the content (gradient) to the card shape
            child: InkWell( // InkWell for tap effect
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => chapter['page']),
                );
              },
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Ink( // Use Ink instead of Container to draw BoxDecoration on Material surface
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16), // Padding inside the Ink
                child: Row(
                  children: [
                    Icon(
                      chapter['icon'],
                      size: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        chapter['title'],
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [ // Optional text shadow
                              Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)
                            ]
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}