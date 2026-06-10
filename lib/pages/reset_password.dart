import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final service = AuthService();
  final email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  void resetPassword() async {
    if (email.text.isEmpty) {
      showMsg("Please enter your email");
      return;
    }

    setState(() => _loading = true);

    try {
      await service.resetPassword(email.text);
      setState(() {
        _loading = false;
        _sent = true;
      });
    } catch (e) {
      setState(() => _loading = false);
      showMsg("Error sending reset email");
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _sent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
          ),
          child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF00C853), size: 26),
        ),

        const SizedBox(height: 24),

        const Text(
          "Reset Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: TextStyle(color: Color(0xFF757575), fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 36),

        const Text(
          "Email",
          style: TextStyle(
            color: Color(0xFFBDBDBD),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              hintText: "your@email.com",
              hintStyle: TextStyle(color: Color(0xFF424242)),
              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF616161), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                  )
                : const Text(
                    "Send Reset Link",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Back to Sign In",
              style: TextStyle(color: Color(0xFF757575), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.check_rounded, color: Color(0xFF00C853), size: 40),
        ),
        const SizedBox(height: 28),
        const Text(
          "Check your inbox",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "A password reset link has been sent to your email address.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF757575), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: const Text(
              "Back to Sign In",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
