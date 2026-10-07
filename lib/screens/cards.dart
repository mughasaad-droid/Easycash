import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _shineController;
  bool _isFront = true;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.userData,
      builder: (context, snapshot) {
        String userName = "User";
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['fullName'] ?? "User";
        }

        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Background Gradient
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(1.0, -1.0),
                    radius: 1.5,
                    colors: [
                      Color(0xFF4A2A0F),
                      Color(0xFF030110),
                    ],
                  ),
                ),
              ),

              // Background Curved Lines
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundLinesPainter(),
                ),
              ),

              // Content
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Virtual Cards',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Flipping Card with Shine
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 220,
                          child: GestureDetector(
                            onTap: _toggleCard,
                            child: AnimatedBuilder(
                              animation: _flipController,
                              builder: (context, child) {
                                double angle = _flipController.value * math.pi;
                                bool isBackVisible = angle > math.pi / 2;

                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001) // Perspective
                                    ..rotateY(angle),
                                  alignment: Alignment.center,
                                  child: isBackVisible
                                      ? Transform(
                                          transform: Matrix4.identity()..rotateY(math.pi),
                                          alignment: Alignment.center,
                                          child: _buildCardImage('assets/images/swap2.png'),
                                        )
                                      : _buildCardImage('assets/images/swap.png'),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      const Text(
                        "Tap to flip card",
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                      ),

                      const SizedBox(height: 40),

                      // Card Details Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildDetailsBox(userName),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildDetailsBox(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Card Details",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          
          _buildDetailRow("Account Number", "4421 8892 0123 45", isWhite: true),
          const SizedBox(height: 15),
          _buildDetailRow("Card Holder", name),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildDetailRow("Expiry", "12/28")),
              Expanded(child: _buildDetailRow("CVV", "551")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWhite = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isWhite ? Colors.white : Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: label == "Account Number" ? 1.5 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildCardImage(String assetPath) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _shineController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    _shineController.value - 0.4,
                    _shineController.value,
                    _shineController.value + 0.4,
                  ],
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0),
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: Image.asset(
                assetPath,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                      child: Text("Image Missing",
                          style: TextStyle(color: Colors.white24))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BackgroundLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.8, size.height * 0.2), width: size.width * 1.5, height: size.height * 0.8), 0, math.pi * 2, false, paint);
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.9, size.height * 0.25), width: size.width * 1.6, height: size.height * 0.9), 0, math.pi * 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
