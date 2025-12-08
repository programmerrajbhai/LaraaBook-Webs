import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/image_url.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/loginController.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/forget_screen.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/reg_screen.dart';
import '../widgets/containnerBox.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // রেসপন্সিভ ব্রেকপয়েন্ট (৮০০ পিক্সেলের বেশি হলে ওয়েব ভিউ)
    bool isWebLayout = size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey[50], // একদম সাদা না দিয়ে হালকা গ্রে প্রফেশনাল লাগে
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: isWebLayout
            ? _buildWebLayout(size) // ডেস্কটপ ভিউ
            : _buildMobileLayout(size), // মোবাইল ভিউ
      ),
    );
  }

  // --- WEB Layout (Split Screen) ---
  Widget _buildWebLayout(Size size) {
    return Row(
      children: [
        // Left Side: Banner / Branding
        Expanded(
          flex: 6, // ৬০% জায়গা নিবে
          child: Container(
            color: ColorPath.deepBlue.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImagePath.appLogotransparent,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  "Connect with friends and the \nworld around you on Meetyarah.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorPath.deepBlue,
                  ),
                ),
                const SizedBox(height: 40),
                // ইলাস্ট্রেশন বা বড় ইমেজ এখানে দিতে পারো
                Image.asset(
                  "assets/images/chat.png", // তোমার অ্যাসেট ফোল্ডারের ইমেজ
                  height: 300,
                ),
              ],
            ),
          ),
        ),

        // Right Side: Login Form
        Expanded(
          flex: 4, // ৪০% জায়গা নিবে
          child: Center(
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: _buildLoginForm(isWeb: true),
            ),
          ),
        ),
      ],
    );
  }

  // --- MOBILE Layout ---
  Widget _buildMobileLayout(Size size) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImagePath.appLogotransparent,
              width: 150,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            _buildLoginForm(isWeb: false),
          ],
        ),
      ),
    );
  }

  // --- Shared Form Component ---
  Widget _buildLoginForm({required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if(isWeb) ...[
          const Text(
            "Welcome Back",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text(
            "Login to continue managing your account.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),
        ],

        // Custom Text Field (Email)
        _customTextField(
          controller: loginController.emailOrPhoneCtrl,
          label: "Email or Phone",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),

        // Custom Text Field (Password)
        _customTextField(
          controller: loginController.passwordCtrl,
          label: "Password",
          icon: Icons.lock_outline,
          isPassword: true,
          onSubmit: (_) => loginController.LoginUser(),
        ),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.to(() => const ForgotScreens()),
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: ColorPath.deepBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Login Button
        Obx(() => loginController.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: ColorPath.deepBlue))
            : ElevatedButton(
          onPressed: () => loginController.LoginUser(),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPath.deepBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: const Text("LOG IN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        )),

        const SizedBox(height: 16),

        // --- GUEST LOGIN BUTTON ---
        Obx(() => loginController.isGuestLoading.value
            ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : OutlinedButton.icon(
          onPressed: () => loginController.loginAsGuest(),
          icon: const Icon(Icons.person_outline, size: 20),
          label: const Text("Continue as Guest"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.grey),
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ),

        const SizedBox(height: 24),

        // OR Divider
        Row(children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("OR", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ]),
        const SizedBox(height: 24),

        // Google Sign In (Custom Widget)
        InkWell(
          onTap: (){}, // Google Login Logic
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(ImagePath.gogoleIcon, height: 24),
                const SizedBox(width: 10),
                const Text("Sign in with Google", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Sign Up Link
        Center(
          child: RichText(
            text: TextSpan(
              text: "Don't have an account? ",
              style: const TextStyle(color: Colors.black54, fontSize: 15),
              children: [
                TextSpan(
                  text: 'Sign Up',
                  style: const TextStyle(
                    color: ColorPath.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.to(() => const RegistrationScreens()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Professional Custom TextField Widget ---
  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    Function(String)? onSubmit,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPath.deepBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}