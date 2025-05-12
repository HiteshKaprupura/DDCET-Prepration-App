import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'dart:async'; // Import for Timer if needed for delays

// --- Question Class (remains the same) ---
class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

// --- MCQQuizPage StatefulWidget (remains mostly the same) ---
class MCQQuizPage extends StatefulWidget {
  const MCQQuizPage({super.key});

  @override
  _MCQQuizPageState createState() => _MCQQuizPageState();
}

class _MCQQuizPageState extends State<MCQQuizPage> with TickerProviderStateMixin { // Use TickerProviderStateMixin for multiple controllers
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  String _feedback = '';
  bool _showFeedback = false; // Control feedback visibility

  // Animation Controllers
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackFadeAnimation;
  late AnimationController _optionsAnimationController; // For animating options in
  late List<Animation<double>> _optionAnimations; // Individual animations for options

  // Your Questions Data
  final List<Question> _questions = [
    const Question(
      questionText: 'What is the SI unit of force?',
      options: ['Newton', 'Joule', 'Pascal', 'Ampere'],
      correctAnswer: 'Newton',
      explanation: 'Force is measured in Newtons (N) in the SI system.',
    ),
    const Question(
      questionText: 'Who formulated the laws of classical motion?',
      options: ['Isaac Newton', 'Albert Einstein', 'Galileo Galilei', 'Michael Faraday'],
      correctAnswer: 'Isaac Newton',
      explanation: 'Sir Isaac Newton formulated the three laws of motion.',
    ),
    const Question(
      questionText: 'What does E=mc² represent?',
      options: ['Energy-mass equivalence', 'Kinetic energy formula', 'Potential energy formula', 'Ohm\'s Law'],
      correctAnswer: 'Energy-mass equivalence',
      explanation: 'E=mc² describes the relationship between energy (E) and mass (m).',
    ),
    const Question(
      questionText: 'What phenomenon causes rainbows?',
      options: ['Refraction and Reflection', 'Diffraction', 'Interference', 'Polarization'],
      correctAnswer: 'Refraction and Reflection',
      explanation: 'Rainbows are formed by refraction and reflection of light in water droplets.',
    ),
    const Question(
      questionText: 'What is the speed of light in a vacuum?',
      options: ['300,000 km/s', '150,000 km/s', '1,000,000 km/s', 'Light cannot travel in a vacuum'],
      correctAnswer: '300,000 km/s',
      explanation: 'The speed of light in a vacuum (c) is approximately 299,792,458 meters per second, often rounded to 300,000 km/s.',
    ),
  ];

  Question get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();

