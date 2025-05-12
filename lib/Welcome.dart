import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Ensure this import points to your actual HomePage file
import 'Home Page.dart'; // Or 'ddcet_home_page.dart' if you renamed it

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Define consistent colors (matching HomePage/QuizPage)
    const Color primaryColor = Colors.indigo; // Or Colors.deepPurpleAccent
    final Color lightBackgroundColor = Colors.indigo.shade50;
    final Color secondaryTextColor = Colors.grey.shade700;

    return Scaffold(
      // Use a subtle gradient or light background consistent with other pages
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBackgroundColor, Colors.white], // Subtle gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main content area that scrolls if needed
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28), // Slightly more padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30), // Space from top safe area

                      // App Title
                      Text(
                        "DDCET Preparation",
                        style: GoogleFonts.poppins( // Use Poppins
                          fontSize: 30, // Slightly larger
                          fontWeight: FontWeight.w600, // Bold
                          color: primaryColor, // Use primary color
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),

                      // Subtitle / Tagline
                      Text(
                        "Practice MCQs. Boost Confidence.\nCrack DDCET!", // Added newline for better centering
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: secondaryTextColor, // Consistent secondary text color
                          height: 1.4, // Line spacing
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40), // More space before image

                      // Welcome Image
                      // **IMPORTANT:** Make sure you have an image at 'assets/Welcome.png'
                      // and have declared the 'assets/' folder in your pubspec.yaml
                      Image.asset(
                        "assets/Welcome.png", // Verify this path
                        height: size.height * 0.40, // Adjust size as needed
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Basic fallback if image fails to load
                          return Container(
                            height: size.height * 0.30,
                            color: Colors.grey.shade200,
                            child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 50)),
                          );
                        },
                      ),
                      const SizedBox(height: 35), // More space after image

                      // Description Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0), // Indent description slightly
                        child: Text(
                          'Access 5000+ MCQs, chapter-wise practice, mock tests, and PYQs – everything you need for DDCET success.', // Slightly rephrased for conciseness
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade800, // Slightly darker grey
                            height: 1.5, // Improve readability
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 50), // Significant space before button

                      // Start Button
                      SizedBox(
                        width: double.infinity, // Make button stretch
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to the main Home Page
                            Navigator.pushReplacement( // Use pushReplacement so user can't go back to Welcome
                              context,
                              MaterialPageRoute(builder: (context) => const DDCETHomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 4, // Subtle shadow
                            backgroundColor: primaryColor, // Consistent button color
                            foregroundColor: Colors.white, // White text
                            padding: const EdgeInsets.symmetric(vertical: 16), // Consistent padding
                            shape: RoundedRectangleBorder(
                              // Consistent rounded corners
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Start Practicing',
                            style: GoogleFonts.poppins( // Use Poppins
                              fontSize: 17, // Slightly larger button text
                              fontWeight: FontWeight.w600, // Bolder button text
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40), // Space at the bottom of scroll view
                    ],
                  ),
                ),
              ),

              // Footer Text (pinned to bottom)
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 5), // Adjust padding
                child: Text(
                  'Developed by Hitesh Parmar', // Your name
                  style: GoogleFonts.poppins( // Use Poppins
                    fontSize: 13, // Smaller footer text
                    color: Colors.grey.shade600, // Muted grey
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