import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Keep for potential future optimization
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the next screen
import 'package:ddcet_preparation/Welcome.dart'; // **** VERIFY THIS PATH ****

// --- Professional & Polished Splash Configuration ---

// Durations - Balanced for Smooth Pacing
const Duration _kTotalAnimationDuration = Duration(milliseconds: 8500); // Slightly shorter master animation
const Duration _kSplashDisplayTime = Duration(seconds: 10);         // Total time on screen
const Duration _kBackgroundFadeInDuration = Duration(milliseconds: 2500);
const Duration _kLogoAppearDuration = Duration(milliseconds: 3500);
const Duration _kTitleAppearDuration = Duration(milliseconds: 2500); // Adjusted title timing
const Duration _kSubtitleAppearDuration = Duration(milliseconds: 1500);
const Duration _kFinalSettleDuration = Duration(milliseconds: 600);
const Duration _kShimmerDuration = Duration(milliseconds: 2000);

// Content
const String _kAppTitle = 'DDCET Preparation';
const String _kAppSubtitle = 'Your Gateway to Success';
const String _kLogoAssetPath = 'assets/Logo.png'; // **** FINAL, FINAL CHECK ****

// Styling (Professional Dark Theme)
const Color _kBackgroundColorStart = Color(0xFF101025); // Slightly less purple navy
const Color _kBackgroundColorEnd = Color(0xFF050510);   // Very dark grey/blue
const Color _kBackgroundColor = Color(0xFF08081A);     // Fallback Dark
const Color _kLogoGlowColor = Color(0x99FFFFFF);   // Slightly softer white glow
const Color _kForegroundColor = Color(0xFFECEFF1); // Clean Off-white (like Material Blue Grey 50)
const Color _kSubtitleColor = Color(0xFFB0BEC5);   // Lighter Subtitle (like Material Blue Grey 300)
const Color _kShimmerHighlightColor = Color(0xCCFFFFFF);

// Text Styles (Professional & Readable)
final TextStyle _kTitleTextStyle = GoogleFonts.poppins(
    fontSize: 42, // Slightly reduced for better balance
    fontWeight: FontWeight.w600,
    color: _kForegroundColor,
    height: 1.18, // Increased slightly for readability
    shadows: const [
      Shadow( offset: Offset(0, 1), blurRadius: 4.0, color: Color(0x33000000)), // Softer shadow
    ]
);

final TextStyle _kSubtitleTextStyle = GoogleFonts.poppins(
  fontSize: 17, // Slightly reduced
  fontWeight: FontWeight.w400,
  color: _kSubtitleColor,
  fontStyle: FontStyle.normal, // Standard style, less emphasis than italic
  letterSpacing: 0.5,
);

// Animation Curves (Smooth & Refined)
const Curve _kBackgroundFadeCurve = Curves.easeIn;
const Curve _kLogoEmergeScaleCurve = Curves.easeOutQuart; // Very smooth scale out
const Curve _kLogoEmergeOpacityCurve = Curves.easeOutCubic;
const Curve _kLogoSettleRotateCurve = Curves.easeOutBack; // Subtle overshoot on settle
const Curve _kTitleSlideCurve = Curves.easeOutCubic;
const Curve _kTextSpacingCurve = Curves.easeInOutCubic;
const Curve _kSubtitleCurve = Curves.easeOutCubic;
const Curve _kSettleCurve = Curves.easeOutSine; // Gentle settle

// Layout & Effects
const double _kLogoSize = 140.0; // Slightly smaller for more space
const double _kVerticalSpacing = 40.0;
const double _kTitleSubtitleSpacing = 14.0; // Slightly tighter
const bool _kEnableHaptics = true;

