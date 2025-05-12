import 'package:ddcet_preparation/Chemistry/ChemistryPage.dart';
import 'package:ddcet_preparation/Phy/PhysicsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Computer/ComputerPage.dart';
import 'EnvironmentalScience/Environmental_Science.dart';
import 'Mathematics/MathematicsPage.dart';
import 'PhysicsQuizPage.dart';


// Main Home Page Widget
class DDCETHomePage extends StatefulWidget {
  const DDCETHomePage({super.key});

  @override
  State<DDCETHomePage> createState() => _DDCETHomePageState();
}

class _DDCETHomePageState extends State<DDCETHomePage> {
  // Tracks the selected index for bottom navigation
  int _selectedIndex = 0;

  // Data representing subjects and their topics
  final List<Map<String, dynamic>> subjects = [
    // Physics section
    {
      'title': 'Physics',
      'topics': [
        'Units & Measurement', 'Classical Mechanics', 'Electric Current',
        'Heat & Thermometry', 'Wave Motion, Optics, Acoustics'
      ],
      'icon': Icons.science_outlined,
      'color': Colors.deepPurpleAccent,
      'gradient': [Colors.deepPurple.shade400, Colors.purpleAccent.shade100],
      'quizPage': const PhysicsPage(), // Physics Quiz Page
    },
    // Chemistry section
    {
      'title': 'Chemistry',
      'topics': [
        'Chemical Reactions', 'Acids, Bases & Salts', 'Metals & Non-metals', 'Corrosion'
      ],
      'icon': Icons.biotech_outlined,
      'color': Colors.teal,
      'gradient': [Colors.teal.shade400, Colors.cyan.shade200],
      'quizPage': const ChemistryPage() // Placeholder quiz
    },
    // Computer Practice section
    {
      'title': 'Computer Practice',
      'topics': ['Computer Basics', 'Internet (HTML)', 'MS Word', 'MS Excel', 'MS PowerPoint'],
      'icon': Icons.computer_outlined,
      'color': Colors.blue.shade700,
      'gradient': [Colors.blue.shade500, Colors.lightBlue.shade200],
      'quizPage': const ComputerSciencePage(), // Placeholder quiz
    },
    // Environmental Science section
    {
      'title': 'Environmental Sci.',
      'topics': ['Ecosystem & Pollution', 'Climate Change', 'Renewable Energy Sources'],
      'icon': Icons.eco_outlined,
      'color': Colors.green.shade600,
      'gradient': [Colors.green.shade500, Colors.lightGreen.shade200],
      'quizPage': const EnvironmentalSciencesPage(), // Placeholder quiz
    },
    // Mathematics section
    {
      'title': 'Mathematics',
      'topics': [
        'Determinants & Matrices', 'Trigonometry', 'Vectors', 'Coordinate Geometry',
        'Functions & Limits', 'Differentiation', 'Integration', 'Logarithm', 'Statistics'
      ],
      'icon': Icons.calculate_outlined,
      'color': Colors.orange.shade800,
      'gradient': [Colors.orange.shade600, Colors.amber.shade300],
      'quizPage': const Mathematicspage(), // Placeholder quiz
    },
    // Aptitude & Communication section
    {
      'title': 'Aptitude & Comm.',
      'topics': ['Comprehension', 'Communication Theory', 'Writing Techniques', 'Grammar', 'Sentence Correction'],
      'icon': Icons.spellcheck_outlined,
      'color': Colors.red.shade600,
      'gradient': [Colors.red.shade400, Colors.pink.shade100],
      'quizPage': const PlaceholderQuizPage(subject: 'Aptitude & Communication'), // Placeholder quiz
    },
  ];

  // Prevent accidental back navigation
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Go back to the first tab (Subjects)
      });
      return false; // Prevent route from popping
    }
    return false; // Prevent app exit (custom exit confirmation can be added)
  }

  // List of Pages for Bottom Navigation
  List<Widget> get _pages => [
    _buildSubjectsPage(), // Subjects Page
    _buildPlaceholderPage(icon: Icons.quiz_outlined, text: 'Mock Tests Coming Soon!'), // Mock Test Page
  ];

  // Builds the Subjects page with list view
  Widget _buildSubjectsPage() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  // Creates a visually enhanced Subject Card for each subject
  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final String title = subject['title'] ?? 'Unnamed Subject';
    final List<String> topics = (subject['topics'] as List?)?.cast<String>() ?? ['No topics available'];
    final IconData icon = subject['icon'] ?? Icons.book_online;
    final Color color = subject['color'] ?? Colors.grey;
    final List<Color> gradientColors = (subject['gradient'] as List?)?.cast<Color>() ?? [color.withOpacity(0.7), color.withOpacity(0.4)];
    final Widget quizPage = subject['quizPage'] ?? const Scaffold(body: Center(child: Text('Error: Quiz page not set up correctly')));

    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => quizPage));
        },
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        topics.join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white.withOpacity(0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Widget for Placeholder Pages
  Widget _buildPlaceholderPage({required IconData icon, required String text}) {
    return Center(
      child: Opacity(
        opacity: 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.grey.shade500),
            const SizedBox(height: 15),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  // Main build method for UI layout
  @override
  Widget build(BuildContext context) {
    const Color appBarColor = Colors.indigo;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('DDCET Preparation', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          backgroundColor: appBarColor,
          elevation: 3.0,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.grey.shade100,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: appBarColor,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 10.0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12.5),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: 'Subjects'),
            BottomNavigationBarItem(icon: Icon(Icons.history_edu_outlined), activeIcon: Icon(Icons.history_edu), label: 'Mock Test'),
          ],
        ),
      ),
    );
  }
}

// Placeholder quiz page for subjects without a real quiz page yet
class PlaceholderQuizPage extends StatelessWidget {
  final String subject;
  const PlaceholderQuizPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subject Quiz', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Quiz content coming soon for $subject!')),
    );
  }
}