    // Feedback Animation
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _feedbackFadeAnimation = CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.easeOut,
    );

    // Options Animation (Staggered)
    _optionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Total duration for all options
      vsync: this,
    );

    _setupOptionAnimations();
    _optionsAnimationController.forward(); // Start animation for the first question
  }

  // Helper to set up staggered animations for options
  void _setupOptionAnimations() {
    _optionAnimations = List.generate(
      _currentQuestion.options.length,
          (index) {
        final startTime = (index * 0.1).clamp(0.0, 1.0); // Stagger start times
        final endTime = (startTime + 0.5).clamp(0.0, 1.0); // Control duration
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _optionsAnimationController,
            curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    _optionsAnimationController.dispose();
    super.dispose();
  }

  void _handleRadioValueChange(String? value) {
    if (!_isAnswerSubmitted) {
      setState(() {
        _selectedAnswer = value;
        _showFeedback = false; // Hide feedback if user changes answer
        _feedbackAnimationController.reset();
      });
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an answer first!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }

    final bool isCorrect = _selectedAnswer == _currentQuestion.correctAnswer;
    setState(() {
      _isAnswerSubmitted = true;
      if (isCorrect) {
        _score++;
        _feedback = 'Correct! ${_currentQuestion.explanation}';
      } else {
        _feedback = 'Incorrect. The correct answer is: ${_currentQuestion.correctAnswer}.\n\n${_currentQuestion.explanation}';
      }
      _showFeedback = true; // Mark feedback to be shown
      _feedbackAnimationController.forward(from: 0.0); // Start fade-in
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswerSubmitted = false;
        _showFeedback = false; // Hide feedback for next question
        _feedback = '';
        _feedbackAnimationController.reset();
        _optionsAnimationController.reset(); // Reset options animation
        _setupOptionAnimations(); // Re-setup animations for new options
        _optionsAnimationController.forward(); // Animate new options in
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => Dialog( // Use Dialog for more customization
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.indigo.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_outlined, color: Colors.amber.shade700, size: 60),
              const SizedBox(height: 15),
              Text(
                'Quiz Completed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Your Score:',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Text(
                '$_score / ${_questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Reset the quiz state
                  setState(() {
                    _currentQuestionIndex = 0;
                    _score = 0;
                    _selectedAnswer = null;
                    _isAnswerSubmitted = false;
                    _showFeedback = false;
                    _feedback = '';
                    _feedbackAnimationController.reset();
                    _optionsAnimationController.reset();
                    _setupOptionAnimations();
                    _optionsAnimationController.forward();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 3,
                ),
                child: Text('Restart Quiz', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // --- Build Option Tile Widget ---
  Widget _buildOptionTile(String option, int index) {
    bool isCorrect = option == _currentQuestion.correctAnswer;
    bool isSelected = option == _selectedAnswer;
    Color tileColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    double borderWidth = 1.0;
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;
    IconData? trailingIconData;
    Color? trailingIconColor;
    double elevation = 1.0; // Base elevation

    if (_isAnswerSubmitted) {
      // If submitted, show correct/incorrect status
      if (isCorrect) {
        tileColor = Colors.green.shade50;
        borderColor = Colors.green.shade500;
        textColor = Colors.green.shade900;
        fontWeight = FontWeight.w600;
        trailingIconData = Icons.check_circle_outline_rounded;
        trailingIconColor = Colors.green.shade700;
        borderWidth = 1.5;
        elevation = isSelected ? 3.0 : 1.0;
      } else if (isSelected && !isCorrect) {
        tileColor = Colors.red.shade50;
        borderColor = Colors.red.shade400;
        textColor = Colors.red.shade900;
        fontWeight = FontWeight.w600;
        trailingIconData = Icons.highlight_off_rounded;
        trailingIconColor = Colors.red.shade700;
        borderWidth = 1.5;
        elevation = 3.0;
      } else {
        // Other options when submitted (not selected, not correct)
        tileColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade600;
      }
    } else if (isSelected) {
      // If selected but not submitted yet
      tileColor = Colors.indigo.shade50;
      borderColor = Colors.indigo.shade400;
      textColor = Colors.indigo.shade900;
      fontWeight = FontWeight.w600;
      borderWidth = 1.5;
      elevation = 3.0; // Add elevation on selection
    }

    // Apply the slide/fade animation to each option tile
    return FadeTransition(
      opacity: _optionAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2), // Start slightly below
          end: Offset.zero,
        ).animate(_optionAnimations[index]),
        child: Card(
          elevation: elevation,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          color: tileColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          child: InkWell( // Use InkWell for tap effect inside Card
            onTap: () => _handleRadioValueChange(option),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0), // Adjust padding
              child: Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: _handleRadioValueChange,
                    activeColor: _isAnswerSubmitted
                        ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                        : Colors.indigo,
                  ),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (_isAnswerSubmitted && trailingIconData != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Icon(trailingIconData, color: trailingIconColor, size: 22),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for the whole page
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.deepPurple.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea( // Ensure content is below status bar
          child: Column(
            children: [
              // Custom AppBar Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton( // Optional Back Button
                      icon: Icon(Icons.arrow_back_ios, color: Colors.indigo.shade700),
                      onPressed: () => Navigator.maybePop(context), // Or handle as needed
                    ),
                    Text(
                      'Physics Quiz',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    SizedBox(width: 40), // Placeholder for centering title if back button exists
                    // If no back button, remove IconButton and SizedBox
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress Bar and Counter
                      Row(
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1}',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_currentQuestionIndex + 1}/${_questions.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect( // Rounded corners for progress bar
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentQuestionIndex + 1) / _questions.length,
                          backgroundColor: Colors.indigo.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Question Text Card
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        color: Colors.white, // White background for contrast
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _currentQuestion.questionText,
                            style: GoogleFonts.poppins(
                              fontSize: 19, // Slightly larger
                              fontWeight: FontWeight.w600, // Bolder
                              color: Colors.indigo.shade900,
                              height: 1.4, // Line spacing
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Options List (using ListView for potential scrolling on small screens)
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(), // Nice scroll effect
                          children: _currentQuestion.options
                              .asMap() // Get index along with option
                              .entries
                              .map((entry) => _buildOptionTile(entry.value, entry.key))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Feedback Area (Animated)
                      AnimatedSize( // Animate size change when feedback appears/disappears
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: FadeTransition(
                          opacity: _feedbackFadeAnimation,
                          child: _showFeedback // Control visibility
                              ? Container(
                            margin: const EdgeInsets.only(bottom: 15), // Add margin below feedback
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _feedback.startsWith('Correct')
                                  ? Colors.green.shade100.withOpacity(0.9)
                                  : Colors.red.shade100.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                  color: _feedback.startsWith('Correct')
                                      ? Colors.green.shade400
                                      : Colors.red.shade400,
                                  width: 1.5
                              ),
                            ),
                            child: Row( // Icon + Text
                              children: [
                                Icon(
                                  _feedback.startsWith('Correct') ? Icons.check_circle : Icons.cancel,
                                  color: _feedback.startsWith('Correct') ? Colors.green.shade800 : Colors.red.shade800,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _feedback,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      color: _feedback.startsWith('Correct') ? Colors.green.shade900 : Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox.shrink(), // Use SizedBox.shrink() when hidden
                        ),
                      ),


                      // Submit / Next Button
                      ElevatedButton(
                        onPressed: _isAnswerSubmitted ? _nextQuestion : _submitAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3.0,
                          textStyle: GoogleFonts.poppins( // Apply font here too
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(_isAnswerSubmitted
                            ? (_currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'Show Results')
                            : 'Submit Answer'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}