import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import '../utils/fade_route.dart';

class TransactionScreen extends StatelessWidget {
  final String amount;
  const TransactionScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    String transactionId = "ID-${math.Random().nextInt(1000000).toString().padLeft(6, '0')}";
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now());

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
                    Color(0xFF4A2A0F),
                    Color(0xFF030110),
                  ],
                ),
              ),
            ),
          ),

          // 2. Background Curved Lines
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundLinesPainter(),
            ),
          ),

          // 3. Content
          SafeArea(
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
                            'Payment Successful',
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

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          
                          // Success Icon with circular pattern
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Dot pattern
                                CustomPaint(
                                  size: const Size(220, 220),
                                  painter: SuccessPatternPainter(),
                                ),
                                // Checkmark Circle
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3.0),
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 65),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          const Text(
                            "Transfer money Successfully",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Rs $amount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Transaction Details Box
                          _buildDetailsBox(
                            amount: amount,
                            transactionId: transactionId,
                            dateTime: formattedDate,
                          ),

                          const SizedBox(height: 40),

                          // Done Button
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                FadeRoute(page:  HomeScreen()),
                                (route) => false,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE87A30), Color(0xFF9E4612)],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE87A30).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Done',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsBox({
    required String amount,
    required String transactionId,
    required String dateTime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Profile & Name Row
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Saad",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "- Rs $amount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          
          // Transaction ID Row
          _buildDetailRow("Transaction ID", transactionId),
          const SizedBox(height: 15),
          
          // Date Row
          _buildDetailRow("Date", dateTime),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

class SuccessPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2.2;
    const int dotCount = 12;

    for (int i = 0; i < dotCount; i++) {
      final double angle = (i * 360 / dotCount) * (math.pi / 180);
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }

    final double innerRadius = radius * 0.7;
    for (int i = 0; i < dotCount; i++) {
      final double angle = (i * 360 / dotCount + 15) * (math.pi / 180);
      final double x = centerX + innerRadius * math.cos(angle);
      final double y = centerY + innerRadius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
