import 'package:flutter/material.dart';
import 'package:projet_final/pages/main_page.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final service = AuthService();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final confirmEmail = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  DateTime? dob;
  bool _obscurePwd = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  void signup() async {
    if (firstName.text.isEmpty || lastName.text.isEmpty || email.text.isEmpty) {
      showMsg("Please fill in all fields");
      return;
    }
    if (password.text.length < 6) {
      showMsg("Password must be at least 6 characters");
      return;
    }
    if (dob == null) {
      showMsg("Select your date of birth");
      return;
    }
    if (!service.isAtLeast13(dob!)) {
      showMsg("You must be at least 13 years old");
      return;
    }
    if (email.text != confirmEmail.text) {
      showMsg("Emails do not match");
      return;
    }
    if (password.text != confirmPassword.text) {
      showMsg("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    bool success = await service.signup(
      firstName: firstName.text,
      lastName: lastName.text,
      dob: dob!,
      email: email.text,
      password: password.text,
    );

    setState(() => _loading = false);

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else {
      showMsg("Registration failed. Try again.");
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C853),
              surface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => dob = picked);
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Join us and start your Quran journey",
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),

              const SizedBox(height: 32),

              // Name row
              Row(
                children: [
                  Expanded(child: _inputBlock("First Name", firstName, Icons.person_outline_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _inputBlock("Last Name", lastName, Icons.person_outline_rounded)),
                ],
              ),

              const SizedBox(height: 16),

              // Date of birth
              _buildLabel("Date of Birth"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dob != null
                          ? const Color(0xFF00C853).withOpacity(0.4)
                          : const Color(0xFF2A2A2A),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: dob != null ? const Color(0xFF00C853) : const Color(0xFF616161),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dob == null
                            ? "Select date of birth"
                            : dob.toString().split(" ")[0],
                        style: TextStyle(
                          color: dob == null ? const Color(0xFF424242) : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _inputBlock("Email", email, Icons.email_outlined),
              const SizedBox(height: 16),
              _inputBlock("Confirm Email", confirmEmail, Icons.email_outlined),
              const SizedBox(height: 16),
              _passwordBlock("Password", password, _obscurePwd,
                  () => setState(() => _obscurePwd = !_obscurePwd)),
              const SizedBox(height: 16),
              _passwordBlock("Confirm Password", confirmPassword, _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm)),

              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : signup,
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
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBlock(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Color(0xFF424242)),
              prefixIcon: Icon(icon, color: const Color(0xFF616161), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordBlock(
      String label, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
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
              hintText: "••••••••",
              hintStyle: const TextStyle(color: Color(0xFF424242)),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF616161), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF616161),
                  size: 20,
                ),
                onPressed: toggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