// ================================================================
// Asset Setup - Check Path & pubspec.yaml one last time!
// ================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _masterController;
  late AnimationController _backgroundController;
  late AnimationController _shimmerController;

  // --- Animations ---
  // Background
  late Animation<double> _backgroundFade;
  late Animation<Alignment> _gradientAlignment;
  // Logo
  late Animation<double> _logoGlowOpacity;
  late Animation<double> _logoGlowScale;
  late Animation<double> _logoImageScale;
  late Animation<double> _logoImageOpacity;
  late Animation<double> _logoRotateY; // Rotation during emerge/settle
  late Animation<double> _contentSettleScale; // Final settle for the whole column

  // Title
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleLetterSpacing;
  // Subtitle
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;

  // State
  bool _isLogoPrecached = false;
  bool _animationsCanStart = false;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    // Ensure status bar icons are light for dark theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));
    _hideSystemUI(); // Hide during animation

    // Initialize Controllers
    _masterController = AnimationController(duration: _kTotalAnimationDuration, vsync: this);
    _backgroundController = AnimationController(duration: const Duration(seconds: 18), vsync: this)..repeat(reverse: true); // Slower bg loop
    _shimmerController = AnimationController(duration: _kShimmerDuration, vsync: this)..repeat();

    // --- Define Animations based on Master Controller ---
    // Calculate ratios from durations
    final double bgFadeEndRatio = _kBackgroundFadeInDuration.inMilliseconds / _kTotalAnimationDuration.inMilliseconds;
    final double logoAppearDurationRatio = _kLogoAppearDuration.inMilliseconds / _kTotalAnimationDuration.inMilliseconds;
    final double titleAppearDurationRatio = _kTitleAppearDuration.inMilliseconds / _kTotalAnimationDuration.inMilliseconds;
    final double subtitleAppearDurationRatio = _kSubtitleAppearDuration.inMilliseconds / _kTotalAnimationDuration.inMilliseconds;
    final double finalSettleDurationRatio = _kFinalSettleDuration.inMilliseconds / _kTotalAnimationDuration.inMilliseconds;

    // Phase 1: Background
    _backgroundFade = CurvedAnimation(parent: _masterController, curve: Interval(0.0, bgFadeEndRatio, curve: _kBackgroundFadeCurve));
    _gradientAlignment = Tween<Alignment>( begin: Alignment.topLeft, end: Alignment.bottomRight, ).animate(_backgroundController);

    // Phase 2: Logo Emergence & Settle
    const double logoStartRatio = 0.10; // Start a bit earlier
    final double logoMidRatio = logoStartRatio + (logoAppearDurationRatio * 0.5);
    final double logoEndRatio = logoStartRatio + logoAppearDurationRatio;

    _logoGlowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 65),
    ]).animate(CurvedAnimation(parent: _masterController, curve: Interval(logoStartRatio, logoMidRatio + 0.1, curve: Curves.easeInOut)));
    _logoGlowScale = Tween<double>(begin: 0.4, end: 1.2).animate(
        CurvedAnimation(parent: _masterController, curve: Interval(logoStartRatio, logoMidRatio, curve: Curves.easeOut))
    );

    final logoImageStartRatio = logoStartRatio + 0.15;
    _logoImageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: Interval(logoImageStartRatio, logoEndRatio, curve: _kLogoEmergeOpacityCurve))
    );
    _logoImageScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _masterController, curve: Interval(logoImageStartRatio, logoEndRatio, curve: _kLogoEmergeScaleCurve))
    );
    // Simple 3D Tilt that settles
    _logoRotateY = Tween<double>(begin: math.pi / 8, end: 0.0).animate( // Less initial tilt
        CurvedAnimation(parent: _masterController, curve: Interval(logoImageStartRatio, logoEndRatio + 0.05, curve: _kLogoSettleRotateCurve)) // Settle slightly after scaling
    );

    // Phase 3: Title Appearance
    final titleStartRatio = logoEndRatio - 0.1; // Start as logo nears end of scaling
    final titleEndRatio = titleStartRatio + titleAppearDurationRatio;
    _titleOpacity = CurvedAnimation(parent: _masterController, curve: Interval(titleStartRatio.clamp(0.0,1.0), titleEndRatio.clamp(0.0,1.0), curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0.0, 15.0), end: Offset.zero).animate( // Slightly less slide
        CurvedAnimation(parent: _masterController, curve: Interval(titleStartRatio.clamp(0.0,1.0), titleEndRatio.clamp(0.0,1.0), curve: _kTitleSlideCurve))
    );
    _titleLetterSpacing = Tween<double>(begin: 5.0, end: 1.2).animate( // Less initial spacing
        CurvedAnimation(parent: _masterController, curve: Interval(titleStartRatio.clamp(0.0,1.0), (titleEndRatio + 0.05).clamp(0.0, 1.0), curve: _kTextSpacingCurve))
    );

    // Phase 4: Subtitle Appearance
    final subtitleStartRatio = titleEndRatio - 0.2; // Start earlier, overlapping title more
    final subtitleEndRatio = subtitleStartRatio + subtitleAppearDurationRatio;
    _subtitleOpacity = CurvedAnimation(parent: _masterController, curve: Interval(subtitleStartRatio.clamp(0.0,1.0), subtitleEndRatio.clamp(0.0, 1.0), curve: _kSubtitleCurve));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0.0, 15.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _masterController, curve: Interval(subtitleStartRatio.clamp(0.0,1.0), subtitleEndRatio.clamp(0.0, 1.0), curve: _kSubtitleCurve))
    );

    // Phase 5: Final Settle (Scale down slightly)
    final settleStartRatio = (1.0 - finalSettleDurationRatio).clamp(0.0, 1.0);
    _contentSettleScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 85), // Stay normal longer
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.99), weight: 10), // Quick scale down
      TweenSequenceItem(tween: Tween(begin: 0.99, end: 1.0), weight: 5), // Settle back smoothly
    ]).animate(CurvedAnimation(parent: _masterController, curve: Interval(settleStartRatio, 1.0, curve: _kSettleCurve)));


    // Trigger Haptics on Settle Completion
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && _kEnableHaptics) { HapticFeedback.lightImpact(); }
        _startNavigationTimer();
      }
    });

    // --- Precache & Start ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentContext = context;
        // Additional check for render object validity
        if (currentContext.findRenderObject() != null && currentContext.mounted) {
          setState(() { _screenSize = MediaQuery.of(currentContext).size; });
          _precacheAndStart();
        } else { print("Splash Screen: Context invalid during PostFrameCallback"); }
      }
    });
  }

  Future<void> _precacheAndStart() async {
    // (Precache logic - same as before)
    if (!mounted || _screenSize == Size.zero) return;
    final currentContext = context;
    if (!currentContext.mounted) return;
    try {
      await precacheImage(AssetImage(_kLogoAssetPath), currentContext);
      if (!mounted) return;
      setState(() { _isLogoPrecached = true; _animationsCanStart = true; });
      print("Splash Logo precached successfully.");
      _masterController.forward();
    } catch (e) {
      print("Error precaching splash logo: $e");
      if (!mounted) return;
      setState(() { _isLogoPrecached = true; _animationsCanStart = true; });
      _masterController.forward();
    }
  }

  void _startNavigationTimer() {
    // (Navigation timer logic - same as before)
    final timeAfterAnimation = _kSplashDisplayTime - _kTotalAnimationDuration;
    final navigationDelay = timeAfterAnimation > Duration.zero ? timeAfterAnimation : const Duration(milliseconds: 300); // Slightly longer hold
    Timer(navigationDelay, _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    // (Navigation logic - same as before)
    if (mounted) {
      _showSystemUI();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const Welcome(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000), // Clean fade duration
        ),
      );
    }
  }

  void _hideSystemUI() { SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); }
  void _showSystemUI() { if (mounted) SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light); }

  @override
  void dispose() {
    _masterController.dispose();
    _backgroundController.dispose();
    _shimmerController.dispose();
    _showSystemUI();
    super.dispose();
  }

  // Helper for Text Shimmer Shader
  Shader _buildShimmerShader(Rect bounds) {
    // (Shimmer shader logic - same as before)
    if (bounds.width <= 0 || bounds.height <= 0) {
      return const LinearGradient(colors: [Colors.transparent, Colors.transparent]).createShader(bounds);
    }
    return LinearGradient(
      colors: [ Colors.transparent, _kShimmerHighlightColor.withOpacity(0.9), Colors.transparent], // Slightly more opaque shimmer
      stops: const [0.3, 0.5, 0.7],
      begin: Alignment(-2.0 + _shimmerController.value * 4, 0.0), // Adjust speed/travel if needed
      end: Alignment(-1.0 + _shimmerController.value * 4, 0.0),
      tileMode: TileMode.clamp,
    ).createShader(bounds);
  }


  @override
  Widget build(BuildContext context) {
    if (_screenSize == Size.zero) {
      return const Scaffold(backgroundColor: _kBackgroundColor);
    }

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: Stack(
        children: [
          // --- Phase 1: Animated Background ---
          AnimatedBuilder(
            animation: Listenable.merge([_backgroundFade, _gradientAlignment]),
            builder: (context, child) {
              return Opacity(
                opacity: _backgroundFade.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [_kBackgroundColorStart, _kBackgroundColorEnd],
                      begin: _gradientAlignment.value,
                      end: Alignment(-_gradientAlignment.value.x, -_gradientAlignment.value.y),
                    ),
                  ),
                ),
              );
            },
          ),

          // --- Main Content ---
          SafeArea(
            child: Center(
              // Apply the final subtle settle scale to the entire content column
              child: AnimatedBuilder(
                animation: _contentSettleScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _contentSettleScale.value,
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // --- Phase 2: Logo Emergence ---
                    SizedBox(
                      width: _kLogoSize * 1.3, height: _kLogoSize * 1.3,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Initial Glow Pulsing
                          AnimatedBuilder(
                              animation: Listenable.merge([_logoGlowOpacity, _logoGlowScale]),
                              builder: (context, child){
                                return Transform.scale(
                                  scale: _logoGlowScale.value,
                                  child: Opacity(
                                    opacity: _logoGlowOpacity.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _kLogoGlowColor.withOpacity(0.4), // Softer base glow
                                        boxShadow: [ BoxShadow( color: _kLogoGlowColor, blurRadius: 60.0, spreadRadius: 6.0,) ], // Wider, softer shadow
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                          // Actual Logo Image (with 3D Tilt)
                          if (_isLogoPrecached && _animationsCanStart)
                            AnimatedBuilder(
                              animation: Listenable.merge([_logoImageScale, _logoImageOpacity, _logoRotateY]),
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(_logoRotateY.value), // Apply Y rotation
                                  child: Transform.scale(
                                    scale: _logoImageScale.value,
                                    child: Opacity(
                                        opacity: _logoImageOpacity.value,
                                        child: child
                                    ),
                                  ),
                                );
                              },
                              child: Image.asset(
                                _kLogoAssetPath,
                                width: _kLogoSize, height: _kLogoSize,
                                fit: BoxFit.contain, semanticLabel: '$_kAppTitle Logo',
                                errorBuilder: (ctx, err, st) => Icon(Icons.error_outline, size: _kLogoSize * 0.7, color: _kSubtitleColor.withOpacity(0.6)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: _kVerticalSpacing),

                    // --- Phase 3: Title Appearance ---
                    AnimatedBuilder(
                      animation: Listenable.merge([_titleOpacity, _titleSlide, _titleLetterSpacing, _shimmerController]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _titleOpacity,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: ShaderMask( // Apply shimmer
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (bounds) => _buildShimmerShader(bounds),
                              child: Text(
                                _kAppTitle,
                                style: _kTitleTextStyle.copyWith(letterSpacing: _titleLetterSpacing.value),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: _kTitleSubtitleSpacing),

                    // --- Phase 4: Subtitle Appearance ---
                    AnimatedBuilder(
                      animation: Listenable.merge([_subtitleOpacity, _subtitleSlide]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _subtitleOpacity,
                          child: SlideTransition(
                            position: _subtitleSlide,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _kAppSubtitle,
                        style: _kSubtitleTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
