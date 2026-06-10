import 'package:flutter/material.dart';
import 'signup_page.dart';
import '../services/auth_service.dart';
import 'reset_password.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginEmail = TextEditingController();
  final loginPwd = TextEditingController();
  final service = AuthService();
  bool _obscure = true;
  bool _loading = false;

  void login() async {
    if (!service.isValidEmail(loginEmail.text)) {
      showMsg("Invalid email");
      return;
    }
    if (loginPwd.text.isEmpty) {
      showMsg("Enter your password");
      return;
    }

    setState(() => _loading = true);

    bool success = await service.login(loginEmail.text, loginPwd.text);

    setState(() => _loading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      showMsg("Login failed. Check your credentials.");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Logo / Header
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Color(0xFF00C853),
                  size: 30,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Welcome back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Sign in to continue your journey",
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 40),

              // Email field
              _buildLabel("Email"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: loginEmail,
                hint: "your@email.com",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              // Password field
              _buildLabel("Password"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: loginPwd,
                hint: "••••••••",
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF616161),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                  ),
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: Color(0xFF00C853), fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: const Color(0xFF2A2A2A))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR", style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
                  ),
                  Expanded(child: Container(height: 1, color: const Color(0xFF2A2A2A))),
                ],
              ),

              const SizedBox(height: 24),

              // Sign up link
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  ),
                  child: const Text(
                    "Create new account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF424242)),
          prefixIcon: Icon(icon, color: const Color(0xFF616161), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
