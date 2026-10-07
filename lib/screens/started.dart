import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login.dart';
import '../utils/fade_route.dart';

class StartedScreen extends StatefulWidget {
  const StartedScreen({super.key});

  @override
  State<StartedScreen> createState() => _StartedScreenState();
}

class _StartedScreenState extends State<StartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Shine effect animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.0, -1.0),
                  radius: 1.5,
                  colors: [
                    Color(0xFF4A2A0F), // Dark Brown/Orange
                    Color(0xFF030110),
                  ],
                ),
              ),
            ),
          ),

          // 2. Background Curved Lines (Custom Painter)
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundLinesPainter(),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Rotated Card Image with Shine Effect
                Expanded(
                  child: Center(
                    child: Transform.rotate(
                      angle: -math.pi / 8, // Approx -22.5 degrees
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(10, 20),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [
                                    _controller.value - 0.4,
                                    _controller.value,
                                    _controller.value + 0.4,
                                  ],
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0),
                                  ],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.srcATop,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/images/card.png',
                            width: MediaQuery.of(context).size.width * 0.70,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 300,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade800,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Card Image Missing',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Text Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      const Text(
                        'Top-Up & Manage\nYour Wallet Seamlessly',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Top up your wallet instantly and manage your funds with ease.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Get Started Button (Transparent/Glass effect)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const LoginScreen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0); // Start from bottom
                                const end = Offset.zero; // End at center
                                const curve = Curves.easeInOutQuart;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A2A0F).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.brown.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the background curves
class BackgroundLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.8, size.height * 0.2),
        width: size.width * 1.5,
        height: size.height * 0.8,
      ),
      0,
      math.pi * 2,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.9, size.height * 0.25),
        width: size.width * 1.6,
        height: size.height * 0.9,
      ),
      0,
      math.pi * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
