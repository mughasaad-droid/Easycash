import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'send.dart';
import 'history.dart';
import 'started.dart';
import 'change_mpin.dart';
import 'cards.dart';
import '../utils/fade_route.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationEnabled = true;
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.userData,
      builder: (context, snapshot) {
        String name = "User";
        String handle = "@user";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['fullName'] ?? "User";
          handle = "@${name.toLowerCase().replaceAll(' ', '')}";
        }

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
                          'Settings',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
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
                        const SizedBox(height: 30),
                        _buildProfileCard(name, handle),
                        const SizedBox(height: 25),
                        _buildSettingsSection(context),
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
    );
  }

  Widget _buildProfileCard(String name, String handle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        children: [
          const CircleAvatar(radius: 35, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d')),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(handle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
            ]),
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))), child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        children: [
          _buildSettingsItem(Icons.lock_outline, 'Change Password', hasArrow: true, onTap: () {
            Navigator.push(context, FadeRoute(page: const ChangeMpinScreen()));
          }),
          _buildSettingsItem(Icons.credit_card_outlined, 'Manage Virtual Cards', hasArrow: true, onTap: () {
            Navigator.push(context, FadeRoute(page: const CardsScreen()));
          }),
          _buildSettingsItem(Icons.notifications_none, 'Notifications', trailing: Switch(value: isNotificationEnabled, onChanged: (val) => setState(() => isNotificationEnabled = val), activeColor: Colors.deepOrange, inactiveThumbColor: Colors.white70, inactiveTrackColor: Colors.white10)),
          _buildSettingsItem(Icons.person_remove_outlined, 'Close Account', hasArrow: true, onTap: () {
            _showCloseAccountDialog(context);
          }),
          _buildSettingsItem(Icons.logout, 'Logout', hasArrow: true, onTap: () async {
            await _auth.signOut();
            if (mounted) {
              Navigator.pushAndRemoveUntil(context, FadeRoute(page: const StartedScreen()), (route) => false);
            }
          }),
        ],
      ),
    );
  }

  void _showCloseAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Close Account", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to close your account? This action will permanently delete all your data and cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                String? result = await _auth.deleteAccount();
                if (result == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account closed successfully.")),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      FadeRoute(page: const StartedScreen()),
                      (route) => false,
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $result")),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {bool hasArrow = false, Widget? trailing, bool isLast = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 22)),
                const SizedBox(width: 15),
                Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
                if (hasArrow) Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 16),
                if (trailing != null) trailing,
              ],
            ),
          ),
          if (!isLast) Padding(padding: const EdgeInsets.only(left: 65), child: Divider(color: Colors.white.withOpacity(0.05), height: 1)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80, decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildNavItem(context, Icons.home_filled, 'Home', false), _buildNavItem(context, Icons.swap_horiz, 'Send', false), _buildNavItem(context, Icons.access_time, 'History', false), _buildNavItem(context, Icons.person_outline, 'Profile', true)]),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (isActive) return;
        if (icon == Icons.home_filled) Navigator.pushReplacement(context, FadeRoute(page: HomeScreen()));
        else if (icon == Icons.swap_horiz) Navigator.pushReplacement(context, FadeRoute(page: const SendScreen()));
        else if (icon == Icons.access_time) Navigator.pushReplacement(context, FadeRoute(page: const HistoryScreen()));
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
