import 'package:flutter/material.dart';

import 'Environmental_Sci.dart';

class EnvironmentalSciencesPage extends StatelessWidget {
  const EnvironmentalSciencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define Environmental Science topics
    final List<Map<String, dynamic>> chapters = [
      {
        'title': 'Ecosystem & Pollution\nClimate Change\nRenewable Energy Sources',
        'icon': Icons.nature_people_rounded,
        'page': const EnvironmentalSci(),
        'colors': [Colors.green.shade600, Colors.green.shade300],
      },
      // {
      //   'title': 'Natural Resources',
      //   'icon': Icons.park_rounded,
      //   'page': const NaturalResources(),
      //   'colors': [Colors.brown.shade400, Colors.brown.shade200],
      // },
      // {
      //   'title': 'Climate Change & Sustainability',
      //   'icon': Icons.eco_rounded,
      //   'page': const ClimateChangeAndSustainability(),
      //   'colors': [Colors.teal.shade400, Colors.teal.shade200],
      // },
      // Add more topics as needed
    ];
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Environmental Science Topics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final gradientColors = chapter['colors'] as List<Color>;

          return Card(
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => chapter['page']),
                );
              },
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
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
                          shadows: [
                            Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)
                          ],
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
