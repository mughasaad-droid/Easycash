import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home.dart';
import 'history.dart';
import 'profile.dart';
import 'transaction.dart';
import '../utils/fade_route.dart';
import '../services/database_service.dart';

class SendScreen extends StatefulWidget {
  final bool isTab;
  const SendScreen({super.key, this.isTab = false});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? selectedBank;
  final List<String> pakistaniBanks = [
    'Habib Bank Limited (HBL)',
    'United Bank Limited (UBL)',
    'Meezan Bank',
    'Bank Alfalah',
    'MCB Bank',
    'Allied Bank (ABL)',
    'Standard Chartered',
    'Bank AL Habib',
    'Faysal Bank',
    'Askari Bank',
  ];

  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a bank")));
      return;
    }
    if (_accountController.text.length != 14) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid 14-digit account number")));
      return;
    }
    if (_amountController.text.isEmpty || _amountController.text == "0") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save transaction to Firebase (Fake transaction)
      await _db.addTransaction(
        bankName: selectedBank!,
        accountNumber: _accountController.text,
        amount: _amountController.text,
        note: _noteController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.push(
          context,
          FadeRoute(
            page: TransactionScreen(
              amount: _amountController.text,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Header
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
                      'Send Money',
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
                    const SizedBox(height: 30),
                    _buildGlossyBox(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBank,
                          hint: const Text("Select Bank", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          dropdownColor: const Color(0xFF1E1E1E),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                          isExpanded: true,
                          items: pakistaniBanks.map((String bank) {
                            return DropdownMenuItem<String>(value: bank, child: Text(bank, style: const TextStyle(color: Colors.white, fontSize: 15)));
                          }).toList(),
                          onChanged: (String? newValue) => setState(() => selectedBank = newValue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGlossyBox(
                      child: TextField(
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_balance_outlined, color: Colors.white.withOpacity(0.5)),
                          hintText: "Enter 14 digit account number",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGlossyBox(
                      height: 130,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Enter Amount",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              prefixText: 'Rs ',
                              prefixStyle: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () {
                              if (_amountController.text == "0") _amountController.clear();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGlossyBox(
                      child: TextField(
                        controller: _noteController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          icon: Icon(Icons.sticky_note_2_outlined, color: Colors.white.withOpacity(0.5)),
                          hintText: "Note: Add a message",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleContinue,
                      child: Container(
                        width: double.infinity, height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE87A30), Color(0xFF9E4612)]),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: const Color(0xFFE87A30).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Center(
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(1.0, -1.0), radius: 1.5, colors: [Color(0xFF4A2A0F), Color(0xFF030110)])))),
          Positioned.fill(child: CustomPaint(painter: BackgroundLinesPainter())),
          content,
          Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 30.0, left: 30, right: 30), child: _buildBottomNavBar(context))),
        ],
      ),
    );
  }

  Widget _buildGlossyBox({required Widget child, double? height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home_filled, 'Home', false),
          _buildNavItem(context, Icons.swap_horiz, 'Send', true),
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
        if (icon == Icons.home_filled) {
          Navigator.pushReplacement(
            context,
            FadeRoute(page: HomeScreen()),
          );
        } else if (icon == Icons.access_time) {
          Navigator.pushReplacement(
            context,
            FadeRoute(page: const HistoryScreen()),
          );
        } else if (icon == Icons.person_outline) {
          Navigator.pushReplacement(
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
                  Icon(icon, color: Colors.black, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
