import 'package:flutter/material.dart';
import 'package:ddcet_preparation/Mathematics/DeterminantsPage.dart';
import 'CoordinateGeometryPage.dart';
import 'DifferentiationPage.dart';
import 'FunctionLimitPage.dart';
import 'IntegrationPage.dart';
import 'LogarithmPage.dart';
import 'StatisticsPage.dart';
import 'TrigonometryPage.dart';
import 'VectorsPage.dart';

class Mathematicspage extends StatelessWidget {
  const Mathematicspage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chapters = [
      {
        'title': '1. Determinants and Matrices',
        'icon': Icons.grid_4x4_rounded,
        'page': const Determinantspage(),
        'colors': [Colors.indigo.shade700, Colors.indigo.shade400],
      },
      {
        'title': '2. Trigonometry',
        'icon': Icons.change_circle_rounded,
        'page': const Trigonometrypage(),
        'colors': [Colors.purple.shade700, Colors.purple.shade400],
      },
      {
        'title': '3. Vectors',
        'icon': Icons.swap_calls_rounded,
        'page': const Vectorspage(),
        'colors': [Colors.blue.shade700, Colors.blue.shade400],
      },
      {
        'title': '4. Coordinate Geometry',
        'icon': Icons.map_rounded,
        'page': const Coordinategeometrypage(),
        'colors': [Colors.teal.shade700, Colors.teal.shade400],
      },
      {
        'title': '5. Function & Limit',
        'icon': Icons.functions,
        'page': const Functionlimitpage(),
        'colors': [Colors.orange.shade800, Colors.orange.shade400],
      },
      {
        'title': '6. Differentiation & Applications',
        'icon': Icons.trending_up_rounded,
        'page': const Differentiationpage(),
        'colors': [Colors.red.shade700, Colors.red.shade400],
      },
      {
        'title': '7. Integration',
        'icon': Icons.integration_instructions_rounded,
        'page': const Integrationpage(),
        'colors': [Colors.green.shade700, Colors.green.shade400],
      },
      {
        'title': '8. Logarithm',
        'icon': Icons.calculate_outlined,
        'page': const Logarithmpage(),
        'colors': [Colors.brown.shade700, Colors.brown.shade400],
      },
      {
        'title': '9. Statistics',
        'icon': Icons.bar_chart_rounded,
        'page': const Statisticspage(),
        'colors': [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mathematics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.yellow.shade700,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final gradientColors = chapter['colors'] as List<Color>;

          return Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
                padding: const EdgeInsets.all(18),
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
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
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
