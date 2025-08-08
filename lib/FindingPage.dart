import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
// Assuming FoundedPage.dart is in the same directory or correctly imported
import 'package:optiripetablet/FoundedPage.dart'; // Adjust path if necessary

class FindingPage extends StatefulWidget {
  const FindingPage({super.key});

  @override
  State<FindingPage> createState() => _FindingPageState();
}

class _FindingPageState extends State<FindingPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  bool _navigated = false;

  // ===== CUSTOMIZATION SECTION =====
  final int dotCount = 4;
  final double bounceHeight = -15.0;
  final Duration animationDuration = const Duration(milliseconds: 1400);
  final double dotSize = 16;
  final double dotSpacing = 4;
  final Color dotColor = Color(0xFFFFF7CD); // Changed for contrast with new background
  // ===== END OF CUSTOMIZATION =====

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: animationDuration,
      vsync: this,
    )..repeat();

    _animations = _buildDotAnimations(dotCount);

    // Start scanning once
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // Listen for scan results
    FlutterBluePlus.onScanResults.listen((scanResults) {
      for (var result in scanResults) {
        // Check if the device name contains "OptiripeMain" and we haven't navigated yet
        if (!_navigated && result.advertisementData.advName.contains("OptiripeBelt")) {
          _navigated = true; // Set flag to true to prevent multiple navigations
          FlutterBluePlus.stopScan(); // Stop scanning once found
          if (mounted) {
            // Navigate to FoundedPage, replacing the current route
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Foundedpage(scanResult: result),
              ),
            );
          }
          break; // Exit loop after finding the device
        }
      }
    });
  }

  // Builds a list of animations for each bouncing dot
  List<Animation<double>> _buildDotAnimations(int count) {
    return List.generate(count, (index) {
      final start = index * 0.1; // Stagger the start of each dot's animation
      final end = start + 0.6; // Duration of the bounce within the full animation cycle

      return TweenSequence<double>([
        // Move up
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: bounceHeight).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50, // Half of the animation duration
        ),
        // Move down
        TweenSequenceItem(
          tween: Tween(begin: bounceHeight, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50, // Other half of the animation duration
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.linear), // Define the interval for this dot
        ),
      );
    });
  }

  // Builds a single bouncing dot widget
  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value), // Apply the animated vertical offset
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: dotSpacing),
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: dotColor, // Dot color from customization
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Builds the row of bouncing dots
  Widget _buildBouncingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min, // Wrap content tightly
      children: _animations.map(_buildDot).toList(), // Map each animation to a dot widget
    );
  }

  // Builds the "Finding Optiripe" text with styled parts
  Widget _buildLoadingText() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Finding ',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFF7CD), // Changed to white for contrast
            ),
          ),
          TextSpan(
            text: 'Optiripe',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFF7CD), // Original color, still good contrast
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F6857), // Background color from your new code
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBouncingDots(), // Display the bouncing dots animation
            const SizedBox(height: 32), // Spacing between dots and text
            _buildLoadingText(), // Display the "Finding Optiripe" text
          ],
        ),
      ),
    );
  }
}