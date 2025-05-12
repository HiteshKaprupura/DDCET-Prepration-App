import 'package:ddcet_preparation/Chemistry/Metals_and_Non-Metals.dart';
import 'package:flutter/material.dart';

import '../Home Page.dart';
import 'Acids_Bases_And_Salts.dart';
import 'Chemical_Reactionand_Equations.dart';


class ChemistryPage extends StatelessWidget {
  const ChemistryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the Chemistry chapters data
    final List<Map<String, dynamic>> chapters = [
      {
        'title': 'Chemical Reactions and Equations',
        'icon': Icons.science_rounded, // Icon representing reactions/science
        'page': const ChemicalReactionandEquations(), // Navigate to the specific page
        'colors': [Colors.teal.shade400, Colors.teal.shade200], // Example colors
      },
      {
        'title': 'Acids, Bases and Salts',
        'icon': Icons.water_drop_rounded, // Icon representing liquids/pH
        'page': const AcidsBasesAndSalts(), // Navigate to the specific page
        'colors': [Colors.orange.shade400, Colors.orange.shade200], // Example colors
      },
      {
        'title': 'Metals and Non-metals',
        'icon': Icons.memory_rounded, // Icon representing materials/elements (like chips/conductors)
        // Alternative: Icons.layers_rounded, Icons.build_circle_outlined
        'page': const Metals_and_Non_Metals(), // Navigate to the specific page
        'colors': [Colors.blueGrey.shade400, Colors.blueGrey.shade200], // Example colors
      },
      // Add more chemistry chapters here if needed following the same structure
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
        title: const Text('Chemistry Chapters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal, // Chemistry theme color (e.g., teal)
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Padding around the list
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          // Use provided colors or a default gradient
          final gradientColors = chapter['colors'] as List<Color>? ?? [Colors.teal.shade300, Colors.teal.shade100];

          return Card( // Use Card for elevation and rounded corners
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 12), // Space between cards
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias, // Ensures gradient respects border radius
            child: InkWell( // Provides ripple effect on tap
              onTap: () {
                // Navigate to the specific chapter page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => chapter['page']),
                );
              },
              splashColor: Colors.white.withOpacity(0.2), // Customize splash color
              highlightColor: Colors.white.withOpacity(0.1), // Customize highlight color
              child: Ink( // Use Ink widget to paint the BoxDecoration (gradient) on Material
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16), // Padding inside the card content area
                child: Row(
                  children: [
                    Icon(
                      chapter['icon'], // Chapter-specific icon
                      size: 30,
                      color: Colors.white, // Icon color
                    ),
                    const SizedBox(width: 16), // Space between icon and text
                    Expanded( // Allows text to take available space
                      child: Text(
                        chapter['title'], // Chapter title
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [ // Subtle text shadow for better readability
                              Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)
                            ]
                        ),
                        // Optional: Handle text overflow if titles are very long
                        // overflow: TextOverflow.ellipsis,
                        // maxLines: 2,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16), // Trailing arrow
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