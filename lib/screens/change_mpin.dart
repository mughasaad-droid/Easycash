import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/fade_route.dart';
import 'login.dart';

class ChangeMpinScreen extends StatefulWidget {
  const ChangeMpinScreen({super.key});

  @override
  State<ChangeMpinScreen> createState() => _ChangeMpinScreenState();
}

class _ChangeMpinScreenState extends State<ChangeMpinScreen> {
  final TextEditingController _oldMpinController = TextEditingController();
  final TextEditingController _newMpinController = TextEditingController();
  final TextEditingController _confirmMpinController = TextEditingController();
  
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  void _handleChangeMpin() async {
    if (_oldMpinController.text.length != 4 || 
        _newMpinController.text.length != 4 || 
        _confirmMpinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All MPINs must be 4 digits")),
      );
      return;
    }

    if (_newMpinController.text != _confirmMpinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New MPINs do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? result = await _auth.changeMpin(
      oldMpin: _oldMpinController.text,
      newMpin: _newMpinController.text,
    );

    setState(() => _isLoading = false);

    if (result == null) {
      // Sign out the user so they have to login with new MPIN
      await _auth.signOut();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("MPIN changed! Please login with your new MPIN.")),
        );
        
        // Navigate to Login Screen and clear stack
        Navigator.pushAndRemoveUntil(
          context,
          FadeRoute(page: const LoginScreen()),
          (route) => false,
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

          // Content
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
                    const Center(
                      child: Text(
                        'Change MPIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Update your security pin',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    _buildInputField(
                      controller: _oldMpinController,
                      hintText: 'Current 4-Digit MPIN',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _newMpinController,
                      hintText: 'New 4-Digit MPIN',
                      icon: Icons.lock_reset,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _confirmMpinController,
                      hintText: 'Confirm New MPIN',
                      icon: Icons.lock_reset,
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 60),

                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _handleChangeMpin,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 55,
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
                                  'Update MPIN',
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
  }) {
    return Center(
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
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
      ),
    );
  }
}
