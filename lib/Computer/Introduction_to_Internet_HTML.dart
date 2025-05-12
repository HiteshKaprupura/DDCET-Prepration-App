import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mcq_model.dart'; // <-- Make sure this path is correct for your project

class IntroductionToInternetHtml extends StatefulWidget {
  // Using hardcoded path/title for simplicity in this example
  const IntroductionToInternetHtml({Key? key}) : super(key: key);

  @override
  State<IntroductionToInternetHtml> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<IntroductionToInternetHtml> with TickerProviderStateMixin {
  // --- Core Quiz State ---
  List<MCQ> questions = []; // Holds all loaded MCQs
  int currentQuestionIndex = 0; // Tracks the currently displayed question
  bool isLoading = true; // Flag for loading state (shows progress indicator)
  Map<int, String?> userAnswers = {}; // Stores the user's final answer for each question index

  // --- UI State (Specific to the current question being viewed) ---
  String _feedback = ''; // Feedback text (Correct/Incorrect + Explanation)
  bool _showFeedback = false; // Controls visibility of the feedback box

  // --- Animation Controllers ---
  // Used for visual flair (fade-in feedback, staggered options)
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackFadeAnimation;
  late AnimationController _optionsAnimationController;
  late List<Animation<double>> _optionAnimations = []; // One animation per option

  // --- Configuration ---
  // TODO: Consider passing these via the constructor for flexibility
  final String _jsonPath = 'assets/mcqs/Computer/Introduction_to_Internet_HTML.json'; // Path to the MCQ data
  final String _chapterTitle = "Introduction To Internet HTML"; // Title displayed in the app bar

  // --- Lifecycle Methods ---

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Start loading questions asynchronously
    loadQuestions();
  }

  @override
  void dispose() {
    // IMPORTANT: Dispose controllers to prevent memory leaks
    _feedbackAnimationController.dispose();
    _optionsAnimationController.dispose();
    super.dispose();
  }

  // --- Initialization Helper ---

