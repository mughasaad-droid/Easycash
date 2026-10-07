import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home.dart';
import '../utils/fade_route.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mpinController = TextEditingController();
  final TextEditingController _confirmMpinController = TextEditingController();
  
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  void _handleSignUp() async {
    if (_fullNameController.text.isEmpty ||
        _cnicController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _mpinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (_mpinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("MPIN must be exactly 4 digits")),
      );
      return;
    }

    if (_mpinController.text != _confirmMpinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("MPINs do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? result = await _auth.signUp(
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      cnic: _cnicController.text,
      mpin: _mpinController.text,
    );

    setState(() => _isLoading = false);

    if (result == null) {
      // Success
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeRoute(page: HomeScreen()),
        );
      }
    } else {
      // Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? "An error occurred")),
        );
      }
    }
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
                    Color(0xFF4A2A0F),
                    Color(0x00030110),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    Center(
                    child:  Text(
                      'Create Account',
                      style: GoogleFonts.lobster(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                    child: Text(
                      'Sign up to get started',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                    ),
                    const SizedBox(height: 50),

                    // Full Name Input
                    _buildInputField(
                      controller: _fullNameController,
                      hintText: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // CNIC Input
                    _buildInputField(
                      controller: _cnicController,
                      hintText: 'CNIC',
                      icon: Icons.credit_card_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Input
                    _buildInputField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // MPIN Input
                    _buildInputField(
                      controller: _mpinController,
                      hintText: 'Create MPIN',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Confirm MPIN Input
                    _buildInputField(
                      controller: _confirmMpinController,
                      hintText: 'Confirm MPIN',
                      icon: Icons.lock_reset,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 40),

                    // Sign Up Button (Same style as Login)
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _handleSignUp,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A2A0F).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.brown.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: _isLoading 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already have an account? Login
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                            children: const [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: Color(0xFFD96D26),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
          ),
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
