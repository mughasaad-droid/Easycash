import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'send.dart';
import 'history.dart';
import 'profile.dart';
import 'cards.dart';
import '../utils/fade_route.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  final bool isTab;
  HomeScreen({super.key, this.isTab = false});

  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.userData,
      builder: (context, snapshot) {
        String name = "User";
        String balance = "0.00";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['fullName'] ?? "User";
          balance = (data['balance'] ?? 0.0).toStringAsFixed(2);
        }

        Widget content = SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(context, name),
                  const SizedBox(height: 30),
                  _buildMainCard(context, balance),
                  const SizedBox(height: 25),
                  _buildRecentSection(),
                  const SizedBox(height: 25),
                  _buildTransactionHistorySection(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        );

        if (isTab) return content;

        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: Stack(
            children: [
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
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundLinesPainter(),
                ),
              ),
              content,
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0, left: 30, right: 30),
                  child: _buildBottomNavBar(context),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              FadeRoute(page: const ProfileScreen()),
            );
          },
          child: const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $name,',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Welcome Back!',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, String balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF9E4612),
            Colors.deepOrangeAccent,
          ],
        ),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs $balance',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardAction(Icons.add, 'Add Money', () {}),
              _buildCardAction(Icons.swap_horiz, 'Send', () {
                Navigator.push(
                  context,
                  FadeRoute(page: const SendScreen()),
                );
              }),
              _buildCardAction(Icons.credit_card, 'Cards', () {
                Navigator.push(
                  context,
                  FadeRoute(page: const CardsScreen()),
                );
              }),
              _buildCardAction(Icons.history, 'Transactions', () {
                Navigator.push(
                  context,
                  FadeRoute(page: const HistoryScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'See All',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'No recent activities',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistorySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Transaction history',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.info_outline, color: Colors.white.withOpacity(0.3), size: 18),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, FadeRoute(page: const HistoryScreen())),
                child: Text(
                  'See All',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _db.transactions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  'Empty history',
                  style: TextStyle(color: Colors.white30, fontSize: 14),
                );
              }

              // Show only top 4 recent transactions on Home
              var docs = snapshot.data!.docs.take(4).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  DateTime? timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                  String formattedDate = timestamp != null ? DateFormat('MMM dd').format(timestamp) : "";
                  bool isReceived = data['type'] == 'received';

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isReceived ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle
                        ),
                        child: Icon(
                          isReceived ? Icons.call_received : Icons.swap_horiz,
                          color: isReceived ? Colors.greenAccent : Colors.white.withOpacity(0.4),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isReceived ? (data['senderName'] ?? "Received") : (data['bankName'] ?? "Sent"),
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Text(formattedDate, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        "${isReceived ? '+' : '-'}Rs ${data['amount']}",
                        style: TextStyle(
                          color: isReceived ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home_filled, 'Home', true),
          _buildNavItem(context, Icons.swap_horiz, 'Send', false), 
          _buildNavItem(context, Icons.access_time, 'History', false),
          _buildNavItem(context, Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (isActive) return;
        if (icon == Icons.swap_horiz) {
          Navigator.push(
            context,
            FadeRoute(page: const SendScreen()),
          );
        } else if (icon == Icons.access_time) {
          Navigator.push(
            context,
            FadeRoute(page: const HistoryScreen()),
          );
        }
        else if (icon == Icons.person_outline) {
          Navigator.push(
            context,
            FadeRoute(page: const ProfileScreen()),
          );
        }
      },
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.black, size: 28), // Increased size
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            )
          : Icon(icon, color: Colors.white.withOpacity(0.4), size: 32),
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
