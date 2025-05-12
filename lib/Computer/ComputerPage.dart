import 'package:flutter/material.dart';
import 'Basics_of_Computer_System.dart';
import 'Introduction_to_Internet_HTML.dart';
import 'Using_MS_Word_Excel_PowerPoint.dart'; // Adjust imports as necessary
 // Page for MS Word/Excel/PowerPoint

class ComputerSciencePage extends StatelessWidget {
  const ComputerSciencePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the chapters for the Computer Science topics
    final List<Map<String, dynamic>> chapters = [
      {
        'title': 'Basics of Computer System',
        'icon': Icons.computer_rounded, // Icon representing computer systems
        'page': const BasicsOfComputerSystem(), // Navigate to the specific page
        'colors': [Colors.blue.shade400, Colors.blue.shade200], // Gradient colors
      },
      {
        'title': 'Introduction to Internet HTML',
        'icon': Icons.web_rounded, // Icon representing the web/HTML
        'page': const IntroductionToInternetHtml(), // Navigate to the specific page
        'colors': [Colors.green.shade400, Colors.green.shade200], // Gradient colors
      },
      {
        'title': 'Using MS Word/Excel/PowerPoint',
        'icon': Icons.library_books_rounded, // Icon representing office software
        'page': const UsingMsWordExcelPowerpoint(), // Navigate to the specific page
        'colors': [Colors.deepOrange.shade400, Colors.deepOrange.shade200], // Gradient colors
      },
      // Add more topics here if needed
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
        title: const Text('Computer Science Topics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue, // General theme color for the page
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Padding around the list
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          // Use provided colors or a default gradient
          final gradientColors = chapter['colors'] as List<Color>? ?? [Colors.blue.shade300, Colors.blue.shade100];

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
