import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/assetsPath/image_url.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/registrationController.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/login_screen.dart';

class RegistrationScreens extends StatelessWidget {
  const RegistrationScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final regController = Get.put(RegistrationController());
    final size = MediaQuery.of(context).size;
    bool isWebDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // --- LEFT SIDE: HERO IMAGE (Web Only) ---
          if (isWebDesktop)
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1529156069898-49953e39b3ac?q=80&w=2070&auto=format&fit=crop"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPath.deepBlue.withOpacity(0.9),
                        Colors.black.withOpacity(0.2),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Join the\nCommunity.",
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create your unique handle and connect with the world.",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

          // --- RIGHT SIDE: REGISTRATION FORM ---
          Expanded(
            flex: isWebDesktop ? 4 : 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isWebDesktop) ...[
                      Image.asset(
                        ImagePath.appLogotransparent,
                        height: 70,
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text(
                      "Create Account ✨",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: isWebDesktop ? TextAlign.start : TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Get started with your unique username.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: isWebDesktop ? TextAlign.start : TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // --- First & Last Name ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: regController.firstnameCtrl,
                            hint: "First Name",
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: regController.lastnameCtrl,
                            hint: "Last Name",
                            icon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- USERNAME FIELD (Unique with @) ---
                    _buildTextField(
                      controller: regController.usernameCtrl,
                      hint: "Username",
                      icon: Icons.alternate_email,
                      prefixText: "@", // এখানে @ দেখানো হবে
                    ),
                    const SizedBox(height: 16),

                    // --- Email ---
                    _buildTextField(
                      controller: regController.emailCtrl,
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // --- Password ---
                    _buildTextField(
                      controller: regController.passwordCtrl,
                      hint: "Create Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    // --- Sign Up Button ---
                    Obx(() => SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: regController.isLoading.value
                            ? null
                            : () => regController.RegisterUser(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPath.deepBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: regController.isLoading.value
                            ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 20),

                    // Divider
                    Row(children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ]),
                    const SizedBox(height: 20),

                    // --- Guest Button ---
                    Obx(() => SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: regController.isGuestLoading.value
                            ? null
                            : () => regController.continueAsGuest(),
                        icon: const Icon(Icons.travel_explore, size: 20),
                        label: Text(
                          regController.isGuestLoading.value ? "Processing..." : "Continue as Guest",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 30),

                    // --- Login Link ---
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: GoogleFonts.inter(
                                color: ColorPath.deepBlue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(() => const LoginScreen());
                                },
                            ),
                          ],
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

  // --- Helper Widget for TextField ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? prefixText, // নতুন প্যারামিটার
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        // ইউজারনেমের জন্য @ দেখাবে
        prefixText: prefixText,
        prefixStyle: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold),

        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPath.deepBlue, width: 1.5),
        ),
      ),
    );
  }
}