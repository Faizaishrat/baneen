import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class Splash2Screen extends StatefulWidget {
  const Splash2Screen({super.key});

  @override
  State<Splash2Screen> createState() => _Splash2ScreenState();
}

class _Splash2ScreenState extends State<Splash2Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _upperImageSlide;
  late Animation<Offset> _lowerImageSlide;

  String _displayedText = '';
  String _fullText = 'BANEEN\nFor women, By women';
  int _currentLetterIndex = 0;
  Timer? _letterAnimationTimer;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _upperImageSlide = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _lowerImageSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();

    // Start letter animation after images slide in
    Future.delayed(const Duration(seconds: 2), _startLetterAnimation);

    // Navigate to login after 5 more seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  void _startLetterAnimation() {
    _letterAnimationTimer?.cancel();
    _currentLetterIndex = 0;
    _displayedText = '';
    _animateNextLetter();
  }

  void _animateNextLetter() {
    if (!mounted || _currentLetterIndex >= _fullText.length) return;

    setState(() {
      _displayedText += _fullText[_currentLetterIndex];
      _currentLetterIndex++;
    });

    if (_currentLetterIndex < _fullText.length) {
      _letterAnimationTimer = Timer(const Duration(milliseconds: 80), _animateNextLetter);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _letterAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> lines = _displayedText.split('\n');

    return Scaffold(
      body: Stack(
        children: [
          // Upper image slides from right
          SlideTransition(
            position: _upperImageSlide,
            child: Align(
              alignment: Alignment.topRight,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 0.5,
                child: Image.asset(
                  'assets/images/car.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Lower image slides from left
          SlideTransition(
            position: _lowerImageSlide,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 0.5,
                child: Image.asset(
                  'assets/images/bike.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Centered text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: lines
                  .map(
                    (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: line == 'BANEEN' ? 44 : 26, // BANEEN bigger
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor, // pink
                      letterSpacing: 1,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                        )
                      ],
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