  void _initializeAnimations() {
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _feedbackFadeAnimation = CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.easeOut,
    );
    _optionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly longer for staggered effect
      vsync: this,
    );
  }

  // --- Data Loading ---

  Future<void> loadQuestions() async {
    // Prevent state updates if the widget is disposed during the async operation
    if (!mounted) return;

    setState(() => isLoading = true); // Show loading indicator

    try {
      // 1. Load the raw JSON string from assets
      final jsonString = await rootBundle.loadString(_jsonPath);
      // 2. Decode the JSON string into a Dart list
      final List<dynamic> jsonData = jsonDecode(jsonString);
      // 3. Map each JSON object to an MCQ object using the factory constructor
      final loadedQuestions = jsonData.map((q) => MCQ.fromJson(q)).toList();

      // Check again if the widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        questions = loadedQuestions;
        isLoading = false; // Hide loading indicator
        // If questions loaded successfully, prepare animations for the first question
        if (questions.isNotEmpty) {
          _setupAndStartOptionAnimations();
        }
      });
    } catch (e) {
      // Handle potential errors during loading (file not found, invalid JSON)
      print("❌ Error loading questions from '$_jsonPath': $e");
      if (!mounted) return;
      setState(() {
        isLoading = false; // Hide loading indicator even on error
        questions = []; // Ensure questions list is empty on error
        // Consider showing an error message to the user in the build method
      });
    }
  }

  // --- State Getters (for cleaner access in build/logic) ---

  MCQ? get _currentQuestion {
    // Safely get the current MCQ object based on the index
    if (questions.isNotEmpty && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null; // Return null if index is out of bounds or questions are empty
  }

  String? get _currentSelectedAnswer {
    // Get the stored answer for the currently viewed question index
    return userAnswers[currentQuestionIndex];
  }

  bool get _isCurrentAnswerEvaluated {
    // Check if an answer has been stored (and thus evaluated) for the current index
    return userAnswers.containsKey(currentQuestionIndex);
  }

  // --- UI Logic & Interaction Handlers ---

  /// Configures and starts the staggered entrance animation for the current question's options.
  void _setupAndStartOptionAnimations() {
    final question = _currentQuestion;
    // Ensure we have a question and options to animate
    if (question == null || question.options.isEmpty) {
      _optionAnimations = [];
      return;
    }

    // Reset controller to start animations from the beginning
    _optionsAnimationController.reset();

    _optionAnimations = List.generate(
      question.options.length,
          (index) {
        // Calculate start and end times for staggering effect
        // Each option starts slightly later than the previous one
        final startTime = (index * 0.15).clamp(0.0, 1.0);
        final endTime = (startTime + 0.6).clamp(0.0, 1.0); // Duration of each item's animation
        // Create the animation tween
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _optionsAnimationController,
            // Use Interval to define when this specific animation runs within the controller's duration
            curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
          ),
        );
      },
      growable: false, // List size won't change
    );

    // Start the overall animation controller
    _optionsAnimationController.forward();
  }

  /// Called when a user taps an option tile.
  /// Stores the answer (making it final for this question) and shows feedback.
  void _handleOptionTap(String selectedOption) {
    // Prevent changing the answer once it's submitted for this question
    if (_isCurrentAnswerEvaluated) return;

    final question = _currentQuestion;
    if (question == null) return; // Should not happen if options are visible

    setState(() {
      // Record the user's choice for this question index
      userAnswers[currentQuestionIndex] = selectedOption;
      // Generate and display feedback immediately based on the selected answer
      _generateAndShowFeedback(selectedOption, question);
    });
  }

  /// Generates the feedback string (correct/incorrect, explanation) and triggers the feedback animation.
  void _generateAndShowFeedback(String? selectedAnswer, MCQ question) {
    // If there's no selected answer (e.g., when clearing state), hide feedback
    if (selectedAnswer == null) {
      _feedback = '';
      _showFeedback = false;
      _feedbackAnimationController.reset();
      return;
    }

    // Determine correctness
    final bool isCorrect = (selectedAnswer == question.correctAnswer);

    // Build the feedback message
    String generatedFeedback = isCorrect ? '✅ Correct!' : '❌ Incorrect!';
    if (!isCorrect) {
      generatedFeedback += '\nCorrect Answer: ${question.correctAnswer}.';
    }
    if (question.explanation.isNotEmpty) {
      // Append explanation if available
      generatedFeedback += '\n\nExplanation:\n${question.explanation}';
    }

    // Update state to show the feedback and start the animation
    _feedback = generatedFeedback;
    _showFeedback = true;
    _feedbackAnimationController.forward(from: 0.0); // Start fade-in animation
  }

  /// Updates the UI state (feedback, animations) when navigating between questions.
  void _loadStateForCurrentIndex() {
    final question = _currentQuestion;
    final selectedAnswer = _currentSelectedAnswer; // Get stored answer for the new index

    // Restore feedback display if an answer was previously submitted for this question
    if (question != null && selectedAnswer != null) {
      _generateAndShowFeedback(selectedAnswer, question);
    } else {
      // Otherwise, clear feedback for unanswered questions
      _feedback = '';
      _showFeedback = false;
      _feedbackAnimationController.reset();
    }

    // Trigger animations for the newly displayed question's options
    _setupAndStartOptionAnimations();
  }

  /// Moves to the next question in the list.
  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        // Load the state (answer feedback, animations) for the new question
        _loadStateForCurrentIndex();
      });
    }
    // Note: Showing results is handled by _handleNextOrResults
  }

  /// Moves to the previous question in the list.
  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        // Load the state (answer feedback, animations) for the new question
        _loadStateForCurrentIndex();
      });
    }
  }

  /// Handles the tap on the primary action button (Next or Show Results).
  void _handleNextOrResults() {
    // Check if we are on the last question
    if (currentQuestionIndex == questions.length - 1) {
      // Ensure the last question has been answered before showing results
      if (_isCurrentAnswerEvaluated) {
        _showResults();
      } else {
        // Inform user they need to answer the current question first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please answer the current question first.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 4,
          ),
        );
      }
    } else {
      // If not the last question, simply navigate to the next one
      _nextQuestion();
    }
  }

  /// Calculates the final score and displays the results dialog.
  void _showResults() {
    // Calculate score on demand based on the stored answers
    int finalScore = 0;
    userAnswers.forEach((index, selectedAnswer) {
      // Ensure the index is valid before accessing the question
      if (index < questions.length && selectedAnswer == questions[index].correctAnswer) {
        finalScore++;
      }
    });

    // --- Results Dialog ---
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 8,
        backgroundColor: Colors.transparent, // Let the Container's decoration show through
        child: Container(
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.indigo.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow( // Subtle shadow for depth
                  color: Colors.indigo.shade200.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fit content size
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 65),
              const SizedBox(height: 15),
              Text(
                'Quiz Completed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
              ),
              const SizedBox(height: 15),
              Text('Your Final Score:', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 10),
              Text(
                '$finalScore / ${questions.length}', // Display calculated score
                style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.indigo.shade700),
              ),
              const SizedBox(height: 30),
              // Restart Button
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Restart Quiz', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Reset the quiz state completely
                  setState(() {
                    currentQuestionIndex = 0;
                    userAnswers.clear(); // Clear all previous answers
                    _feedback = '';
                    _showFeedback = false;
                    _feedbackAnimationController.reset();
                    // Ensure animations are ready for the first question on restart
                    if (questions.isNotEmpty) {
                      _setupAndStartOptionAnimations();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Pill shape
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 12),
              // Back Button (Optional)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Pop the QuizScreen itself if possible
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigo.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('Back to Chapters', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // --- Widget Building Methods ---

  /// Builds a single, animated option tile (Card with Radio button and text).
  Widget _buildOptionTile(String option, int optionIndex) {
    final question = _currentQuestion;
    // Safety check - should not happen if build is called correctly
    if (question == null) return const SizedBox.shrink();

    // Get the state relevant *only* to the currently displayed question index
    final selectedAnswerForThisQuestion = _currentSelectedAnswer;
    final isThisQuestionEvaluated = _isCurrentAnswerEvaluated;

    // Determine the visual state of this specific option
    final bool isCorrect = option == question.correctAnswer;
    // Check if *this* option matches the answer stored for the *current* question index
    final bool isSelected = option == selectedAnswerForThisQuestion;

    // --- Dynamic Styling based on Evaluation State ---
    Color tileColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    double borderWidth = 1.0;
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;
    IconData? trailingIconData;
    Color? trailingIconColor;
    double elevation = 1.0; // Default elevation

    if (isThisQuestionEvaluated) {
      // Style differently if the user has already answered this question
      if (isCorrect) { // This is the correct option
        tileColor = Colors.green.shade50; borderColor = Colors.green.shade500; textColor = Colors.green.shade900; fontWeight = FontWeight.w600; trailingIconData = Icons.check_circle_outline_rounded; trailingIconColor = Colors.green.shade700; borderWidth = 1.5; elevation = isSelected ? 3.0 : 1.0; // Slightly raise if it was the selected one
      } else if (isSelected && !isCorrect) { // This is the incorrect option the user selected
        tileColor = Colors.red.shade50; borderColor = Colors.red.shade400; textColor = Colors.red.shade900; fontWeight = FontWeight.w600; trailingIconData = Icons.highlight_off_rounded; trailingIconColor = Colors.red.shade700; borderWidth = 1.5; elevation = 3.0; // Raise the incorrect selection
      } else { // Other incorrect options (not selected)
        tileColor = Colors.grey.shade100; borderColor = Colors.grey.shade300; textColor = Colors.grey.shade600; elevation = 0.5; // De-emphasize
      }
    }
    // Else (question not answered yet): Use default styles defined above.

    // Safety check for animations list bounds
    if (optionIndex >= _optionAnimations.length) {
      print("⚠️ Warning: Option animation index out of bounds ($optionIndex). Check _setupAndStartOptionAnimations.");
      return const SizedBox.shrink();
    }

    // Apply entrance animation (Fade + Slide)
    return FadeTransition(
      opacity: _optionAnimations[optionIndex],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.3), // Start slightly below
          end: Offset.zero,
        ).animate(_optionAnimations[optionIndex]), // Use this option's specific animation curve
        child: Card(
          elevation: elevation,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          color: tileColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: borderColor, width: borderWidth), // Dynamic border
          ),
          child: InkWell(
            // Allow tap only if this question hasn't been answered yet
            onTap: !isThisQuestionEvaluated ? () => _handleOptionTap(option) : null,
            borderRadius: BorderRadius.circular(12.0), // Match card shape for ripple
            splashColor: isThisQuestionEvaluated ? Colors.transparent : Colors.indigo.withOpacity(0.1),
            highlightColor: isThisQuestionEvaluated ? Colors.transparent : Colors.indigo.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: Row(
                children: [
                  Radio<String>(
                    value: option,
                    // groupValue reflects the stored answer for the current question
                    groupValue: selectedAnswerForThisQuestion,
                    // Allow change only if not evaluated
                    onChanged: !isThisQuestionEvaluated ? (value) {
                      if (value != null) _handleOptionTap(value);
                    } : null,
                    // Color changes based on correctness after evaluation
                    activeColor: isThisQuestionEvaluated
                        ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                        : Colors.indigo.shade600, // Default active color
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target padding
                    visualDensity: VisualDensity.compact, // Make radio slightly smaller
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0), // Space between radio and text
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          fontWeight: fontWeight, // Dynamic weight
                          color: textColor, // Dynamic color
                        ),
                      ),
                    ),
                  ),
                  // Show check/cross icon only after evaluation
                  if (isThisQuestionEvaluated && trailingIconData != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0), // Space from edge
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


  @override
  Widget build(BuildContext context) {
    // --- Handle Loading State ---
    if (isLoading) {
      return Scaffold(
        body: Container( // Consistent background gradient during load
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.deepPurple.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400)
              )
          ),
        ),
      );
    }

    // --- Handle Error/Empty State ---
    if (questions.isEmpty) {
      return Scaffold(
        body: Container( // Different gradient for error state (optional)
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.orange.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    "Oops! Could not load questions.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade900),
                  ),
                  const SizedBox(height: 10),
                  Text( // Provide helpful error info
                    "Please check if the file path ('$_jsonPath') is correct and the JSON file is validly formatted.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  // Allow user to navigate back if possible
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text("Go Back", style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    // --- Main Quiz UI ---
    final question = _currentQuestion!; // We know questions is not empty here
    // Determine button states for enabling/disabling navigation
    final bool canGoPrevious = currentQuestionIndex > 0;
    final bool canGoNext = currentQuestionIndex < questions.length - 1;
    // Check if the *currently displayed* question has been answered
    final bool isCurrentAnswered = _isCurrentAnswerEvaluated;

    return Scaffold(
      // Use a Container with gradient for the main background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.deepPurple.shade50, Colors.white], // Subtle gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.6, 1.0], // Control gradient spread
          ),
        ),
        // SafeArea avoids OS intrusions (status bar, notch)
        child: SafeArea(
          child: Column(
            children: [
              // --- Custom App Bar Area ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Material( // Wrap InkWell in Material for visual feedback
                      color: Colors.white.withOpacity(0.5), // Semi-transparent background
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Navigator.maybePop(context), // Safely pop if possible
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.indigo.shade700, size: 20),
                        ),
                      ),
                    ),
                    // Title (centered)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Prevent overlap
                        child: Text(
                          _chapterTitle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis, // Handle long titles
                          maxLines: 1,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigo.shade800),
                        ),
                      ),
                    ),
                    // Placeholder to balance the Row (same width as back button)
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // --- Scrollable Content Area ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // Nice scroll physics
                  // Consistent padding around the main content
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0), // Add bottom padding for buttons
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill width
                    children: [
                      // --- Progress Indicator ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${currentQuestionIndex + 1}',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                          ),
                          Text(
                            '${currentQuestionIndex + 1} / ${questions.length}',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect( // Rounded corners for the progress bar
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / questions.length, // Progress value
                          backgroundColor: Colors.indigo.shade100.withOpacity(0.5), // Background track color
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400), // Progress color
                          minHeight: 12, // Make it thicker
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- Question Text Card ---
                      Card(
                        elevation: 4.0,
                        shadowColor: Colors.indigo.withOpacity(0.2), // Soft shadow
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
                          child: Text(
                            question.questionText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade900, // Dark text for contrast
                              height: 1.5, // Line spacing
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- Options List ---
                      // Build each option tile using the helper method
                      Column(
                        children: question.options
                            .asMap() // Get index along with option string
                            .entries
                            .map((entry) => _buildOptionTile(entry.value, entry.key))
                            .toList(),
                      ),
                      const SizedBox(height: 15),

                      // --- Feedback Area (Animated Visibility) ---
                      // Shows Correct/Incorrect + Explanation after answering
                      AnimatedSize( // Animates size changes when feedback appears/disappears
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutQuad,
                        child: FadeTransition( // Animates opacity
                          opacity: _feedbackFadeAnimation,
                          // Conditionally build the feedback container
                          child: _showFeedback
                              ? Container(
                            margin: const EdgeInsets.only(bottom: 20), // Space before buttons
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            decoration: BoxDecoration(
                              // Dynamic background/border based on correctness
                                color: _feedback.startsWith('✅')
                                    ? Colors.green.shade100.withOpacity(0.95)
                                    : Colors.red.shade100.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    color: _feedback.startsWith('✅')
                                        ? Colors.green.shade300
                                        : Colors.red.shade300,
                                    width: 1.0
                                ),
                                boxShadow: [ // Subtle shadow for the feedback box
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2),
                                  )
                                ]
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align icon top-left with text
                              children: [
                                Icon( // Dynamic Icon
                                  _feedback.startsWith('✅') ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: _feedback.startsWith('✅') ? Colors.green.shade800 : Colors.red.shade800,
                                  size: 22,
                                ),
                                const SizedBox(width: 12), // Space between icon and text
                                Expanded( // Allow text to wrap
                                  child: Text(
                                    _feedback, // The generated feedback message
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      // Dynamic text color
                                      color: _feedback.startsWith('✅') ? Colors.green.shade900 : Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4, // Line spacing for explanations
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          // If _showFeedback is false, render an empty box (AnimatedSize handles the transition)
                              : const SizedBox.shrink(),
                        ),
                      ), // Feedback end

                      // --- Navigation Buttons Row ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Button
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                              label: Text('Prev', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                              // Enable only if not the first question
                              onPressed: canGoPrevious ? _previousQuestion : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Different style for prev button
                                foregroundColor: Colors.indigo.shade600,
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.grey.shade500,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(color: Colors.indigo.shade100) // Subtle border
                                ),
                                elevation: canGoPrevious ? 2.0 : 0.5, // Reduced elevation when disabled
                              ),
                            ),
                          ),
                          const SizedBox(width: 15), // Space between buttons
                          // Next / Show Results Button
                          Expanded(
                            child: ElevatedButton.icon(
                              // Dynamic icon: forward arrow or checkmark for results
                              icon: Icon(canGoNext ? Icons.arrow_forward_ios_rounded : Icons.done_all_rounded, size: 18),
                              // Dynamic label
                              label: Text(canGoNext ? 'Next' : 'Results', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                              // Enable ONLY if the current question has been answered
                              onPressed: isCurrentAnswered ? _handleNextOrResults : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade600, // Primary action color
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.indigo.shade200, // Muted color when disabled
                                disabledForegroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: isCurrentAnswered ? 3.0 : 0.5, // Reduced elevation when disabled
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ), // End Expanded Scrollable Area
            ],
          ),
        ), // End SafeArea
      ), // End Container (Background)
    ); // End Scaffold
  } // End build method
} // End _QuizScreenState