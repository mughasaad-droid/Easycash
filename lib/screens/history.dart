import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'send.dart';
import 'profile.dart';
import '../utils/fade_route.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  final bool isTab;
  const HistoryScreen({super.key, this.isTab = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = "Last 7 Days";
  final List<String> filters = ["Last 7 Days", "Last 1 Month", "Last 6 Months", "Last 1 Year"];
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                if (!widget.isTab)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  )
                else
                  const SizedBox(width: 48),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Transaction History',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("History", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildFilterDropdown()
                    ]),
                    const SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: _db.transactions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 30),
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              DateTime? timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                              String formattedDate = timestamp != null ? DateFormat('MMM dd, yyyy').format(timestamp) : "";
                              
                              bool isReceived = data['type'] == 'received';

                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isReceived ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05), 
                                      shape: BoxShape.circle
                                    ),
                                    child: Icon(
                                      isReceived ? Icons.call_received : Icons.swap_horiz, 
                                      color: isReceived ? Colors.greenAccent : Colors.white.withOpacity(0.5), 
                                      size: 24
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isReceived ? (data['senderName'] ?? "Received") : (data['bankName'] ?? "Sent"), 
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
                                        ),
                                        Text(formattedDate, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${isReceived ? '+' : '-'}Rs ${data['amount']}",
                                    style: TextStyle(
                                      color: isReceived ? Colors.greenAccent : Colors.redAccent, 
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isTab) return content;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(1.0, -1.0), radius: 1.5, colors: [Color(0xFF4A2A0F), Color(0x00030110)])))),
          Positioned.fill(child: CustomPaint(painter: BackgroundLinesPainter())),
          content,
          Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 30.0, left: 30, right: 30), child: _buildBottomNavBar(context))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.receipt_long_outlined, color: Colors.white.withOpacity(0.1), size: 80),
          const SizedBox(height: 20),
          const Text('Empty history', style: TextStyle(color: Colors.white30, fontSize: 16)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter, dropdownColor: const Color(0xFF1E1E1E), icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20), style: const TextStyle(color: Colors.white70, fontSize: 14),
          items: filters.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
          onChanged: (newValue) => setState(() => selectedFilter = newValue!),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildNavItem(context, Icons.home_filled, 'Home', false), _buildNavItem(context, Icons.swap_horiz, 'Send', false), _buildNavItem(context, Icons.access_time, 'History', true), _buildNavItem(context, Icons.person_outline, 'Profile', false)]),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (isActive) return;
        if (icon == Icons.home_filled) Navigator.pushReplacement(context, FadeRoute(page: HomeScreen()));
        else if (icon == Icons.swap_horiz) Navigator.pushReplacement(context, FadeRoute(page: const SendScreen()));
        else if (icon == Icons.person_outline) Navigator.pushReplacement(context, FadeRoute(page: const ProfileScreen()));
      },
      child: isActive ? Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)), child: Row(children: [Icon(icon, color: Colors.black, size: 28), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))])) : Icon(icon, color: Colors.white.withOpacity(0.4), size: 32),
    );
  }
}

class BackgroundLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.8, size.height * 0.2), width: size.width * 1.5, height: size.height * 0.8), 0, math.pi * 2, false, paint);
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.9, size.height * 0.25), width: size.width * 1.6, height: size.height * 0.9), 0, math.pi * 2, false, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
