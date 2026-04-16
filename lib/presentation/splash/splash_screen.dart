
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // Show logo AFTER rings finish & disappear
    Timer(const Duration(milliseconds: 1900), () {
      setState(() => _showLogo = true);
    });

    // Navigate to splash2
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) context.go('/splash2');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxSize = screenSize.longestSide * 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _showLogo
            ? Image.asset(
          'assets/images/splash1-logo.png',
          width: 150,
        )
            : AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final progress = _controller.value;
            final opacity = 1 - progress;

            return Opacity(
              opacity: opacity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _ring(maxSize * progress * 0.25, 3),
                  _ring(maxSize * progress * 0.45, 3),
                  _ring(maxSize * progress * 0.65, 3),
                  _ring(maxSize * progress * 0.85, 3),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _ring(double size, double strokeWidth) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFF4081),
          width: strokeWidth,
        ),
      ),
    );
  }
}

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _c1;
//   late AnimationController _c2;
//   late AnimationController _c3;
//
//   bool _showLogo = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _c1 = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1400));
//     _c2 = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1400));
//     _c3 = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1400));
//
//     _c1.forward();
//     Timer(const Duration(milliseconds: 300), () => _c2.forward());
//     Timer(const Duration(milliseconds: 600), () => _c3.forward());
//
//     // Show logo
//     Timer(const Duration(milliseconds: 2600), () {
//       setState(() => _showLogo = true);
//     });
//
//     // Navigate to splash2
//     Timer(const Duration(milliseconds: 3800), () {
//       if (mounted) context.go('/splash2');
//     });
//   }
//
//   @override
//   void dispose() {
//     _c1.dispose();
//     _c2.dispose();
//     _c3.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: _showLogo
//             ? Image.asset(
//           'assets/images/splash1-logo.png',
//           width: 150,
//         )
//             : Stack(
//           alignment: Alignment.center,
//           children: [
//             _ring(80, 4), // outer ring
//             _ring(50, 4), // inner ring
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _ring(double size, double strokeWidth) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: const Color(0xFFFF4081),
//           width: strokeWidth,
//         ),
//       ),
//     );
//   }
// }
//
//
// //   Widget _circle(AnimationController c, double y) {
// //     return Transform.translate(
// //       offset: Offset(0, y),
// //       child: AnimatedBuilder(
// //         animation: c,
// //         builder: (_, __) {
// //           final size = 20 + (c.value * 30); // stays small & visible
// //           return Container(
// //             width: size,
// //             height: size,
// //             decoration: const BoxDecoration(
// //               color: Color(0xFFFF4081),
// //               shape: BoxShape.circle,
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
//
