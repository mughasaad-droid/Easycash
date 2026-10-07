import 'dart:math' as math;
import 'package:easycash/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup.dart';
import '../utils/fade_route.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mpinController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _mpinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone and MPIN")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    String? result = await _auth.login(
      phoneNumber: _phoneController.text,
      mpin: _mpinController.text,
    );

    setState(() => _isLoading = false);

    if (result == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeRoute(page: HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Color(0x00030110),
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'Welcome Back',
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
                        'Please login to continue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    _buildInputField(
                      controller: _phoneController,
                      hintText: 'Enter your number',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _mpinController,
                      hintText: 'Enter your MPIN',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 80),

                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _handleLogin,
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
                                  'Login',
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

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeRoute(page: const SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                            children: const [
                              TextSpan(
                                text: 'Sign Up',
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
